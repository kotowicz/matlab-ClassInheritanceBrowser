function fixedName = extractCaseCorrectedName(fullName, subName)
    fixedNames = regexpi(fullName, ['\<' regexprep(subName, '\W*', '\\W*') '\>'], 'match');
    if isempty(fixedNames)
        fixedName = '';
    else
        fixedName = strrep(fixedNames{end}, '\', '/');
        fixedName = regexprep(fixedName, '(^|/)[@+]?', '$1');
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2011/05/17 02:24:36 $
