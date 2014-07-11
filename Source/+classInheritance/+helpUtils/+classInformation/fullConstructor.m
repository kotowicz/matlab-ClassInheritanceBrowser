classdef fullConstructor < classInheritance.helpUtils.classInformation.fileConstructor
    properties (SetAccess=private, GetAccess=private)
        isUnspecified = false;
    end

    methods
        function ci = fullConstructor(classWrapper, packageName, className, basePath, noAtDir, isUnspecified, justChecking)
            fullPath = fullfile(basePath, [className '.m']);
            if ~exist(fullPath, 'file')
                fullPath(end) = 'p';
            end
            ci@classInheritance.helpUtils.classInformation.fileConstructor(packageName, className, basePath, fullPath, noAtDir, justChecking);
            ci.classWrapper = classWrapper;
            ci.isUnspecified = isUnspecified;
        end

        function b = isClass(ci)
            if ci.noAtDir
                b = ci.isMCOSClass;
            else
                b = ci.isUnspecified;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $  $Date: 2011/02/15 00:53:42 $
