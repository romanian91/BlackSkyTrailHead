function [XU, YA, YE] = raw2err(X,Y)

%Raw to Error
% This function converts a data series X and Y into their average values at
% XA, YA, and associated error values YE...

[XU, UI, UR] = unique(X);
YA = zeros(length(XU),1);
YE = zeros(length(XU),1);

for i = 1:length(XU)
    YA(i) = mean(Y(UR==i));
    YE(i) = std(Y(UR==i))/sqrt(length(Y(UR==i)));
end

end