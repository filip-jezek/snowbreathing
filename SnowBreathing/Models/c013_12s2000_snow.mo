within SnowBreathing.Models;

model c013_12s2000_snow
  SnowBreathing.Components.ConeCompGrad coneCompGrad( D_CO2 = 3e-4, D_O2 = 3e-4,caseID = "c013-12s2000", useCO2Solubility = false) annotation(
    Placement(visible = true, transformation(origin = {10, -6}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Components.ExperimentalData data(caseID = "c013-12s2000") annotation(
    Placement(visible = true, transformation(origin = {-54, -6}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(data.fluxConcCO2O2, coneCompGrad.fluxConcB) annotation(
    Line(points = {{-46, -6}, {10, -6}}, color = {0, 12, 255}));
  annotation(
    experiment(StartTime = 0, StopTime = 800, Tolerance = 1e-06, Interval = 0.1));
end c013_12s2000_snow;