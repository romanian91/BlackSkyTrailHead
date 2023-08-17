function tifPath = makeTif(imPath)

lastDot = findLastDot(imPath);

tifPath = [imPath(1:lastDot), 'tif'];
IMG = imread(imPath);
imwrite(IMG,tifPath)

end