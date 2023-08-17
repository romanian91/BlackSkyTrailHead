function finalImg = AngleColorFig(fibPath)

addpath('Functions')

fiberBlue = FiberPlot(fibPath);
% 
fiberGray = imcomplement(rgb2gray(fiberBlue));
% 
fiberBW = im2bw(fiberGray,0);
% 
ACM = getAngles(fibPath,fiberBW,fiberGray);
% 
finalImg = double(ones(size(fiberBlue)));
% load('ACMtest')
colorVal = 0.88;

save('ACMtest')

for i = 1:size(finalImg,1)
    for j = 1:size(finalImg,2)
        if fiberBW(i,j) == 1
            trans = double(fiberGray(i,j))/255;
            finalImg(i,j,:) = hsv2rgb([ACM(i,j)/180,trans,1-trans*(1-colorVal)]);
        end
    end
end


imtool(finalImg)
imwrite(finalImg,['/Users/Imperssonator/Documents/GA Tech/Research/Papers/Quantification of P3HT Microstructure/Workflow/', fibPath(findLastSlash(fibPath)+1:end-7), 'ACM.tif']);

end

function ACM = getAngles(fibPath,fbw,fg)

load(fibPath)

load(fibPath)
XY = imageData.xy;
NumFibs = length(XY);
h = imageData.sizeY;
w = imageData.sizeX;
MSA = zeros(imageData.sizeY,imageData.sizeX);   % MS with angles
MSB = logical(zeros(imageData.sizeY,imageData.sizeX));   % MS binary
MSC = zeros(imageData.sizeY,imageData.sizeX,3);
Blank = MSC;
whos Blank
colorVal = 0.85;

disp(NumFibs)

for f = 1:NumFibs
    disp(f)
    xyf = XY{f};    % Pull out the xy coordinates of segment ends for this fiber
    for s = 1:size(xyf,2)-1
        SegEnds = xyf(:,s:s+1); % pull out the xy coordinates of each individual segment
        vect = get_vectors(SegEnds);
        vect(:, vect(2,:)>0) = - vect(:, vect(2,:)>0); % Turn the coordinate system from informatics into geometrical 
        SegAngle = acosd(vect(1,:));    % return angle in degrees between 0 and 180
        LineVec = reshape(SegEnds,1,4); % necessary format for insertShape
        MSCadd = insertShape(Blank,...
            'Line', LineVec,...
            'Color',hsv2rgb([SegAngle/180 1 colorVal]));    % Make a 512x512x3 colored image of this segment
        MSBadd = im2bw(MSCadd,0);
        MSBadd = ~MSB.*MSBadd;  % Only add pixels that are not currently in the structure
        MSCadd = repmat(~MSB,1,1,3).*MSCadd;
        MSAadd = SegAngle.*double(MSBadd);
        MSA = MSA+MSAadd;   % Angle
        MSB = MSB+MSBadd;   % Binary
%         whos MSB
        MSC = MSC+MSCadd;   % Color
    end
end

% figure
% spy(MSB)
% figure
% spy(fbw)

MSC(MSC==0)=1;

initFill = fbw.*MSB;    % which anti-aliased pixels already have angle values
% whos initFill
initMiss = fbw~=MSB;    % which anti-aliased pixels are missing angle values
initMiss(fbw==0)=0;
% whos initMiss
[Im, Jm] = find(initMiss);
[Ib, Jb] = find(MSB);
numMiss = length(Im)
numB = length(Ib)
% figure
% spy(initMiss)

ACM=MSA;                % initialize angles with MSA

[I,J] = find(initMiss(:));    % get linear inidices of missing angles

% Now, for each missing angle pixel, find its nearest filled neighbors and
% take the value from the closest one.

% s = 4;
disp('making ipdm')
[X,Y] = meshgrid((1:h),(1:w));
ipdm = zeros(numMiss,numB);
for i = 1:numMiss
    for j = 1:numB
        ipdm(i,j) = (X(Im(i),Jm(i))-X(Ib(j),Jb(j)))^2 ...
        + (Y(Im(i),Jm(i))-Y(Ib(j),Jb(j)))^2;
    end
end

disp('filling angles')
for i = 1:numMiss
    [trash, closeB] = min(ipdm(i,:));
    ACM(Im(i),Jm(i)) = ACM(Ib(closeB),Jb(closeB));
end
% 
% for p = 1:length(I)
%     i = I(p);
%     j = J(p);
%     Box = ones(s*2+1);
%     Box(s+1,s+1) = 0;
%     Match = Box.*MSB(i-s:i+s,j-s:j+s);
%     MatchDist = Match.*Dist2;
%     MatchDist(MatchDist==0)=Inf;
%     [trash, ind] = min(MatchDist(:));
%     ACM(i,j) = ACM(i+X(ind),j+Y(ind));
% end

end

function v = get_vectors(xy)
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2));
v = v./[l; l];

end