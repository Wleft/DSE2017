%% project starting script

% add maps to matlab path
addpath(genpath('Aerodynamics'),genpath('Hydrodynamics'),genpath('Operations'),genpath('Propulsion and Performance'),genpath('Stability and Control'),genpath('Structures'),genpath('Other'))

% get current values
raw = GetGoogleSpreadsheet('1IoZBrjcV7A9TBFl9LnCycaRduCVj8CQdqR6YlVuH_FQ');

isString    = cellfun('isclass', raw, 'char'); % change , to .
raw(isString) = strrep(raw(isString), ',', '.');

Weights.kg = str2num(char(raw(2:5,2)));
Weights.N = str2num(char(raw(2:5,4)));
Weights.text = raw(2:5,1);