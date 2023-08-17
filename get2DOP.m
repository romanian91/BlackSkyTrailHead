function expt = get2DOP(expt,devNum)
% Handle to the application data

disp(['Getting 2DOP for device ', expt.dev(devNum).devName])

dev = expt.dev(devNum);
numFib = length(dev.AFM);

for i = 1:numFib
    if isempty(dev.AFM(i).fibPath)
        continue
    end
    load(dev.AFM(i).fibPath);
    xMin = 0;
    xMax = 10000;
    yMin = 0;
    yMax = 10000;
    gridStep = 100;
    randImNum = 100;
    procLength = [];
    toSave = false;
    isCircleArea = true;
    isFitData = false;
    noFig = true;
    
    % Process selected data
    step = imageData.step_nm;
    xy = imageData.xy_nm;
    
    % Check processing area values
    p_all = cellfun(@get_points, xy, 'UniformOutput', false);
    p_all = [p_all{:}]; % combine points of all fibers
    [xMin, xMax] = utility.checkRange(xMin, xMax, p_all(1,:));
    [yMin, yMax] = utility.checkRange(yMin, yMax, p_all(2,:));
    
    % Check gridStep value
    if isempty(gridStep) || isnan(gridStep) || gridStep <= step
        % set default value
        gridStep = 10*step;
    end
    
    % Image size in grid steps (cells)
    numCellX = floor((xMax-xMin)/gridStep);
    numCellY = floor((yMax-yMin)/gridStep);
    
    % Check procLength and values
    if isempty(procLength) || isnan(procLength) || procLength <= gridStep
        % set auto value
        procStepNum = min([numCellX, numCellY]);
    else
        % round procLength to an integer number of graphSteps
        procStepNum = min([round(procLength/gridStep), numCellX, numCellY]);
    end
    procLength = procStepNum*gridStep;
    
    % Pick data within the range
    % p_im - coordinates of vectors' start points
    % v_im - vector coordinates
    xy_im = cellfun(@(xy)get_points_in_range(xy, xMin, xMax, yMin, yMax), xy, ...
        'UniformOutput', false);
    xy_im = [xy_im{:}];
    
    p_im = cellfun(@get_points, xy_im, 'UniformOutput', false);
    v_im = cellfun(@get_vectors, xy_im, 'UniformOutput', false);
    p_im = [p_im{:}];
    v_im = [v_im{:}];
    
    % Check for a presence of vectors in the processing area
    if isempty(p_im);
        warndlg('There are no fibers in the selected area');
        return
    end
    
    % Calculate fiber length density (in 1/um)
    fibLengthDensity = 1000*size(p_im, 2)*step/((xMax-xMin)*(yMax-yMin));
    
    % Calculate Order Parameter 2D vs Box size
    [xdata, S_im] = algorithm.OP2D(p_im, v_im, xMin, yMin, ...
        gridStep, procStepNum, numCellX, numCellY, isCircleArea);
    
    % Generate images with random fibers positioning
    S_rand = zeros(randImNum, length(xdata));
    for l = 1:randImNum
        xc = random('Uniform', xMin, xMax, size(xy_im));
        yc = random('Uniform', yMin, yMax, size(xy_im));
        angle = random('Uniform', 0, 2*pi, size(xy_im));
        
        [p_rand, v_rand] = arrayfun(@move_and_rotate, xy_im, xc, yc, angle, ...
            'UniformOutput', false);
        
        % Unite points and vectors of all fibers
        p_rand = [p_rand{:}];
        v_rand = [v_rand{:}];
        
        % Periodic boundary conditions
        p_rand(1,:) = mod(p_rand(1,:)-xMin, xMax-xMin) + xMin;
        p_rand(2,:) = mod(p_rand(2,:)-yMin, yMax-yMin) + yMin;
        
        [~, S_rand(l,:)] = algorithm.OP2D(p_rand, v_rand, ...
            xMin, yMin, gridStep, procStepNum, numCellX, numCellY, isCircleArea);
    end
    % Average S_rand
    S_rand = mean(S_rand);
    
    % Plot the graph in a new figure
    if ~noFig
        figure('NumberTitle', 'off', 'Name', ['OP2D ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
        plot(xdata, S_im, '.', xdata, S_rand, '.');
        legend('S_{im}', 'S_{rand}');
        
        % Fit data
        if isFitData
            fun = @(x) sum((S_im - (1-x(1)).*S_rand - x(1).*((1-x(2)).*exp(-xdata./(2.*x(3)))+x(2))).^2);
            [res, ~, exfl] = fminsearch(fun, [0.6, 0.1, 100]);
            if exfl == 1
                fit_y = (1-res(1)).*S_rand + res(1).*((1-res(2)).*exp(-xdata./(2.*res(3)))+res(2));
                plot(xdata, S_im, '.', xdata, S_rand, '.', [0, xdata], [1, fit_y]);
                legend('S_{im}', 'S_{rand}', 'Fit', 'Location', 'North');
                text('Units', 'normalized', 'Position', [0.7 0.9], ...
                    'BackgroundColor', [1 1 1], ...
                    'String', {
                    ['a = ' num2str(res(1), '%.3f')];
                    ['b = ' num2str(res(2), '%.3f')];
                    ['\lambda = ' num2str(res(3), '%.2f') ' nm']});
            else
                text('Units', 'normalized', 'Position', [0.7 0.9], ...
                    'BackgroundColor', [1 1 1], ...
                    'String', 'Fit did not converge');
                legend('Location', 'North');
            end
        end
        
        xlabel('Box size, d (nm)');
        ylabel('Order parameter 2D, S_{2D}');
        title(dev.AFM(i).fibPath(1:end-4), 'Interpreter', 'none');
    end
    
    % Save results to a text file
    if toSave
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['OP2D_' dev.AFM(i).fibPath(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\t%s\r\n', ...
                'Box size, d', 'Image OP, S_{im}', 'Random OP, S_{rand}');	% Long name
            fprintf(fileID, '%s\t%s\t%s\r\n', 'nm', '', '');                % Units
            fprintf(fileID, '%s\t%s\t%s\r\n', '', '', '');                  % Comments
            fprintf(fileID, '%g\t%f\t%f\r\n', [xdata; S_im; S_rand]);       % Data
            
            fclose(fileID);
        end
    end
    dev.AFM(i).xS = xdata;
    dev.AFM(i).S_im = S_im;
    dev.AFM(i).S_rand = S_rand;
    dev.AFM(i).S_align = S_im - S_rand;
    dev.AFM(i).fibLengthDensity = fibLengthDensity;
    
end

expt.dev(devNum) = dev;


end

function p = get_points_in_range(xy, xMin, xMax, yMin, yMax)
ind = diff([0, xMin <= xy(1,:) & xy(1,:) <= xMax & yMin <= xy(2,:) & xy(2,:) <= yMax, 0]);
in = find(ind == 1);
out = find(ind == -1);
p = cell(1, length(in));
for l = 1:length(in)
    p{l} = xy(:, in(l):out(l)-1);
end

end


function p = get_points(xy)
p = xy(:,1:end-1);

end

function v = get_vectors(xy)
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2));
v = v./[l; l];

end

function [p_rand, v_rand] = move_and_rotate(xy, xc, yc, angle)
xy = xy{1};

% Center at (0; 0)
xy = bsxfun(@minus, xy, xy(:,1));

% Move to (xc; yc) and turn by angle
p_rand = [xc + xy(1,:).*cos(angle) - xy(2,:).*sin(angle);
    yc + xy(1,:).*sin(angle) + xy(2,:).*cos(angle)];

% Get vectors and points
v_rand = diff(xy, 1, 2);
l = sqrt(sum(v_rand.^2));
v_rand = v_rand./[l; l];

p_rand = p_rand(:,1:end-1);

end

