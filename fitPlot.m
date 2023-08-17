function [regX, regY] = fitPlot(X,Y)

[xm xn] = size(X);
if xm<xn
    X = X';
end

[ym yn] = size(Y);
if ym<yn
    Y = Y';
end

% Model Fit

c = 1;
for p = 1:3
    reg(c,p) = MultiPolyRegress(X,Y,p);
    loocv(c,p) = reg(c,p).CVMAE;
end

[minErr, minInd] = min(loocv(:));
bestFit = reg(minInd);

minX = min(X)-range(X)/10;
maxX = max(X)+range(X)/10;

regX = (minX:range(X)/100:maxX)';
B = bestFit.Coefficients;
PM = bestFit.PowerMatrix;

regY = zeros(size(regX));

for i = 1:length(B)
    regY = regY + regX.^(PM(i)).*B(i);
end

end