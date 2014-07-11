classdef superUDD < helpUtils.classWrapper.UDD & helpUtils.classWrapper.super
    methods
        function cw = superUDD(schemaClass, subClassPath, subClassPackageName)
            cw.subClassPackageName = subClassPackageName;
            cw.subClassPath = subClassPath;
            cw.schemaClass = schemaClass;
            cw.className = schemaClass.Name;
            cw.packageName = schemaClass.Package.Name;
            allPackageDirs = helpUtils.hashedDirInfo(['@' cw.packageName]);
            packagePaths = {allPackageDirs.path};
            cw.classPaths = strcat(packagePaths, ['/@' cw.className]);
        end
        
        function classInfo = getElement(cw, elementName, justChecking)
            if strcmpi(cw.className, elementName)
                classInfo = cw.getSuperElement(elementName);
            else
                classInfo = cw.getElement@helpUtils.classWrapper.UDD(elementName, justChecking);
            end
        end
        
        function b = hasClassHelp(cw)
            classInfo = cw.getClassHelpFile;
            if isempty(classInfo)
                b = false;
            else
                b = classInfo.checkHelp;
            end
        end

        function classInfo = getSimpleElementHelpFile(cw)
            classInfo = cw.getFileMethod('schema');
        end
    end
    
    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, ~)
            classInfo = cw.getSuperElement(elementName);
        end

        function b = isConstructor(~, ~)
            b = false;
        end

        function classInfo = getClassHelpFile(cw)
            classInfo = cw.getFileMethod(cw.className);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.10 $  $Date: 2012/09/05 07:24:28 $
