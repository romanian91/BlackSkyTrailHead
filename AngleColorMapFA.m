function [] = AngleColorMapFA(msPath)

load(msPath)

figure
AngMapNaN = MSA;
AngMapNaN(~MSB)=NaN;
AngMapNaN(1,1) = 180; AngMapNaN(end,end) = -180;        % enforce the lower and upper bounds of the color map
pcolor(AngMapNaN); shading flat; axis equal; set(gca,'YDir','reverse');
hmap = [(0:256)'/256; (0:256)'/256];
hmap(:,2) = 1; %saturation
hmap(:,3) = 0.85; %value
huemap = hsv2rgb(hmap);
colormap(huemap);
ax = gca;
ax.Visible = 'off';


end