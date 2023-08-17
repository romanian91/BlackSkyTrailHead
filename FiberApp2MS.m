function msPath = FiberApp2MS(fibPath)

load(fibPath)
XY = imageData.xy;
NumFibs = length(XY);
MSA = zeros(imageData.sizeY,imageData.sizeX);   % MS with angles
MSB = zeros(imageData.sizeY,imageData.sizeX);   % MS binary
BW = MSB;

disp(NumFibs)
for f = 1:NumFibs
    disp(f)
    xyf = XY{f};    % Pull out the xy coordinates of segment ends for this fiber
    for s = 1:size(xyf,2)-1
        SegEnds = xyf(:,s:s+1); % pull out the xy coordinates of each individual segment
        vect = get_vectors(SegEnds);
        vect(:, vect(2,:)>0) = - vect(:, vect(2,:)>0); % Turn the coordinate system from informatics into geometrical 
        SegAngle = acos(vect(1,:))*180/pi;
        LineVec = reshape(SegEnds,1,4); % necessary format for insertShape
        MSBadd = ~~rgb2gray(insertShape(BW,...
            'line', LineVec,...
            'Color',[255 255 255],...
            'SmoothEdges', true));    % Make a 512x512 black/white with just that segment as 1's
        MSBadd = ~MSB.*MSBadd;  % Only add pixels that are not currently in the structure
        MSAadd = SegAngle.*double(MSBadd);
        MSA = MSA+MSAadd;
        MSB = MSB+MSBadd;
    end
end

% AngleColorMapInt(MSA,MSB);
msPath = [fibPath(1:end-7), 'ms.mat'];
save([fibPath(1:end-7), 'ms.mat'],'MSA','MSB')

end

function [] = AngleColorMapInt(AngMap,BW)

figure
AngMapNaN = AngMap;
AngMapNaN(~BW)=NaN;
AngMapNaN(1,1) = 180; AngMapNaN(end,end) = -180;        % enforce the lower and upper bounds of the color map
pcolor(AngMapNaN); shading flat; axis equal; set(gca,'YDir','reverse');
hmap = [(0:256)'/256; (0:256)'/256];
hmap(:,[2 3]) = 0.7; %brightness
huemap = hsv2rgb(hmap);
colormap(huemap);

end

function v = get_vectors(xy)
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2));
v = v./[l; l];

end