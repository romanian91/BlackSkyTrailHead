function expt = getCurvDist(expt,devNum)
% Given "path", the path to the folder of fiber data files with a /, and
% "devStr", a string of the title of the device (0-3 or whatever), and
% "angleStep", the level of discretization of the angular distribution,
% produce:
% N, the total count of fiber segments of a given angle, specified by
% Centers, and S_Avg, the average 2-D O.P. Also display ODists for each
% inidividual image so variance can be analyzed.

numBins = 50; % default for now

FS = CompileFib(expt.AFMFolder,expt.dev(devNum).devName);
if isempty(fieldnames(FS))
    expt.dev(devNum).avgCurv = [];
    expt.dev(devNum).stdCurv = [];
    return
end
curv = [];

for i = 1:length(FS)
    curvi = getCurv(FS(i).FilePath);
    curv = [curv, curvi];
end

expt.dev(devNum).avgCurv = mean(abs(curv));
expt.dev(devNum).stdCurv = std(curv);

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

function curvature = getCurv(FilePath)

load(FilePath)
step = imageData.step_nm;
data = {imageData.xy_nm};
data = [data{:}];
vectSep = 2;

curvature = cellfun(@(xy)curvature_calc(xy, step, vectSep), data, ...
            'UniformOutput', false);
curvature = [curvature{:}]; % unite curvature of all fibrils

end

function curvature = curvature_calc(xy, step, vectSep)
% First derivative
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2)); % vectors length
v = v./[l; l]; % normalize

v12 = v(:, 1:end-vectSep);
v23 = v(:, 1+vectSep:end);

% Second derivative
vect = v23 - v12;
leng = step*vectSep;
vect = vect./leng;

% Curvature sign
v13 = v12 + v23;
s = sign(v12(1,:).*v13(2,:) - v12(2,:).*v13(1,:));

% Resulting curvature
curvature = sqrt(sum(vect.^2)).*s;

end