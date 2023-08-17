function [N, C, S] = ODistBulk(path,devStr,angleStep)
% Given "path", the path to the folder of fiber data files with a /, and
% "devStr", a string of the title of the device (0-3 or whatever), and
% "angleStep", the level of discretization of the angular distribution,
% produce:
% N, the total count of fiber segments of a given angle, specified by
% Centers, and S_Avg, the average 2-D O.P. Also display ODists for each
% inidividual image so variance can be analyzed.

FS = CompileFib(path,devStr);
N = [];
C = [];
S = [];

for i = 1:length(FS)
    [N(i,:), C(i,:), S(i,1)] = ODistFA(FS(i).FilePath,angleStep);
end

Ntot = sum(N,1);
S_Avg = mean(S,1);
S_Std = std(S);
nsamps = length(S);
CI = tpdf(0.025,nsamps)*S_Std/sqrt(nsamps);
disp('Average OP:')
disp(S_Avg)
disp('95% Confidence Interval:')
disp(CI)
disp('Standard Error:')
disp(S_Std/sqrt(nsamps))

figure('NumberTitle', 'off', 'Name', ['ODist ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
title(devStr, 'Interpreter', 'none');
% if polarCoord % according to the selected coordinate system
% Reflect through the origin to the full 360 deg range
stepNum = round(180/angleStep);
step = pi*angleStep/180; % angle step in rad
centers = - step/2 + linspace(0, 2*pi, 2*stepNum+1) ;
polar(centers, Ntot);
text('Units', 'normalized', 'Position', [-0.09 0.16], ...
    'BackgroundColor', [1 1 1], ...
    'String', ['S_{2D} = ' num2str(S_Avg, 2)]);
Centers = 180*centers/pi; % recalculate into deg in case of saving to a text file

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
    FirstDot = FindFirstDot(FIB(p).name);
    if strcmp(devStr,FIB(p).name(1:FirstDot-1))
        count = count+1;
        out(count).File = FIB(p).name;
        out(count).FilePath = [FolderPath, FIB(p).name];
    end
end

end

function [n, centers, S] = ODistFA(IDPath,angleStep)

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

% Plot distribution in a new figure
figure('NumberTitle', 'off', 'Name', ['ODist ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
title(imageData.name, 'Interpreter', 'none');
% if polarCoord % according to the selected coordinate system
    % Reflect through the origin to the full 360 deg range
    step = pi*angleStep/180; % angle step in rad
    centers = - step/2 + linspace(0, 2*pi, 2*stepNum+1) ;
    n = [n(end), n, n];
    polar(centers, n);
    text('Units', 'normalized', 'Position', [-0.09 0.16], ...
        'BackgroundColor', [1 1 1], ...
        'String', ['S_{2D} = ' num2str(S, 2)]);
    centers = 180*centers/pi; % recalculate into deg in case of saving to a text file
% else
%     centers = [-angleStep/2, linspace(0, 180, stepNum+1) + angleStep/2]; % in deg
%     n = [n(end), n, n(1)];
%     plot(centers, n);
%     xlim([0 180]);
%     xlabel('Angle, \theta (deg)');
%     ylabel('Number of vectors, n_v');
%     text('Units', 'normalized', 'Position', [0.8 0.95], ...
%         'BackgroundColor', [1 1 1], ...
%         'String', ['S_{2D} = ' num2str(S, 2)]);
% end

end

function v = get_vectors(xy)
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2));
v = v./[l; l];
end
