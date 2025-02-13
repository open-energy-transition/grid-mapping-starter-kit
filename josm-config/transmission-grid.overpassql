[out:json][timeout:200];

{{geocodeArea:"Kenya"}}->.searchArea;

relation["boundary"="administrative"][admin_level=2](area.searchArea) ->.administrative_boundary;

// Find all power towers
node["power"="tower"](area.searchArea) -> .towers;

// Find all power poles.
node["power"="pole"](area.searchArea) -> .poles;

// Find all power lines that are connected to towers
way["power"="line"](area.searchArea)
  (bn.towers) -> .lines_connected;

// Find all high-voltage power lines (>= 90 kV)
way["power"="line"]["voltage"](if:t["voltage"] >= 90000)(area.searchArea) -> .high_voltage_lines;

// Find only poles that are part of high-voltage lines
node.poles(w.high_voltage_lines) -> .hv_poles;

// Include substations
node["power"="substation"](area.searchArea) -> .substation_nodes;
way["power"="substation"](area.searchArea) -> .substation_ways;
relation["power"="substation"](area.searchArea) -> .substation_relations;

// Include power plants
node["power"="plant"](area.searchArea) -> .plant_nodes;
way["power"="plant"](area.searchArea)-> .plant_ways;
relation["power"="plant"](area.searchArea) -> .plant_relations;

// Include generators 
node["power"="generator"](area.searchArea) -> .generator_nodes;
way["power"="generator"](area.searchArea) -> .generator_ways;
relation["power"="generator"](area.searchArea) -> .generator_relations;

// Include portals 
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
  .administrative_boundary;
);

out body;
>;
out skel qt;
