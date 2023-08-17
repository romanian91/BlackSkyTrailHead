function out = findLastSlash(FilePath)

SlashInd = regexp(FilePath,'[\\/]');
out = SlashInd(end);

end