[out:json][timeout:400];

// ===============================================================
//  Grid Mapping Starter Kit  
// 
//  Cover a country, state or province you want to map 
//  with the Slippy Map bounding box to select the area you want to download. 
// 
// ===============================================================
//  Depending on the area you want to map, you need to switch  
//  between country (admin_level=2), state (admin_level=3),  
//  or province (admin_level=5) level.  
// ===============================================================
//  Please note that the minimum voltage level in this script  
//  is set to 90 kV by default, as these scripts are optimized  
//  for transmission grid mapping. 
//  Add poles and lower the voltage to map the distribution grid. 
// ===============================================================

// Select country or state/province nodes inside the bounding box
node["place"~"country|state|province"]({{bbox}}) -> .places;

  // ================================
  //  You can set the admin_level  
  //         in the following code.   
  // ================================

// Find administrative boundaries that match the selected admin level
relation["boundary"="administrative"]["admin_level"="2"](bn.places) -> .admin_boundary;

  // =========================================================
  //  If you want load data based on country, state, or  
  //  province names, please comment out the code in  
  //  the following lines.  
  // =========================================================

// relation["boundary"="administrative"]["name"~"Kenya|Uganda"] -> .admin_boundary;
// relation["boundary"="administrative"]["name"~"Colombia"] -> .admin_boundary;

// Map the relation to an area
.admin_boundary map_to_area -> .searchArea;

// ================================
// Get transmission grid relevant data
// ================================

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
  // poles
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
