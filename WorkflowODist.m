% load('SnA40k')
% d6 = expt.dev(15);
% fib61={d6.AFM(:).fibPath};
% fib61 = fib61(2:4);
% 
% for i = 1:length(fib61)
%     ODistFA(fib61{i},5,['E', num2str(i)]);
%     
%     hgexport(gcf, ['~/Documents/GA Tech/Research/Papers/Quantification of P3HT Microstructure/Workflow/ODist', num2str(i), '.tif'],  ...
%         hgexport('factorystyle'), 'Format', 'tiff');
% end

% Set parameters (these could be arguments to a function)
rInner = 0;     % inner radius of the colour ring
rOuter = 200;    % outer radius of the colour ring
ncols = 180;      % number of colour segments
% Get polar coordinates of each point in the domain
[x, y] = meshgrid(-rOuter-20:rOuter+20);
[theta, rho] = cart2pol(x, -y);
% Set up colour wheel in hsv space
theta(theta<0) = theta(theta<0)+pi;

hue = theta/pi;
hue = ceil(hue * ncols) / ncols;   % quantise hue 
saturation = ones(size(hue));      % full saturation
saturation(rho>rOuter) = 0;
brightness = 0.88*double(rho >= rInner & rho <= rOuter) + ...
                double(rho>rOuter);  % white outside ring
% Convert to rgb space for display
rgb = hsv2rgb(cat(3, hue, saturation, brightness));
% Check result
figure
imshow(rgb);

imwrite(rgb, '~/Documents/GA Tech/Research/Papers/Quantification of P3HT Microstructure/Workflow/ColorWheel.tif');