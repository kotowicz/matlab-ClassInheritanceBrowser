function dirInfo = hashedDirInfo(dirPath)
    persistent seenDirs;
    persistent usingHash;
    
    if islogical(dirPath)
        seenDirs = [];
        usingHash = dirPath;
        return;
    end
    
    if usingHash
        dirPathAsField = ['x' regexprep(fliplr(dirPath), {'@','+','\W'}, {'AT','PLUS',''})];
        if length(dirPathAsField) > namelengthmax
            dirPathAsField = dirPathAsField(1:namelengthmax);
        end
        if isfield(seenDirs, dirPathAsField)
            dirInfo = seenDirs.(dirPathAsField);
        else 
            % Note: -caseinsensitive is an undocumented and unsupported feature
            dirInfo = what('-caseinsensitive', dirPath);
            try
                seenDirs.(dirPathAsField) = dirInfo;
            catch  %#ok<CTCH>
                usingHash = false;
            end
        end
    else
        dirInfo = what('-caseinsensitive', dirPath);
    end
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2011/02/15 00:53:41 $
