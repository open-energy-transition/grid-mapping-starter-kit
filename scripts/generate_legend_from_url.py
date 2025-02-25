#!/usr/bin/env python3
"""
parse_color_properties_improved.py

A script that:
1. Fetches a MapCSS file from a given URL.
2. Parses it (robustly handling advanced bracket/quote syntax).
3. Separates out any rule with selector == "meta" and displays its properties
   in a "Metadata" section (all combined).
4. For all other rules, extracts only properties containing "color" and
   shows them (with an HTML color swatch) in a table.

Usage:
    python parse_color_properties_improved.py <mapcss_url> <output.html>

Requires:
    pip install requests
"""

import argparse
import logging
import re
import requests
import sys
from typing import List, Dict, Any
from string import Template

# -------------------------------------------------------------------------
# 1. Argument Parsing
# -------------------------------------------------------------------------
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate an HTML legend of color properties + metadata from a MapCSS file."
    )
    parser.add_argument("mapcss_url", help="URL of the MapCSS file to fetch")
    parser.add_argument("output_file", help="Path to the output HTML file")
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose (DEBUG) logging"
    )
    return parser.parse_args()

# -------------------------------------------------------------------------
# 2. Logging Configuration
# -------------------------------------------------------------------------
def configure_logging(verbose: bool):
    log_level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S"
    )

# -------------------------------------------------------------------------
# 3. Fetch the .mapcss content
# -------------------------------------------------------------------------
def fetch_mapcss_content(url: str) -> str:
    """
    Fetch the .mapcss content from a given URL and return it as a string.
    Raises requests.RequestException on network errors.
    """
    logging.debug(f"Attempting to fetch {url}")
    response = requests.get(url)
    response.raise_for_status()
    logging.debug("Fetch successful")
    return response.text

# -------------------------------------------------------------------------
# 4. Robust splitting of selectors (with bracket/quote handling)
# -------------------------------------------------------------------------
def split_selectors_robust(selectors_raw: str) -> List[str]:
    """
    Split a selector string into multiple selectors on top-level commas only,
    ignoring commas within parentheses, square brackets, curly braces, or quotes.
    """
    selectors = []
    current = []
    bracket_depth = 0
    paren_depth = 0
    brace_depth = 0
    in_single_quote = False
    in_double_quote = False
    escape = False

    for char in selectors_raw:
        if escape:
            current.append(char)
            escape = False
            continue

        if char == "\\":
            escape = True
            current.append(char)
            continue

        if char == "'" and not in_double_quote:
            in_single_quote = not in_single_quote
            current.append(char)
            continue
        if char == '"' and not in_single_quote:
            in_double_quote = not in_double_quote
            current.append(char)
            continue

        if in_single_quote or in_double_quote:
            current.append(char)
            continue

        if char == '[':
            bracket_depth += 1
        elif char == ']':
            bracket_depth -= 1
        elif char == '(':
            paren_depth += 1
        elif char == ')':
            paren_depth -= 1
        elif char == '{':
            brace_depth += 1
        elif char == '}':
            brace_depth -= 1

        if (char == ',' and bracket_depth == 0 
                and paren_depth == 0 and brace_depth == 0):
            selector_str = "".join(current).strip()
            if selector_str:
                selectors.append(selector_str)
            current = []
        else:
            current.append(char)

    last_selector = "".join(current).strip()
    if last_selector:
        selectors.append(last_selector)

    return selectors

# -------------------------------------------------------------------------
# 5. Parsing the MapCSS content
# -------------------------------------------------------------------------
def parse_mapcss_content(content: str) -> List[Dict[str, Any]]:
    """
    Parse the MapCSS content into a list of rules with:
      - 'selectors': list of selector strings
      - 'properties': dict of style properties
    """
    # Regex to capture blocks:  selectors { ... }
    block_pattern = re.compile(
        r'([^{}]+)\s*\{\s*([^}]*)\s*\}',
        re.MULTILINE | re.DOTALL
    )

    # Regex to parse each property of the form: key: value;
    property_pattern = re.compile(r'([a-zA-Z0-9_\-\_]+)\s*:\s*([^;]+)\s*;')

    rules = []

    for match in block_pattern.finditer(content):
        selectors_raw = match.group(1).strip()
        styles_raw = match.group(2).strip()

        # Split multiple selectors carefully
        selectors = split_selectors_robust(selectors_raw)

        # Parse properties
        properties = {}
        for pm in property_pattern.finditer(styles_raw):
            prop_key = pm.group(1).strip()
            prop_value = pm.group(2).strip()
            properties[prop_key] = prop_value

        rules.append({
            'selectors': selectors,
            'properties': properties
        })

    return rules

