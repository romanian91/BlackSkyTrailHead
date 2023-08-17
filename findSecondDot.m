function out = findSecondDot(FilePath)

DotInd = regexp(FilePath,'[\.]');
if numel(DotInd)>1
    out = DotInd(2);
else
    out = DotInd(1);
end

end