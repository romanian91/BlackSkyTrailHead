%% Gather Data
% Generate your unprecedented, high-impact data...

load('SnA40k')

X1 = [];
X2 = [];
X3 = [];
Y1 = [];
Y2 = [];
Y3 = [];

for i = 1:length(expt.dev)
    
    xVar = 'AgeTime';
    yVar = 'satMob';
    if ~isempty(expt.dev(i).satMob) ...
            && ~strcmp(expt.dev(i).devName,'4-T1-2')...
            && ~strcmp(expt.dev(i).devName,'4-T1-1')...
            && ~strcmp(expt.dev(i).devName,'4-T1-3')...
            && expt.dev(i).process.(xVar)~=3*24;
%         disp(expt.dev(i).devName)
        X1 = [X1, expt.dev(i).process.(xVar)];
        Y1 = [Y1, expt.dev(i).(yVar)];
    end
end

[X, Y, YE] = raw2err(X1,Y1);

%% Initialize Plot Area
% tight_subplot( <number of columns>, <number of rows>, <gap between axes>,
% <upper and lower margin outside plot>, <right and left margin> )
f1 = figure;
hold on
f1.Position = [440 318 539 480];

%% Plot Data

hdata = scatter(X,Y,'ok'); drawnow;
hax = gca; % store axis objects in the structure array "Axes"
[regX, regY] = fitPlot(X,Y);
hfit = plot(hax,regX,regY,'-k');
[xb, yb, esym] = verrorbar(X,Y,YE);
herr = plot(hax,xb,yb,esym);

%% Format Lines and Markers

hdata.SizeData = 100;
hMarks = hdata.MarkerHandle;
hMarks.EdgeColorData = uint8([100; 100; 100; 175]);
hMarks.FaceColorData = uint8([120; 120; 120; 150]);

hfit.LineWidth = 0.75;
hfit.Color = [0.8, 0.8, 0.8];

herr.LineWidth = 0.75;
herr.Color = [0.4 0.4 0.4];

%% Format Plot Area

hax.FontSize = 20;
hax.Box = 'on';
hax.PlotBoxAspectRatio = [1 1 1];
hax.LineWidth = 0.75;
hax.YLabel.String = 'Mobility (cm^2/Vs)';
hax.XLabel.String = 'Aging Time (days)';

%% Format Ticks

hax.XTick = 24*(0:2:8);
XTL = {};
for i = 1:length(hax.XTick)
    XTL = [XTL; {num2str(uint8(hax.XTick(i)/24))}];
end
hax.XTickLabel = XTL;
hax.XLim = [-8 200];

hax.YTick = (0.06:0.02:0.16);
YTL = {};
for i = 1:length(hax.YTick)
    YTL = [YTL; {num2str(hax.YTick(i))}];
end
hax.YTickLabel = YTL;
% Axes(1).YTickLabel = {'200'; '400'; '600'; '1000'; '1400'};

%% Export

hgexport(f1, ['~/Documents/GA Tech/Research/Papers/Quantification of P3HT Microstructure/MobvTime.tif'],  ...
     hgexport('factorystyle'), 'Format', 'tiff'); 

