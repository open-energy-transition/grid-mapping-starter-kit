[out:json][timeout:400];

// This query looks for towers at the beginning or end of a line, that have not been connected to a generator/plant or a substation/portal/transformer
// It will help find and correctly finalise lines 

// Select country or state/province nodes inside the bounding box
node["place"~"country|state|province"]({{bbox}}) -> .places;

// Find administrative boundaries that match the selected admin level
// Admin_level 4 if working in a region, level 2 for country-level
relation["boundary"="administrative"]["admin_level"="2"](bn.places) -> .admin_boundary;

// Map the relation to an area
.admin_boundary map_to_area -> .searchArea;

// Get power towers 
node["power"="tower"](area.searchArea) -> .towers;  

// Find power lines 
way["power"="line"](area.searchArea)-> .lines;

// Find "beginning/end" power connections
nwr["power"~"substation|transformer|plant|portal|generator"](area.searchArea) -> .power_nodes;  

// Find towers close to beginning/end power infrastructure within 400 metres 
node.towers(around.power_nodes:400) -> .towers_close;

// Find towers connected only one way (dead end)
node.towers_close(way_link.lines:1)->.towers_deadend;

.towers_deadend out body;
>;
out skel qt;   

    
