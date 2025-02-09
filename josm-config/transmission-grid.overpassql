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

// Include power plants
node["power"="plant"]({{bbox}}) -> .plant_nodes;
way["power"="plant"]({{bbox}}) -> .plant_ways;
relation["power"="plant"]({{bbox}}) -> .plant_relations;

// Combine all relevant results
(
  .towers;
  .lines_connected_to_towers;
  .substation_nodes;
  .substation_ways;
  .substation_relations;
  .plant_nodes;
  .plant_ways;
  .plant_relations;
);

out body;
>;
out skel qt;
