# Grid Mapping Starter Kit

**A starter kit for Electrical Transmission Grid Mapping in OpenStreetMap, combining Osmose with JOSM.**

_This repository is still under development and may change significantly over time._

## Setup Mapping Environment
1. Install the latest version of JOSM on your machine. [Download here](https://josm.openstreetmap.de/).
2. Configure the JOSM user interface according to your needs. A preconfigured preferences file is [available here](josm-config/preferences.xml). The [JOSM wiki](https://josm.openstreetmap.de/wiki/Help/Preferences) provides details on where to place the `preferences.xml` file, depending on your operating system.
3. The [paint map style](josm-config/transmission_grid_mapping_style.mapcss) is dynamically loaded from this GitHub repository and optimized for large-scale transmission grid mapping using [this URL](https://raw.githubusercontent.com/open-energy-transition/grid-mapping-starter-kit/refs/heads/main/josm-config/transmission_grid_mapping_style.mapcss). If you want to use a custom paint style, download the file to your local machine, modify it, and add it to JOSM under **Edit → Preferences → Paint Map Style**.
4. Load the [template session](josm-config/transmission_grid_mapping_template.joz) by selecting **File → Open**.
5. Add a new OSM token to JOSM under **Edit → Preferences → OSM Server**. **Be aware that your token will be stored in your local `preferences.xml` file. Do not share this file with anyone.**

## Download Transmission Data and Issues
1. Zoom to the area you want to map. Activate the `osm-transmission-grid` layer and download the osm tranmission data to this layer using the preconfigured Overpass Turbo script [transmission-grid.overpassql](josm-config/transmission-grid.overpassql). **Press Download → Download from Overpass API** and copy/paste the content to the script window. If the download fails, the timeout may be too low or the bounding box too large:
2. Visit [Osmose](https://osmose.openstreetmap.fr/en/map/#loc=7/4.907/-72.994&level=1%2C2%2C3&tags=power&class=2&item=7040) and activate only **"Power lines"**. Click the plus symbol next to it and select **"Unfinished power major line"**. Zoom to the area of interest, activate the Osmose layer in JOSM, switch back to Osmose, and press **Export → JOSM**. Towers with "Unfinished power major line" should now be visible in the Osmose layer in JOSM.
   - If the towers are not visible, try the following:
     - Disable your ad blocker.
     - Enable **Remote Control** under **Edit → Preferences** in JOSM.
     - Reduce the visible area in Osmose.
3. Enable **"Discourage Upload"** for the Osmose layer to prevent accidental uploads. You can now investigate each Osmose error in the transmission grid. After fixing an issue (or if you cannot fix it), remove the tower from the Osmose layer to track your progress.

## Mapping Strategies
The following strategies outline different approaches to extending the existing transmission network. **Only map infrastructure that you can confidently classify using satellite or ground imagery.**

- [ ] Search for all **"Unfinished major power lines"** in Osmose.
- [ ] Look for news reports on new substations and transmission lines that have become operational in recent years. LLMs like ChatGPT allow you to search in the local language: _"Please search for news about transmission lines or substation recently opened in X. Please use the official language of the country for your search"_
- [ ] Search for new substation records and national substation records as a reference "hint" layer. LLMs like ChatGPT allow you to search in the local language: _"Please search for transmission lines or substation datasets in X. Please use the official language of the country for your search"_
- [ ] Check records of generators, solar farms, and other energy assets for integration into the transmission network.
- [ ] Ensure all transmission substations are connected to the national grid.
- [ ] Identify obvious gaps in the network topology from a national perspective.
- [ ] Look for new lines parallel to existing ones and new lines starting from major central substations.

