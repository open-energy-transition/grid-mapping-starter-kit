import requests
import json

def fetch_osmose_data(region, issue_type=8110):

    url = f"https://osmose.openstreetmap.fr/api/0.3/issues.json?state={region}&item={issue_type}"
    
    response = requests.get(url)
    
    if response.status_code != 200:
        print(f"Error fetching data: {response.status_code}")
        return []
    
    data = response.json()
    print(data)
    issues = []
    
    for issue in data.get("issues", []):
        lat = issue.get("lat")
        lon = issue.get("lon")
        
        if lat is not None and lon is not None:
            issues.append({
                "type": "Feature",
                "properties": {
                    "id": issue.get("id"),
                    "item": issue.get("item", "Unknown"),
                },
                "geometry": {
                    "type": "Point",
                    "coordinates": [lon, lat]
                }
            })
    
    print(issues)
    return issues

def save_to_geojson(issues, filename="osmose_unfinished_power_lines.geojson"):
    """
    Saves the extracted issues to a GeoJSON file.
    :param issues: List of issues.
    :param filename: Name of the output GeoJSON file.
    """
    if not issues:
        print("No issues to save.")
        return
    
    geojson_data = {
        "type": "FeatureCollection",
        "features": issues
    }
    
    with open(filename, mode='w', encoding='utf-8') as file:
        json.dump(geojson_data, file, indent=4)
    
    print(f"Data saved to {filename}")

if __name__ == "__main__":
    region = input("Enter country or state name: ").strip()
    issues = fetch_osmose_data(region)
    print(f"Fetched {len(issues)} issues.")
    save_to_geojson(issues)
