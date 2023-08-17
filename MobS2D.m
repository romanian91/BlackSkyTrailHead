load('SnA40k')

S = [];
SE = [];
M = [];

dev = expt.dev;
for i = 1:length(dev)
    if ~isempty(dev(i).avgS2D) && ~strcmp(dev(i).devName,'4-T1-2')
        S = [S, dev(i).avgS2D];
        SE = [SE, dev(i).S2DSE];
        M = [M, dev(i).satMob];
    end
end

% Model Fit
reg = MultiPolyRegress(S',M',1);
lbS = 0; ubS = 0.5;
regX = (lbS:0.01:ubS)';
B = reg.Coefficients;
regY = regX.*B(2)+B(1);

% Plot data
hfig = figure;
hax = gca;
hold(hax,'on')
hfit = plot(hax,regX,regY,'-k');
[xb, yb, esym] = herrorbar(S,M,SE);
herr = plot(hax,xb,yb,esym);
hdata = scatter(hax,S,M); drawnow;

% Adjust axis settings
hax.YLabel.String = 'Mobility (cm^2/Vs)';
hax.XLabel.String = 'S_{2D}';
hax.FontSize=20;
hax.Box = 'on';
hax.LineWidth = 0.75;
hax.PlotBoxAspectRatio = [1 1 1];

% Adjust fit line
herr.LineWidth = 0.75;
herr.Color = [0.4 0.4 0.4];
hfit.LineWidth = 0.75;
hfit.Color = [0.6, 0.6, 0.6];

% Fine tune data labels
hdata.SizeData = 100;
hmarks = hdata.MarkerHandle;
hmarks.EdgeColorData = uint8([60; 60; 60; 175]);
hmarks.FaceColorData = uint8([120; 120; 120; 150]);

% Scale figure and write text
hfig.Position = [440 174 661 624];
htex = text('Units', 'normalized', 'Position', [0.417 0.94], ...
    'BackgroundColor', [1 1 1], ...
    'String', ['R^2 = ' num2str(reg.RSquare, 2)],...
    'FontSize', 20,...
    'EdgeColor', [0.6 0.6 0.6]);

hgexport(hfig, ['~/Documents/GA Tech/Research/Papers/Quantification of P3HT Microstructure/MobS2D.tif'],  ...
     hgexport('factorystyle'), 'Format', 'tiff'); 