# -------------------------------------------------------------------------
# 6. Separate out "meta" rules from regular rules
# -------------------------------------------------------------------------
def separate_meta_rules(rules: List[Dict[str, Any]]):
    """
    Return two lists:
      - meta_rules: any rule whose selectors include "meta"
      - normal_rules: all other rules
    """
    meta_rules = []
    normal_rules = []
    for r in rules:
        # If *any* of the selectors is exactly "meta"
        if any(sel.strip().lower() == "meta" for sel in r["selectors"]):
            meta_rules.append(r)
        else:
            normal_rules.append(r)
    return meta_rules, normal_rules

# -------------------------------------------------------------------------
# 7. Generating the HTML Legend
# -------------------------------------------------------------------------

HTML_TEMPLATE = Template("""\
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MapCSS Color Legend</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 1em;
        }
        table {
            border-collapse: collapse;
            width: 80%;
            margin: 0 auto;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 0.5em;
            vertical-align: top;
        }
        th {
            background: #eee;
            text-align: left;
        }
        .color-swatch {
            display: inline-block;
            width: 1.5em;
            height: 1.5em;
            vertical-align: middle;
            margin-right: 0.5em;
            border: 1px solid #333;
        }
        pre {
            background: #f8f8f8;
            padding: 0.5em;
            margin: 0;
        }
        .color-key {
            font-weight: bold;
        }
        .meta-section {
            width: 80%;
            margin: 0 auto;
            padding: 1em;
            border: 1px dashed #aaa;
            margin-bottom: 2em;
        }
        .meta-section h2 {
            margin-top: 0;
        }
    </style>
</head>
<body>
<h1>MapCSS Color Legend</h1>

$meta_section

<table>
<tr>
    <th>Selectors</th>
    <th>Color Properties</th>
</tr>
$rows
</table>
</body>
</html>
""")

ROW_TEMPLATE = Template("""\
<tr>
    <td><pre>$selectors</pre></td>
    <td>$color_props</td>
</tr>
""")

def build_meta_section(meta_rules: List[Dict[str, Any]]) -> str:
    """
    Combine all 'meta' properties into a single list under a "Metadata" heading.
    """
    if not meta_rules:
        return ""

    # Collect all properties from all meta rules
    combined_props = {}
    for rule in meta_rules:
        for k, v in rule["properties"].items():
            combined_props[k] = v

    if combined_props:
        meta_list_items = "".join(
            f"<li><strong>{k}:</strong> {v}</li>" 
            for k, v in combined_props.items()
        )
        meta_html = f"<ul>{meta_list_items}</ul>"
    else:
        meta_html = "<p><em>No metadata properties</em></p>"

    return f"""
    <div class="meta-section">
      <h2>Metadata</h2>
      {meta_html}
    </div>
    """

def generate_color_legend(rules: List[Dict[str, Any]], output_file: str):
    """
    1. Separate out meta rules from normal rules.
    2. Build a single "Metadata" section combining all meta properties.
    3. Build a color legend table for rules with "color" properties.
    """
    meta_rules, normal_rules = separate_meta_rules(rules)

    # Build meta section
    meta_section_html = build_meta_section(meta_rules)

    # Build table rows for color rules
    rows_html = []
    for rule in normal_rules:
        selectors_str = "<br>".join(rule['selectors'])
        # Filter only properties that have "color" in the key
        color_props = {
            k: v for k, v in rule["properties"].items()
            if "color" in k.lower()
        }

        if not color_props:
            row_html = ROW_TEMPLATE.substitute(
                selectors=selectors_str,
                color_props="<em>No color properties</em>"
            )
            rows_html.append(row_html)
            continue

        color_list = []
        for k, v in color_props.items():
            color_swatch = f'<span class="color-swatch" style="background:{v};"></span>'
            color_line = f'{color_swatch} <span class="color-key">{k}</span>: {v}'
            color_list.append(color_line)

        color_props_str = "<br>".join(color_list)
        row_html = ROW_TEMPLATE.substitute(
            selectors=selectors_str,
            color_props=color_props_str
        )
        rows_html.append(row_html)

    final_html = HTML_TEMPLATE.substitute(
        meta_section=meta_section_html,
        rows="".join(rows_html)
    )

    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(final_html)
        logging.info(f"Legend + metadata written to: {output_file}")
    except OSError as e:
        logging.error(f"Failed to write HTML to {output_file}: {e}")
        sys.exit(1)

# -------------------------------------------------------------------------
# 8. Main Entry Point
# -------------------------------------------------------------------------
def main():
    args = parse_args()
    configure_logging(args.verbose)

    mapcss_url = args.mapcss_url
    output_file = args.output_file

    # 1. Fetch the content
    try:
        logging.info(f"Fetching MapCSS from: {mapcss_url}")
        content = fetch_mapcss_content(mapcss_url)
    except requests.RequestException as e:
        logging.error(f"Failed to fetch MapCSS content: {e}")
        sys.exit(1)

    # 2. Parse the MapCSS content
    logging.debug("Parsing the MapCSS content")
    rules = parse_mapcss_content(content)
    logging.debug(f"Found {len(rules)} rule blocks")

    # 3. Generate the meta + color-based legend
    generate_color_legend(rules, output_file)

if __name__ == "__main__":
    main()
