function out = findFirstDot(FilePath)

DotInd = regexp(FilePath,'[\.]');
out = DotInd(1);

end