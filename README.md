# Grid Mapping Starter Kit 
**Contains a starter kit for Electrical Transmission Grid Mapping in OpenStreetMap by combining Osmose with JOSM**

_The content of this repository is still under development and may significantly change over time._ 

## Setup Mapping Environment 
1. Install the newest version of JOSM on your machine. [Link](https://josm.openstreetmap.de/)
2. Configure the JOSM user interface according to your needs. A preconfigured preferences file is [available here](josm-config/preferences.xml). The wiki gives [details](https://josm.openstreetmap.de/wiki/Help/Preferences) on where to place the perferences.xml file depending on your operating system.
3. The [paint map style](josm-config/Styles_Power-style.mapcss) is dynamically loaded from this GitHub repository, optimized for large scale transmission grid mapping. If you want your own paint style, please load the file to you local machine, modify it and add it to JOSM under Edit->Preferences->Paint Map Style.
4. Load the [template session](transmission_grid_mapping_template.joz) of with File->Open.
5. Add a new OSM token to JOSM under Edit->Preferences->OSM Server. **Please be aware of that your token will be stored in your local preferences.xml file, so do not share this file with anyone.**

## Download Transmission Data and Issues
1. Zoom to the area you want to map. Activate the osm-transmission-grid layer using the preconfigured Overpass Turbo Script. If the download fails, the timeout is to low or the bounding box to large:
```
[out:json][timeout:120];
// Use the current map's bounding box for the search area

// Find all power towers
node["power"="tower"]({{bbox}}) -> .towers;

// Find all power lines that are connected to towers
way["power"="line"]({{bbox}})
  (bn.towers) -> .lines_connected_to_towers;

// Include substations
node["power"="substation"]({{bbox}}) -> .substation_nodes;
way["power"="substation"]({{bbox}}) -> .substation_ways;
relation["power"="substation"]({{bbox}}) -> .substation_relations;

// Combine all relevant results
(
  .towers;
  .lines_connected_to_towers;
  .substation_nodes;
  .substation_ways;
  .substation_relations;
);

out body;
>;
out skel qt;
```
2. Visit [Osmose](https://osmose.openstreetmap.fr/en/map/#loc=7/4.907/-72.994&level=1%2C2%2C3&tags=power&class=2&item=7040) and activate only "power lines". Press the plus symbol next to it and select "Unfinished power major line". Zoom to the area you are interested in. Activate the osmose layer in JOSM. Switch to osmose again and press Export --> JOSM. The towers with "Unfinished power major line" should now be visible in the osmose layer in JOSM. If this is not the case deactivate your ad blocker, activate Remote Control under Edit --> Preferences in JOSM, or reduce the visible area in osmose. 
3. Enable "Discourage Upload" for the Osmose layer so that you do not accidentally upload this layer. You can now investigate every osmose error in the transmission grid. After you have fixed an issue or you are not able to fix it, remove the tower from the osmose layer to keep track about your progress.

## Mapping Strategies
The following mapping strategies show different approaches to extending the existing transmission network. Please note that you should only map infrastructure that you can classify with a high degree of confidence from satellite or ground imagery.

- [ ] Search for all "Unfinished major power line" in Osmose.
- [ ] Search the news for new substations in the country that have become operational in the last years.
- [ ] Search for new substation records and for national substation records as a 'hint' layer.
- [ ] Check the records of generators, solar farms and other energy assets for integration into the transmission network.
- [ ] Check if all transmission substations are connected to the national grid.
- [ ] Check for obvious gaps in the network topology from a national perspective.
- [ ] Check for new lines parallel to existing lines and new lines leaving major CE substations. 

