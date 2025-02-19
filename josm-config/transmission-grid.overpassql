[out:json][timeout:400];

// Select your mapping area with a bounding box or country name(s). If possible, mapping data should be carried out at state or federal level to avoid conflicts. 

// Use the bounding box to select the boarders between 2 or more countries or select one country with a larger bounding box in it. 
// Retrieve the admin_level="2" administrative boundary that intersects with the bbox
// Switch to "admin_level"="3" for countries with large grid data.
 
relation["boundary"="administrative"]["admin_level"="2"]({{bbox}}) -> .admin_boundary;
// relation["boundary"="administrative"]["name"~"Kenya|Uganda"] -> .admin_boundary;
// relation["boundary"="administrative"]["name"~"Kenya"] -> .admin_boundary;


// Get transmission grid mapping relevant data

// Map the relation to an area
.admin_boundary map_to_area -> .searchArea;

// Find all power towers within the administrative boundary
node["power"="tower"](area.searchArea) -> .towers;

// Find all power poles within the administrative boundary
node["power"="pole"](area.searchArea) -> .poles;

// Find all power lines that are connected to towers within the administrative boundary
way["power"="line"](area.searchArea)
  (bn.towers) -> .lines_connected;

// Find all high-voltage power lines (>= 90 kV) within the administrative boundary
way["power"="line"]["voltage"](if:t["voltage"] >= 90000)(area.searchArea) -> .high_voltage_lines;

// Find only poles that are part of high-voltage lines within the administrative boundary
node.poles(w.high_voltage_lines) -> .hv_poles;

// Include substations within the administrative boundary
node["power"="substation"](area.searchArea) -> .substation_nodes;
way["power"="substation"](area.searchArea) -> .substation_ways;
relation["power"="substation"](area.searchArea) -> .substation_relations;

// Include power plants within the administrative boundary
node["power"="plant"](area.searchArea) -> .plant_nodes;
way["power"="plant"](area.searchArea) -> .plant_ways;
relation["power"="plant"](area.searchArea) -> .plant_relations;

// Include generators within the administrative boundary
node["power"="generator"](area.searchArea) -> .generator_nodes;
way["power"="generator"](area.searchArea) -> .generator_ways;
relation["power"="generator"](area.searchArea) -> .generator_relations;

// Include portals within the administrative boundary
node["power"="portal"](area.searchArea) -> .portal_nodes;

// Combine all relevant results
(
  .towers;
  .hv_poles;   // Only HV poles
  .lines_connected;
  .high_voltage_lines;
  .substation_nodes;
  .substation_ways;
  .substation_relations;
  .plant_nodes;
  .plant_ways;
  .plant_relations;
  .generator_nodes;
  .generator_ways;
  .generator_relations;
  .portal_nodes;
  .admin_boundary;
);

out body;
>;
out skel qt;
