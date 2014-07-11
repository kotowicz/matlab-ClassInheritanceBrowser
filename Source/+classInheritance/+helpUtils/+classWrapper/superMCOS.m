classdef superMCOS < classInheritance.helpUtils.classWrapper.MCOS & classInheritance.helpUtils.classWrapper.super
    properties (SetAccess=private, GetAccess=private)
        isAbstractMethod = false;
        isStaticMethod = false;
    end
    
    methods
        function cw = superMCOS(metaClass, subClassPath, subClassName, subClassPackageName, isAbstractMethod, isStaticMethod)
            packagedName = metaClass.Name;
            className = regexp(packagedName, '\w*$', 'match', 'once');
            classDir = which(packagedName);
            classDir = fileparts(classDir);
            if isempty(classDir)
                [~, classDir] = classInheritance.helpUtils.splitClassInformation(packagedName);
                if isempty(classDir)
                    classDir = '';
                else
                    classDir = fileparts(classDir);
                end
            end
            cw = cw@classInheritance.helpUtils.classWrapper.MCOS(packagedName, className, classDir);
            cw.metaClass = metaClass;
            if isempty(cw.classPaths)
                % classdef is not an M-file
                packageList = regexp(cw.packagedName, '\w+(?=\.)', 'match');
                if isempty(packageList)
                    allClassDirs = classInheritance.helpUtils.hashedDirInfo(['@' cw.className]);
                    cw.classPaths = {allClassDirs.path};
                else
                    topPackageDirs = classInheritance.helpUtils.hashedDirInfo(['+' packageList{1}]);
                    packagePaths = {topPackageDirs.path};
                    if ~isscalar(packageList)
                        subpackages = sprintf('/+%s', packageList{2:end});
                        packagePaths = strcat(packagePaths, subpackages);
                    end
                    cw.classPaths = strcat(packagePaths, ['/@' cw.className]);
                end
            end
            cw.subClassPath = subClassPath;
            cw.subClassName = subClassName;
            cw.subClassPackageName = subClassPackageName;
            if nargin > 4
                cw.isAbstractMethod = isAbstractMethod;
                if nargin > 5
                    cw.isStaticMethod = isStaticMethod;
                end
            end
        end

        function classInfo = getSimpleElement(cw, classElement, elementKeyword)
            classdefInfo = cw.getSimpleElementHelpFile;
            classInfo = classInheritance.helpUtils.classInformation.simpleMCOSElement(cw.className, classElement, fileparts(classdefInfo.definition), elementKeyword, cw.subClassPackageName);
        end

        function b = hasClassHelp(cw)
            if cw.metaClass.Hidden
                b = false;
            elseif strcmp(cw.className, 'handle')
                b = true;
            else
                classInfo = cw.getClassHelpFile;
                b = classInfo.hasHelp;
            end
        end

        function classInfo = getSimpleElementHelpFile(cw)
            classInfo = cw.getClassHelpFile;
        end
    end
    
    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, ~)
            classInfo = cw.innerGetLocalMethod(elementName, cw.isAbstractMethod, cw.isStaticMethod);
        end

        function b = isConstructor(~, ~) 
            b = false;
        end

        function classInfo = getClassHelpFile(cw)
            classInfo = classInheritance.helpUtils.classInformation.simpleMCOSConstructor(cw.className, fullfile(cw.classDir, [cw.className '.m']), false);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.16 $  $Date: 2012/09/05 07:24:27 $
