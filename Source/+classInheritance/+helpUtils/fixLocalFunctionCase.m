function [fname, hasLocalFunction, shouldLink, qualifyingPath, fullPath] = fixLocalFunctionCase(fname, helpPath)
    justChecking = nargin > 1;
    if ~justChecking
        helpPath = '';
    end
    
    hasLocalFunction = false;
    shouldLink = false;
    qualifyingPath = '';
    fullPath = '';
    split = regexp(fname, filemarker, 'split', 'once');
    if length(split) > 1
        hasLocalFunction = true;
        [fileName, qualifyingPath, fullPath, hasMFileForHelp] = classInheritance.helpUtils.fixFileNameCase(split{1}, helpPath);
        if ~hasMFileForHelp
            [~, fullPath] = classInheritance.helpUtils.splitClassInformation(fileName, helpPath, false);
            hasMFileForHelp = exist(fullPath, 'file') == 2;
        end
        if hasMFileForHelp
            [~, mainFunctionName] = fileparts(fullPath);
            try %#ok<TRYNC>
                % Note: -subfun is an undocumented and unsupported feature
                localFunctions = [{mainFunctionName}; which('-subfun', fullPath)];
                localFunctionIndex = strcmpi(localFunctions, split{2});
                if any(localFunctionIndex)
                    shouldLink = true;
                    if justChecking
                        fname = [fileName, filemarker, localFunctions{localFunctionIndex}];
                    else
                        fname = regexprep(fullPath, '\.[mp]$', [filemarker, localFunctions{localFunctionIndex}]);
                    end
                end
            end
            if ~shouldLink && classInheritance.helpUtils.isClassMFile(fullPath)
                fname = [fileName, filesep, split{2}];
                hasLocalFunction = false;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2012/09/05 07:24:05 $
