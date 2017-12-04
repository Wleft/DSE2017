%% project starting script

% add maps to matlab path
addpath(genpath('Aerodynamics'),genpath('Hydrodynamics'),genpath('Operations'),genpath('Propulsion and Performance'),genpath('Stability and Control'),genpath('Structures'),genpath('Other'))

% get current values
raw = GetGoogleSpreadsheet('1IoZBrjcV7A9TBFl9LnCycaRduCVj8CQdqR6YlVuH_FQ');

