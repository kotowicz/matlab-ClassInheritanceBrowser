function packageName = getPackageName(packagePath)
    packageList = regexp(packagePath, ['((^|[\\/])[@+]\w+)+(?=([\\/](\w+' filemarker '\w+|\w+(\.[mp])?))?$)'], 'match', 'once');
    packageList = regexp(packageList, '\w+', 'match');
    if isempty(packageList)
        packageName = '';
    elseif isscalar(packageList)
        packageName = packageList{1};
    else
        c2 = strcat(packageList(1:end-1),{'.'});
        packageName = [c2{:} packageList{end}];
    end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2010/08/23 23:10:15 $
