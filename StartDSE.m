%% project starting script

% add maps to matlab path
addpath(genpath('Aerodynamics'),genpath('Hydrodynamics'),genpath('Operations'),genpath('Propulsion and Performance'),genpath('Stability and Control'),genpath('Structures'),genpath('Other'))

% get current values
raw = GetGoogleSpreadsheet('1IoZBrjcV7A9TBFl9LnCycaRduCVj8CQdqR6YlVuH_FQ');

isString    = cellfun('isclass', raw, 'char'); % change , to .
raw(isString) = strrep(raw(isString), ',', '.');

isString    = cellfun('isclass', raw, 'char'); % change ' ' to _
raw(isString) = strrep(raw(isString), ' ', '_');

isString    = cellfun('isclass', raw, 'char'); % remove *
raw(isString) = strrep(raw(isString), '*', '');

isString    = cellfun('isclass', raw, 'char'); % remove (
raw(isString) = strrep(raw(isString), '(', '');

isString    = cellfun('isclass', raw, 'char'); % remove )
raw(isString) = strrep(raw(isString), ')', '');

isString    = cellfun('isclass', raw, 'char'); % remove /
raw(isString) = strrep(raw(isString), '/', '');

clear isString
rawdouble = cellfun(@(x)str2double(x), raw);

[row, col] = find(not(isnan(rawdouble)));
[j,~] = size(row);
k=0;
for i=1:j
    if isequal(raw(row(i), col(i)-1),{'kg'}) %skip kg entries, due to duplicate variable names
        k=k+1;
    else
        vars(i-k) = raw(row(i), col(i)-1);
        pars(i-k) = raw(row(i), col(i));
        uni(i-k) = raw(row(i), col(i)+1);
    end
end

% make data structure
pars = cellfun(@(x)str2double(x), pars);
dat = array2table(pars);
dat.Properties.VariableNames = vars;
data = table2struct(dat);

% make units structure
unit = array2table(uni);
unit.Properties.VariableNames = vars;
units = table2struct(unit);

clearvars -except data units