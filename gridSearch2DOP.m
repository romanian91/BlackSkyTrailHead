load('SnA40k')

S = zeros(10,100);
SE = zeros(10,100);
M = zeros(10,1);
FITloocv = zeros(1,100);

dev = expt.dev;
count = 0;
for i = 1:length(dev)
    if ~isempty(dev(i).avgS2D) && ~strcmp(dev(i).devName,'4-T1-2')
        count = count+1;
        M(count) = dev(i).satMob;
    end
end

dev = expt.dev;
count = 0;
for i = 1:length(dev)
    if ~isempty(dev(i).avgS2D) && ~strcmp(dev(i).devName,'4-T1-2')
        count = count+1;
        countj = 0;
        Si = zeros(3,100);
        for j = 1:length(dev(i).AFM)
            if ~isempty(dev(i).AFM(j).fibPath)
                countj = countj+1;
                Si(countj,:) = dev(i).AFM(j).S_im;
            end
        end
        S(count,:) = mean(Si,1);
        SE(count,:) = std(Si,1)/sqrt(size(Si,1));
    end
end

FITS = MultiPolyRegress([1; 2; 3],[2; 4; 8],1);

for i = 1:size(S,2)
    FITS(1,i) = findBestFit(S(:,i),M(:,1),1);
    FITloocv(1,i) = FITS(1,i).CVMAE;
end
    
% 
% 
% % Model Fit
% reg = MultiPolyRegress(S',M',1);
% lbS = 0; ubS = 0.5;
% regX = (lbS:0.01:ubS)';
% B = reg.Coefficients;
% regY = regX.*B(2)+B(1);
% 
% % Plot data
% hfig = figure;
% hax = gca;
% hold(hax,'on')
% hfit = plot(hax,regX,regY,'-k');
% [xb, yb, esym] = herrorbar(S,M,SE);
% herr = plot(hax,xb,yb,esym);
% hdata = scatter(hax,S,M); drawnow;
% 
% % Adjust axis settings
% hax.YLabel.String = 'Mobility (cm^2/Vs)';
% hax.XLabel.String = 'S_{2D}';
% hax.FontSize=20;
% hax.Box = 'on';
% hax.LineWidth = 0.75;
% hax.PlotBoxAspectRatio = [1 1 1];
% 
% % Adjust fit line
% herr.LineWidth = 0.75;
% herr.Color = [0.4 0.4 0.4];
% hfit.LineWidth = 0.75;
% hfit.Color = [0.6, 0.6, 0.6];
% 
% % Fine tune data labels
% hdata.SizeData = 100;
% hmarks = hdata.MarkerHandle;
% hmarks.EdgeColorData = uint8([60; 60; 60; 175]);
% hmarks.FaceColorData = uint8([120; 120; 120; 150]);
% 
% % Scale figure and write text
% hfig.Position = [440 174 661 624];
% htex = text('Units', 'normalized', 'Position', [0.417 0.94], ...
%     'BackgroundColor', [1 1 1], ...
%     'String', ['R^2 = ' num2str(reg.RSquare, 2)],...
%     'FontSize', 20,...
%     'EdgeColor', [0.6 0.6 0.6]);
% 
% hgexport(hfig, ['~/Documents/GA Tech/Research/Papers/Quantification of P3HT Microstructure/MobS2D.tif'],  ...
%      hgexport('factorystyle'), 'Format', 'tiff'); 
