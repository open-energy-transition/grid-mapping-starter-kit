[out:json][timeout:400];

// Select country or state/province nodes inside the bounding box
node["place"~"country|state|province"]({{bbox}}) -> .places;

// Find administrative boundaries that match the selected admin level
// Admin_level 4 if working in a region, level 2 for country-level
// Admin level 4 sometimes does not work (ie. Gabon), so do admin 2 and change settlements to only fetch cities
relation["boundary"="administrative"]["admin_level"="2"](bn.places) -> .admin_boundary;

// Map the relation to an area
.admin_boundary map_to_area -> .searchArea;

// ================================
// Get power towers 
// ================================
node["power"="tower"](area.searchArea) -> .towers;  

// Find all power lines that are connected to towers within the administrative boundary
way["power"="line"](area.searchArea)-> .lines;

nwr["power"~"substation|transformer|plant|portal"](area.searchArea) -> .power_nodes;  

// Find towers close to end power infrastructure within 400 metres
node.towers(around.power_nodes:400) -> .towers_close;

// Find towers connected with one way (dead end)
node.towers_close(way_link.lines:1)->.towers_deadend;

// ===========================
//If you want to exclude towers that are within the substation boundary

// First find substations
nwr["power"="substation"](area.searchArea) -> .substations;

//Get the area of a substation
.substations map_to_area -> .substation_areas;

// Find towers inside the boundary
node.towers(area.substation_areas)->.towers_insidesub;

// Find towers outside the boundary
(.towers_deadend; - .towers_insidesub;)->.towers_unfinished;


.towers_unfinished out body;
>;
out skel qt;   

    
