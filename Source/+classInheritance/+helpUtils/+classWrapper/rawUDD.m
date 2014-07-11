classdef rawUDD < classInheritance.helpUtils.classWrapper.UDD & classInheritance.helpUtils.classWrapper.raw
    methods
        function cw = rawUDD(className, packagePath, packageHandle, isUnspecifiedConstructor)
            cw.isUnspecifiedConstructor = isUnspecifiedConstructor;
            cw.className = className;
            cw.packageName = packageHandle.Name;
            cw.subClassPath = fullfile(packagePath, ['@', className]);
            cw.classPaths = {cw.subClassPath};
            cw.subClassPackageName = cw.packageName;
            try
                cw.schemaClass = packageHandle.findclass(cw.className);
            catch e %#ok<NASGU>
                % probably an error parsing the class file
            end
        end

        function classInfo = getConstructor(cw, ~)
            classInfo = classInheritance.helpUtils.classInformation.fullConstructor(cw, cw.packageName, cw.className, cw.subClassPath, false, cw.isUnspecifiedConstructor, true);
        end
    end
    
    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, justChecking)
            classInfo = [];
            classMethods = methods([cw.packageName '.' cw.className]);
            methodIndex = strcmpi(classMethods, elementName);
            if any(methodIndex)
                elementName = classMethods{methodIndex};
                if justChecking
                    classInfo = classInheritance.helpUtils.classInformation.fileMethod(cw, cw.className, cw.subClassPath, cw.subClassPath, elementName, cw.subClassPackageName);
                else
                    classInfo = cw.getSuperElement(elementName);
                    if ~isempty(classInfo)
                        classInfo.className = cw.className;
                    end
                end
            elseif ~isempty(cw.schemaClass)
                for classProperty = cw.schemaClass.Properties'
                    if strcmpi(classProperty.Name, elementName)
                        if strcmp(classProperty.Visible, 'on')
                            if strcmp(classProperty.AccessFlags.PublicSet, 'on') || strcmp(classProperty.AccessFlags.PublicGet, 'on')
                                classInfo = classInheritance.helpUtils.classInformation.propertyUDD(cw, cw.subClassPath, classProperty.Name, cw.subClassPackageName);
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $  $Date: 2012/09/05 07:24:25 $
