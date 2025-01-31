# Grid Mapping Starter Kit 
**A starter kit for transmission grid mapping in OpenStreetMap** 

This repository contains a starter kit for Electrical Transmission Grid Mapping in OpenStreetMap by combining Osmose with JOSM.

_Please keep in mind that the content of this repository is still under development and the recommendations may change significantly over time._ 

## Setup Mapping Environment 
1. Install the newest version JOSM on your machine. [Link](https://josm.openstreetmap.de/)
2. Configure the JOSM GUI preferences according to your needs. A preconfigured preferences file is [available here](josm-config/preferences.xml). The wiki gives [details](https://josm.openstreetmap.de/wiki/Help/Preferences) on where to place the perferences.xml file depending on your operating system.
3. Add the [paint map style](), optimized for large scale transmission grid mapping, under Edit->Preferences->Paint Map style
4. Zoom to you area of interested and download new transmission grid data into your osm-transmission-grid layer using the preconfigured Overpass Turbo Script. If the download fails the timeout is to low or the bounding box to large. 
```
[out:json][timeout:60];
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
5. Visit Osmose and activate only "power lines". Press the plus symbol next to it and only select "Unfinished power major line". Zoom to the area you are interested in. Activate the osmose layer in JOSM and press Export --> JOSM. The towers with Unfinished power major line should now be visible in the osmose layer. If this is not the case deactivate your ad blocker, activate Remote Control under Edit --> Preferences in JOSM, or reduce the visible area in osmose. 
6. You can now check every osmose error in the transmission grid. After you have fixed an issue or you are not able to fix it, remove the tower from the osmose layer to see what you already have checked. 

