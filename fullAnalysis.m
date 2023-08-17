function SP = fullAnalysis(expName,parentDir,varargin)

%Full Analysis
% This function takes an experiment name, and runs the full set of OFET
% data analysis on all devices in its Dropbox folder

if nargin == 1
    parentDir = '/Users/Imperssonator/Dropbox/Experiments/';
end
addpath('Functions')
addpath('Data')

SP = [expName, '.mat'];
expt = struct();
expt.name = expName;
expt.parentDirectory = parentDir;

% Process variables
expt.dev = addProcVars(expt,parentDir);

% AFM
expt = runAFM(expt,parentDir);

% UV-Vis


% Electrical
expt.dev = runElectrical(expt,parentDir);

save(SP,'expt')
end

function dev = addProcVars(exp,parentDir)

xlsFile = [parentDir, exp.name, '/Process.xlsx'];
[~, ~, procTable] = xlsread(xlsFile);
procTable = CleanXLSCell(procTable);
%     disp(alldata)
[numProcVars,numDevs] = size(procTable); % Number of process variables, number of devices (columns in spreadsheet)

dev = struct();
for dd = 1:numDevs-1  % iterate over devices in exp struct (exclude first column...)
    
    ddCol = dd+1;
    % Find which column has device dd
    dev(dd).devName = getDevName(procTable,ddCol);
    
    for i = 1:numProcVars
        procVari = procTable{i,1}; % category = name of process variable in row i
        cellidd = procTable{i,ddCol}; % store value of that process variable in cellidd
        dev(dd).process.(procVari)=cellidd; %store the value of cellji in the exp structure process section
    end

    dev(dd).process = ClearEmpty(dev(dd).process);
    dev(dd).process = AddSolventProps(dev(dd).process);
end

end

function devName = getDevName(procTable,devCol)

% ddName = string of dev name
% procTable = cell array where one column will correspond to ddName

[numProcVars,numDevs] = size(procTable); % Number of process variables, number of devices (columns in spreadsheet)

for i = 1:numProcVars
    if strcmp(procTable{i,1},'DevName')
        nameRow = i;
    end
end

devName = procTable{nameRow,devCol};

end

function out = findAllSubdirs()

% Generate a cell array of the names of all subdirectories in the current
% directory

D = dir;

Names = {D(:).name};

out = {};

for i = 1:length(Names)
    if D(i).isdir
        Name = Names{i};
        if Name(1) ~= '.'
            out = [out; Name];
        end
    end
end

end

function Updated = CleanXLSCell(Old)

% Takes a cell array "old" and removes any rows or columns that are
% entirely full of NaN's

[m, n] = size(Old);

GoodRows = [];
GoodCols = [];

for i = 1:m
    if all(isnan([Old{i,:}]))
    else
        GoodRows = [GoodRows i];
    end
end

for j = 1:n
    if all(isnan([Old{:,j}]))
    else
        GoodCols = [GoodCols j];
    end
end

Updated = Old(GoodRows,GoodCols);

end

function Updated = ClearEmpty(Old)

%% Find empty matrices and replace with NaN

FN = fieldnames(Old);
Updated = Old;

for d = 1:length(Old)
    for i = 1:numel(FN)
%         disp(Old(d).(FN{i}))
%         disp(isequal(Old(d).(FN{i}),[]))
        if isequal(Old(d).(FN{i}),[])
            Updated(d).(FN{i})=NaN;
        end
    end
end

end