[out:json][timeout:400];

node["place"~"country|state|province"]({{bbox}}) -> .places;
relation["boundary"="administrative"]["admin_level"="4"](bn.places) -> .admin_boundary;

// Map the relation to an area
.admin_boundary map_to_area -> .searchArea;

// ================================
// Get settlements
// ================================
node["place"~"village|town|city"](area.searchArea) -> .settlement_node;
way["place"~"village|town|city"](area.searchArea) -> .settlement_way;
relation["place"~"village|town|city"](area.searchArea) -> .settlement_relation;

(
  .settlement_node;
  .settlement_way;
  .settlement_relation;
) -> .settlements;

// ================================
// Get power-related infrastructure
// ================================
(
  node["power"="tower"](area.searchArea);
  node["power"="pole"](area.searchArea);
  way["power"="line"](area.searchArea);
  node["power"="substation"](area.searchArea);
  way["power"="substation"](area.searchArea);
  relation["power"="substation"](area.searchArea);
  node["power"="generator"](area.searchArea);
  way["power"="generator"](area.searchArea);
  relation["power"="generator"](area.searchArea);
  node["power"="plant"](area.searchArea);
  way["power"="plant"](area.searchArea);
  relation["power"="plant"](area.searchArea);
  node["power"="transformer"](area.searchArea);
  way["power"="transformer"](area.searchArea);
  relation["power"="transformer"](area.searchArea);
  node["power"="portal"](area.searchArea);
) -> .power_infra;

// Find settlements with power infrastructure within 5km
nwr.settlements(around.power_infra:5000) -> .settlements_with_power;

// Find settlements WITHOUT power infrastructure
(.settlements; - .settlements_with_power;)-> .unpowered_settlements;

.unpowered_settlements out body;
>;
out skel qt;
