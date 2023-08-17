function expt = getS2D(expt,devNum)
% Given "path", the path to the folder of fiber data files with a /, and
% "devStr", a string of the title of the device (0-3 or whatever), and
% "angleStep", the level of discretization of the angular distribution,
% produce:
% N, the total count of fiber segments of a given angle, specified by
% Centers, and S_Avg, the average 2-D O.P. Also display ODists for each
% inidividual image so variance can be analyzed.

defaultAngleStep = 5;

FS = CompileFib(expt.AFMFolder,expt.dev(devNum).devName);
if isempty(fieldnames(FS))
    expt.dev(devNum).S2D = [];
    expt.dev(devNum).S2DSE = [];
    return
end
S = [];

for i = 1:length(FS)
    S(i,1) = getSingleS(FS(i).FilePath,defaultAngleStep);
end

S_Avg = mean(S,1);
expt.dev(devNum).avgS2D = S_Avg;
disp(expt.dev(devNum).devName)
disp(S)
disp(S_Avg)
S_Std = std(S);
nsamps = length(S);
CI = tpdf(0.025,nsamps)*S_Std/sqrt(nsamps);
% disp('Average OP:')
% disp(S_Avg)
% disp('95% Confidence Interval:')
% disp(CI)
% disp('Standard Error:')
SE = S_Std/sqrt(nsamps);
expt.dev(devNum).S2DSE = SE;
expt.dev(devNum).S2DCI = CI;
expt.dev(devNum).stdS2D = S_Std;
% disp(SE)

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

function S = getSingleS(IDPath,angleStep)

load(IDPath)

% Proceed with the selected data
vect = cellfun(@get_vectors, imageData(1).xy, 'UniformOutput', false);
vect = [vect{:}]; % unite data of all fibrils

% Calculate 2D order parameter (S)
A = sum(vect(1,:).^2);
B = sum(prod(vect));
N = size(vect, 2);
S = sqrt((2*A-N)^2+4*B^2)/N;

% Calculate orientation distribution
vect(:, vect(2,:)>0) = - vect(:, vect(2,:)>0); % Turn the coordinate system from informatics into geometrical 
orientation = acos(vect(1,:));

% Check angleStep value
stepNum = round(180/angleStep);
angleStep = 180/stepNum;
% set(ui.angleStep, 'String', angleStep);

% Calculate for 0-pi range
n = histc(orientation, linspace(0, pi, stepNum+1));
n(1) = n(1) + n(end);
n(end) = []; % remove orientation = pi values



end

function v = get_vectors(xy)
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2));
v = v./[l; l];
end
