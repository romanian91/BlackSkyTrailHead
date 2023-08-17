function expt = runAFM(expt,parentDir)

%Run AFM
% For each device, and each image of that device, create a .tif, and
% put the relevant params into exp.AFM 

AFMFolder = [parentDir, expt.name, '/AFM/Phase/'];
expt.AFMFolder = AFMFolder;
imDir = compileImgs(AFMFolder);
% imDir is structure with fields:
%  name (file string)
%  imName (string of name without extension)
%  devName (string of the device the image was taken from)
%  path (full file path)
%  other stuff

% Put AFM raw image file details into exp struct
for i = 1:length(expt.dev)
    devName = expt.dev(i).devName;
    numDevImgs = 0;
    for j = 1:length(imDir)
        if strcmp(devName,imDir(j).devName)
            numDevImgs = numDevImgs+1;
            expt.dev(i).AFM(numDevImgs).imPath = imDir(j).path;
            expt.dev(i).AFM(numDevImgs).imName = imDir(j).imName;
            expt.dev(i).AFM(numDevImgs).imFile = imDir(j).name;
            expt.dev(i).AFM(numDevImgs).IMG = imread(imDir(j).path);
            expt.dev(i).AFM(numDevImgs).imDim = getImDim(imDir(j).imName);
            expt.dev(i).AFM(numDevImgs).tifPath = makeTif(imDir(j).path); % Make .tif image just cuz
            
            % Now check for existing FiberApp data and compile that stuff
            fibPath = [imDir(j).path(1:findLastDot(imDir(j).path)), 'fib.mat'];
            if exist(fibPath,'file')
                expt.dev(i).AFM(numDevImgs).fibPath = fibPath;
            end
        end
    end
    expt.dev(i).numImgs = numDevImgs;
    expt = getS2D(expt,i);
    expt = getFibLen(expt,i);
    expt = getCurvDist(expt,i);
    expt = get2DOP(expt,i);
end

end


function tifPath = makeTif(imPath)

lastDot = findLastDot(imPath);

tifPath = [imPath(1:lastDot), 'tif'];
IMG = imread(imPath);
imwrite(IMG,tifPath)

end

function out = compileImgs(FolderPath)
disp(FolderPath)

ad = pwd;

% First compile any images from the folderpath
cd(FolderPath)

PNG = dir('*.png');
JPG = dir('*.jpg');
JPEG = dir('*.jpeg');
CurIms = [PNG; JPG; JPEG]; % Generate directory structure of images in FolderPath
cd(ad)

for p = 1:length(CurIms)
    CurIms(p).path = [FolderPath CurIms(p).name];   % prepend the folder path to the image names
    CurIms(p).imName = CurIms(p).name(1:findSecondDot(CurIms(p).name)-1);  % find just the image name
    CurIms(p).devName = CurIms(p).name(1:findFirstDot(CurIms(p).name)-1);   % find just the name of the device
end
out = CurIms;

end