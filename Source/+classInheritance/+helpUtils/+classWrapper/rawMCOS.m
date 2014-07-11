classdef rawMCOS < helpUtils.classWrapper.MCOS & helpUtils.classWrapper.raw
    properties (SetAccess=private, GetAccess=private)
        packageName = '';
    end

    methods
        function cw = rawMCOS(className, packagePath, packageName, classHasNoAtDir, isUnspecifiedConstructor)
            packagedName = helpUtils.makePackagedName(packageName, className);
            if classHasNoAtDir
                classDir = packagePath;
            else
                classDir = fullfile(packagePath, ['@', className]);
            end
            cw = cw@helpUtils.classWrapper.MCOS(packagedName, className, classDir);
            cw.classHasNoAtDir = classHasNoAtDir;
            cw.isUnspecifiedConstructor = isUnspecifiedConstructor;
            cw.packageName = packageName;
            cw.subClassPath = classDir;
            cw.subClassPackageName = cw.packageName;
            cw.subClassName = cw.className;
        end

        function classInfo = getConstructor(cw, justChecking)
            if cw.isUnspecifiedConstructor
                classInfo = helpUtils.classInformation.fullConstructor(cw, cw.packageName, cw.className, cw.subClassPath, cw.classHasNoAtDir, true, justChecking);
            else
                classInfo = helpUtils.classInformation.localConstructor(cw.packageName, cw.className, cw.subClassPath, justChecking);
            end
        end

        function classInfo = getElement(cw, elementName, justChecking)
            if cw.classHasNoAtDir
                classInfo = cw.getLocalElement(elementName, justChecking);
            else
                classInfo = cw.getElement@helpUtils.classWrapper.MCOS(elementName, justChecking);
            end
            if ~isempty(classInfo)
                classInfo.setAccessible;
            end
        end
        
        function classInfo = getMethod(cw, classMethod)
            cw.loadClass;
            elementName = classMethod.Name;

            classInfo = cw.getFileMethod(elementName);
            if isempty(classInfo)
                classInfo = cw.innerGetMethod(classMethod);
            else
                cw.setAccessibleMethod(classInfo, classMethod);
            end
        end

        function classInfo = getSimpleElement(cw, classElement, elementKeyword, justChecking)
            cw.loadClass;

            if strcmp(elementKeyword, 'enumeration')
                definingClass = cw.metaClass;
            else
                definingClass = classElement.DefiningClass;
            end
            if definingClass == cw.metaClass || justChecking
                classInfo = helpUtils.classInformation.simpleMCOSElement(cw.className, classElement, cw.subClassPath, elementKeyword, cw.subClassPackageName);
            else
                definingClassWrapper = helpUtils.classWrapper.superMCOS(definingClass, cw.subClassPath, cw.subClassName, cw.subClassPackageName);
                classInfo = definingClassWrapper.getSimpleElement(classElement, elementKeyword);
                classInfo.className = cw.className;
                classInfo.superWrapper = definingClassWrapper;
            end
            classInfo.isAccessible = ~cw.metaClass.Hidden && classInfo.isAccessibleElement(classElement);
            if strcmp(elementKeyword, 'properties')
                classInfo.setStatic(classElement.Constant);
            end
        end
    end

    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, justChecking)
            classInfo = [];
            cw.loadClass;
            if ~isempty(cw.metaClass)
                classMethod = helpUtils.getMethod(cw.metaClass, elementName);

                if ~isempty(classMethod)
                    classInfo = cw.innerGetMethod(classMethod);
                else
                    [classElement, elementKeyword] = helpUtils.getSimpleElement(cw.metaClass, elementName);

                    if ~isempty(classElement)
                        classInfo = cw.getSimpleElement(classElement, elementKeyword, justChecking);
                    end
                end
            end
        end
    end

    methods (Access=private)
        function classInfo = innerGetMethod(cw, classMethod)
            elementName = classMethod.Name;
            definingClass = classMethod.DefiningClass;
            if definingClass == cw.metaClass
                classInfo = innerGetLocalMethod(cw, elementName, classMethod.Abstract, classMethod.Static);
            else
                classInfo = cw.getSuperClassInfo(definingClass, classMethod.Abstract, classMethod.Static, elementName);
            end
            if ~isempty(classInfo)
                cw.setAccessibleMethod(classInfo, classMethod);
            end
        end

        function setAccessibleMethod(cw, classInfo, classMethod)
            classInfo.isAccessible = ~cw.metaClass.Hidden && helpUtils.isAccessible(classMethod, 'methods');
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.16 $  $Date: 2012/11/15 13:56:25 $
