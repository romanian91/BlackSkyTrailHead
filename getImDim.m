function imDim = getImDim(imName)

% Comb the Ocular_Ascension repo to find the dimension of the image I took
% with the name "imName" lol so easy right
OA = '/Users/Imperssonator/Documents/MATLAB/Ocular_Ascension/';
imDir = dir(OA);
disp(imName)

for i = 1:length(imDir)
    if ~imDir(i).isdir
        fid = fopen([OA, imDir(i).name]);
        mdCell = textscan(fid,'%s');
        mdCell = mdCell{1};
        fclose(fid);
        for j = 1:length(mdCell)
            if strcmp(imName,mdCell{j})
                for k = j:length(mdCell)
                    if strcmp('um',mdCell{k})
                        imDim = mdCell{k-1};
                        return
                    end
                end
            end
        end
    end
end

end