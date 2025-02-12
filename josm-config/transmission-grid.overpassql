[out:json][timeout:120];

// Use the current map's bounding box for the search area

// Find all power towers
node["power"="tower"]({{bbox}}) -> .towers;

// Find all power poles.
node["power"="pole"]({{bbox}}) -> .poles;

// Find all power lines that are connected to towers
way["power"="line"]({{bbox}})
  (bn.towers) -> .lines_connected;

// Find all high-voltage power lines (>= 90 kV)
way["power"="line"]["voltage"](if:t["voltage"] >= 90000)({{bbox}}) -> .high_voltage_lines;

// Find only poles that are part of high-voltage lines
node.poles(w.high_voltage_lines) -> .hv_poles;

// Include substations
node["power"="substation"]({{bbox}}) -> .substation_nodes;
way["power"="substation"]({{bbox}}) -> .substation_ways;
relation["power"="substation"]({{bbox}}) -> .substation_relations;

// Include power plants
node["power"="plant"]({{bbox}}) -> .plant_nodes;
way["power"="plant"]({{bbox}}) -> .plant_ways;
relation["power"="plant"]({{bbox}}) -> .plant_relations;

// Include generators 
node["power"="generator"]({{bbox}}) -> .generator_nodes;
way["power"="generator"]({{bbox}}) -> .generator_ways;
relation["power"="generator"]({{bbox}}) -> .generator_relations;

// Include portals 
node["power"="portal"]({{bbox}}) -> .portal_nodes;

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
);

out body;
>;
out skel qt;
