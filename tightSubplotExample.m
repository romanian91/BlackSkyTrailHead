%% Generate Data
% Generate your unprecedented, high-impact data...

X = (0:0.1:10);
Y1 = X.^2+randn(size(X));
Y2 = sin(X)+randn(size(X))/10;
Y3 = exp(-X)+randn(size(X))/10;

%% Initialize Plot Area
% tight_subplot( <number of columns>, <number of rows>, <gap between axes>,
% <upper and lower margin outside plot>, <right and left margin> )
figure
ha = tight_subplot(3, 1, 0, 0.1, 0.12);
% returns ha, a matrix of axis handles, and creates a figure.

%% Plot Data
% plot each Y series on a different ha(i)... for some reason ha is a matrix
% of doubles, but this seems to work with plot(). This is some weird matlab
% thing with axes handles

plot(ha(1),X,Y1,'ok')
plot(ha(2),X,Y2,'-b')
plot(ha(3),X,Y3,'or')

%% Edit Figure
% Edit this figure using plot tools, or if you like doing it
% programmatically, retrieve the figure object and axes objects...

f1 = gcf;   % get current figure object
Axes = f1.Children; % store axis objects in the structure array "Axes"

%% Change Font Size
for i = 1:length(Axes)
    Axes(i).FontSize = 16;
end

%% Remove extra x tick labels
% This function tries to label all of the x-axes... this command will
% remove those so only the bottom one (1) has them.

for i = 2:length(Axes)
    Axes(i).XTickLabel = {};
end

%% Remove overlapping y tick labels
% Also when the plots are stacked this tightly, the top y tick label of one
% plot overlaps the bottom tick label of the plot above it... this block of
% code fixes that. Try commenting this out to see what the problem is.

for i = 2:length(Axes)    % Start at 2 because this isn't a problem for the bottom axis
    Axes(i).YTickLabel = Axes(i).YTickLabel(2:end); % remove the last tick label
    Axes(i).YTick = Axes(i).YTick(2:end); % and remove the last tick
end

%% Label y axes

Axes(1).YLabel.String = 'exp(-x)';
Axes(2).YLabel.String = 'sin(x)';
Axes(3).YLabel.String = 'x^2';
Axes(1).XLabel.String = 'x';

%% Align y axis labels
% Even with these, the y label for the sin(x) plot isn't in line with the
% others... this can be fixed too!
yLabPos = [];
for i = 1:length(Axes)
    yLabPos(i) = Axes(i).YLabel.Position(1);    % get the x-coordinate of the y label for each axis
    bestPos = min(yLabPos);
end
for i = 1:length(Axes)
    Axes(i).YLabel.Position(1) = bestPos;       % enforce all y labels to use this location
end