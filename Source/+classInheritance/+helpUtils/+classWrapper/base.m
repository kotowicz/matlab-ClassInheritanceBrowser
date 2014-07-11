classdef base < handle
    properties (SetAccess=protected, GetAccess=public)
        className = '';
    end
    
    properties (SetAccess=protected, GetAccess=protected)
        classPaths = {};
        subClassName = '';
        subClassPath = '';
        subClassPackageName = '';
    end
    
    methods (Abstract, Access=protected)
        classInfo = getLocalElement(cw, elementName, justChecking);
    end
    
    
    methods
        function classInfo = getClassInformation(cw, elementName, justChecking)
            if cw.isConstructor(elementName)
                classInfo = cw.getConstructor(justChecking);
            else
                classInfo = cw.getElement(elementName, justChecking);
            end
        end

        function classInfo = getElement(cw, elementName, justChecking)
            classInfo = cw.getFileMethod(elementName);
            if isempty(classInfo)
                classInfo = cw.getLocalElement(elementName, justChecking);
            end
        end
        
        function [helpText, needsHotlinking, shadowedClassInfo, shadowedWrapper] = getShadowedHelp(~, ~, ~)
            helpText = '';
            needsHotlinking = false;
            shadowedClassInfo = [];
            shadowedWrapper = [];
        end
        
        function helpText = getElementDescription(~, ~)
            helpText = '';
        end
    end

    methods (Access=protected)
        function classInfo = getFileMethod(cw, methodName)
            classInfo = [];
            for j=1:length(cw.classPaths)
                allClassInfo = classInheritance.helpUtils.hashedDirInfo(cw.classPaths{j});
                if isempty(allClassInfo)
                    cw.classPaths{j} = fileparts(cw.classPaths{j});
                else
                    for i = 1:length(allClassInfo)
                        classDirInfo = allClassInfo(i);
                        [fixedName, foundTarget] = classInheritance.helpUtils.extractFile(classDirInfo, methodName);
                        if foundTarget
                            classInfo = classInheritance.helpUtils.classInformation.fileMethod(cw, cw.className, classDirInfo.path, cw.subClassPath, fixedName, cw.subClassPackageName);
                            return;
                        end
                    end
                end
            end
        end
        
        function b = isConstructor(cw, methodName)
            b = strcmpi(cw.className, methodName);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.11 $  $Date: 2012/09/05 07:24:22 $
