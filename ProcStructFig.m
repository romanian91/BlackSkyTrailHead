%% Gather Data
% Generate your unprecedented, high-impact data...

load('SnA40k')

X2 = [];
X1 = [];
Y2 = [];
Y1 = [];
Y2e = [];
Y1e = [];

for i = 1:length(expt.dev)
    
    xVar = 'AgeTime';
    yVar = 'avgFibLen';
    if ~isempty(expt.dev(i).avgS2D) && ~strcmp(expt.dev(i).devName,'4-T1-2')
%         disp(expt.dev(i).devName)
        X1 = [X1, expt.dev(i).process.(xVar)];
        Y1 = [Y1, expt.dev(i).(yVar)];
        Y1e = [Y1e, expt.dev(i).FibLenSE];
    end
    
    yVar = 'avgS2D';
    if ~isempty(expt.dev(i).avgS2D) && ~strcmp(expt.dev(i).devName,'4-T1-2')
%         disp(expt.dev(i).devName)
        X2 = [X2, expt.dev(i).process.(xVar)];
        Y2 = [Y2, expt.dev(i).(yVar)];
        Y2e = [Y2e, expt.dev(i).S2DSE];
    end
end

%% Initialize Plot Area
% tight_subplot( <number of columns>, <number of rows>, <gap between axes>,
% <upper and lower margin outside plot>, <right and left margin> )
f1 = figure;
f1.Position = [440 19 510 779];
ha = tight_subplot(2, 1, 0, [0.1, 0.05], [0.2, 0.05]);
ha = f1.Children;
hold(ha(1),'on');
hold(ha(2),'on');
% returns ha, a matrix of axis handles, and creates a figure.

%% Plot Data
% plot each Y series on a different ha(i)... for some reason ha is a matrix
% of doubles, but this seems to work with plot(). This is some weird matlab
% thing with axes handles

% plot(ha(1),X1,Y1,'ok')
hdata1 = scatter(ha(1),X1,Y1,'ok'); drawnow;
[regX1, regY1] = fitPlot(X1,Y1);
hfit1 = plot(ha(1),regX1,regY1,'-k');
[xb1, yb1, esym1] = verrorbar(X1,Y1,Y1e);
herr1 = plot(ha(1),xb1,yb1,esym1);

hdata2 = scatter(ha(2),X2,Y2,'ok'); drawnow;
[regX2, regY2] = fitPlot(X2,Y2);
hfit2 = plot(ha(2),regX2,regY2,'-k');
[xb2, yb2, esym2] = verrorbar(X2,Y2,Y2e);
herr2 = plot(ha(2),xb2,yb2,esym2);

%% Edit Marker and Line Styles

hdata1.SizeData = 100;
hdata2.SizeData = 100;

hMarks1 = hdata2.MarkerHandle;
hMarks1.EdgeColorData = uint8([100; 100; 100; 175]);
hMarks1.FaceColorData = uint8([120; 120; 120; 150]);

hMarks2 = hdata1.MarkerHandle;
hMarks2.EdgeColorData = uint8([100; 100; 100; 175]);
hMarks2.FaceColorData = uint8([120; 120; 120; 150]);

hfit1.LineWidth = 0.75;
hfit1.Color = [0.8, 0.8, 0.8];

hfit2.LineWidth = 0.75;
hfit2.Color = [0.8, 0.8, 0.8];

herr1.LineWidth = 0.75;
herr1.Color = [0.4 0.4 0.4];

herr2.LineWidth = 0.75;
herr2.Color = [0.4 0.4 0.4];


%% Edit Figure
% Edit this figure using plot tools, or if you like doing it
% programmatically, retrieve the figure object and axes objects...

ha = f1.Children; % store axis objects in the structure array "Axes"

%% Change Font Size
for i = 1:length(ha)
    ha(i).FontSize = 16;
    ha(i).Box = 'on';
end

%% Remove extra x tick labels
% This function tries to label all of the x-axes... this command will
% remove those so only the bottom one (1) has them.

ha(1).XTick = [0 48 96 48*3 48*4];
ha(1).XTickLabel = {'0'; '2'; '4'; '6'; '8'};
ha(1).XLim = [-8 200];
ha(2).XTick = [0 48 96 48*3 48*4];
ha(2).XTickLabel = {'0'; '2'; '4'; '6'; '8'};
ha(2).XLim = [-8 200];
for i = 2:length(ha)
    ha(i).XTickLabel = {};
end

%% Set Y Ticks and Labels

ha(1).YTick = [200 600 1000 1400];
ha(1).YTickLabel = {'200'; '600'; '1000'; '1400'};
ha(1).LineWidth = 0.75;
ha(1).YLim = [200 1400];

ha(2).YTick = [0 0.1 0.2 0.3 0.4 0.5];
ha(2).YTickLabel = {'0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'};
ha(2).LineWidth = 0.75;

%% Remove overlapping y tick labels
% Also when the plots are stacked this tightly, the top y tick label of one
% plot overlaps the bottom tick label of the plot above it... this block of
% code fixes that. Try commenting this out to see what the problem is.

for i = 2:length(ha)    % Start at 2 because this isn't a problem for the bottom axis
    ha(i).YTickLabel = ha(i).YTickLabel(2:end); % remove the first tick label
    ha(i).YTick = ha(i).YTick(2:end); % and remove the first tick
end

%% Label y axes

ha(2).YLabel.String = 'S_{2D}';
ha(1).YLabel.String = 'Average Fiber Length (nm)';
% Axes(3).YLabel.String = 'Mobility (cm^2/Vs)';
ha(1).XLabel.String = 'Aging Time (days)';

%% Align y axis labels
% Even with these, the y label for the sin(x) plot isn't in line with the
% others... this can be fixed too!
yLabPos = [];
for i = 1:length(ha)
    yLabPos(i) = ha(i).YLabel.Position(1);    % get the x-coordinate of the y label for each axis
    bestPos = min(yLabPos);
end
for i = 1:length(ha)
    ha(i).YLabel.Position(1) = bestPos;       % enforce all y labels to use this location
end

htexA = text('Units', 'normalized', 'Position', [0.03 1.92], ...
    'BackgroundColor', [1 1 1], ...
    'String', 'A',...
    'FontSize', 28,...
    'EdgeColor', [1 1 1]);
htexB = text('Units', 'normalized', 'Position', [0.03 0.92], ...
    'BackgroundColor', [1 1 1], ...
    'String', 'B',...
    'FontSize', 28,...
    'EdgeColor', [1 1 1]);

%% Export

hgexport(f1, ['~/Documents/GA Tech/Research/Papers/Quantification of P3HT Microstructure/ProcStruct.tif'],  ...
     hgexport('factorystyle'), 'Format', 'tiff'); 

