function fibLen = getFibLenHist(expt,devNum)
% Given "path", the path to the folder of fiber data files with a /, and
% "devStr", a string of the title of the device (0-3 or whatever), and
% "angleStep", the level of discretization of the angular distribution,
% produce:
% N, the total count of fiber segments of a given angle, specified by
% Centers, and S_Avg, the average 2-D O.P. Also display ODists for each
% inidividual image so variance can be analyzed.

margin = 30;

FS = CompileFib(expt.AFMFolder,expt.dev(devNum).devName);
if isempty(fieldnames(FS))
    expt.dev(devNum).avgFibLen = [];
    expt.dev(devNum).stdFibLen = [];
    return
end
fibLen = [];

for i = 1:length(FS)
    fibLeni = GetFibLen(FS(i).FilePath,margin);
    fibLen = [fibLen, fibLeni];
end

end

function out = CompileFib(FolderPath,devStr)

ad = pwd;

% First compile any images from the folderpath
cd(FolderPath)

FIB = dir('*.fib.mat');
cd(ad)
out = struct();

count = 0;
for p = 1:length(FIB)
    FirstDot = findFirstDot(FIB(p).name);
    if strcmp(devStr,FIB(p).name(1:FirstDot-1))
        count = count+1;
        out(count).File = FIB(p).name;
        out(count).FilePath = [FolderPath, FIB(p).name];
    end
end

end

function FL = GetFibLen(FilePath,margin)

load(FilePath)

FibCell = imageData.xy;
Lnm = imageData.length_nm;
FL = [];
sizeX = imageData.sizeX;
sizeY = imageData.sizeY;

for i = 1:length(FibCell)
    XYi = FibCell{i};
    if any(XYi(1,:)<margin) || any(XYi(1,:)>(sizeX-margin)) ||...    % if any part of this fiber goes off the edge
            any(XYi(2,:)<margin) || any(XYi(2,:)>(sizeY-margin))
        continue
    else
        FL = [FL, Lnm(i)];
    end
end



end