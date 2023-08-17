for i = 1:length(exp.DEV)
if ~isempty(exp.DEV(i).avgCurv)
plot(exp.DEV(i).process.AgeTime,exp.DEV(i).avgCurv,'ob')
end
end