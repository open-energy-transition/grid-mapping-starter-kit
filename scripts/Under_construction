// ================================
// Get power infrastructure under construction or proposed
// ================================

(
  nwr["power"="tower"]["construction"];
  nwr["power"="tower"]["proposed"];
  nwr["power"="pole"]["construction"];
  nwr["power"="pole"]["proposed"];
  nwr["power"="line"]["construction"];
  nwr["power"="line"]["proposed"];
  nwr["power"="substation"]["construction"];
  nwr["power"="substation"]["proposed"];
  nwr["power"="plant"]["construction"];
  nwr["power"="plant"]["proposed"];
  nwr["power"="generator"]["construction"];
  nwr["power"="generator"]["proposed"];
  nwr["power"="transformer"]["construction"];
  nwr["power"="transformer"]["proposed"];
  nwr["power"="portal"]["construction"];
  nwr["power"="portal"]["proposed"];
) -> .unfinished_power;

// High-voltage power lines (>= 90 kV)
(
  way["power"="line"]["voltage"](if:t["voltage"] >= 90000)["construction"];
  way["power"="line"]["voltage"](if:t["voltage"] >= 90000)["proposed"];
) -> .high_voltage_lines_unfinished;

// Combine results
(
  .unfinished_power;
  .high_voltage_lines_unfinished;
);

out body;
>;
out skel qt;
