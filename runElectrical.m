function dev = runElectrical(expt,parentDir)

transferFolder = [parentDir, expt.name, '/Electrical/Transfer/'];
expt.transferFolder = transferFolder;
csvDir = CompileCSV(transferFolder);

dev = expt.dev;

for i = 1:length(dev)
    devName = dev(i).devName;
    for j = 1:length(csvDir)
    if strcmp(devName,csvDir(j).devName)
        dev(i).electrical.transfer.path = csvDir(j).path;
        dev(i).electrical.transfer = calcMob(dev(i).electrical.transfer);
        dev(i).satMob = dev(i).electrical.transfer.satMob;
        break
    end
    end
end

end

function out = CompileCSV(FolderPath)

ad = pwd;

% First compile any csv files from the folderpath
cd(FolderPath)

CSV = dir('*.csv');
cd(ad)

for p = 1:length(CSV)
    CSV(p).path = [FolderPath CSV(p).name];   % prepend the folder path to the file names
    CSV(p).devName = CSV(p).path(findLastSlash(CSV(p).path)+1:findLastDot(CSV(p).path)-1);   % find just the name of the device
end
out = CSV;
% disp(CSV)

% % Now search subdirectories further
% cd(FolderPath)
% SubDirs = FindAllSubDirs();     % Generate list of subdirectories
% cd(ad)
% if not(isempty(SubDirs))
%     for j = 1:length(SubDirs)
%         out = [out; CompileCSV([FolderPath SubDirs{j} '/'])];   % If not empty, also run for all subdirectories
%     end
% end
% disp(out)

end