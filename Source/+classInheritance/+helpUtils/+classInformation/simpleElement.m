classdef simpleElement < classInheritance.helpUtils.classInformation.classElement
    properties (SetAccess=private, GetAccess=protected)
        foundElement = false;
        elementKeyword;
    end

    methods
        function ci = simpleElement(className, elementName, classPath, elementKeyword, packageName)
            definition = fullfile(classPath, [className filemarker elementName]);
            whichTopic = fullfile(classPath, [className '.m']);
            ci@classInheritance.helpUtils.classInformation.classElement(packageName, className, elementName, definition, definition, whichTopic)
            ci.elementKeyword = elementKeyword;
            ci.isSimpleElement = true;
        end

        function topic = fullTopic(ci)
            %topic = [classInheritance.helpUtils.makePackagedName(ci.packageName, ci.className), '/', ci.element];
            topic = [classInheritance.helpUtils.makePackagedName(ci.packageName, ci.className), ci.separator, ci.element];
        end
    end
    
    methods (Access=protected)
        function helpText = getElementHelp(ci, helpFile)
            helpText = classInheritance.helpUtils.callHelpFunction(@ci.getHelpTextFromFile, helpFile);
        end
    end
    
    methods (Access=private)
        function helpText = getHelpTextFromFile(ci, fullPath)
            helpText = '';
            if ~ci.foundElement
                classFile = fileread(fullPath);
                allElementHelps = ci.getAllElementHelps(classFile);
                allElementHelps(~strcmp(ci.element, {allElementHelps.element})) = [];
                for elementHelp = allElementHelps
                    ci.foundElement = true;
                    [helpText, prependName] = ci.extractHelpText(elementHelp);
                    if ~isempty(helpText)
                        helpText = regexprep(helpText, '^\s*%', ' ', 'lineanchors');
                        helpText = regexprep(helpText, '\r', '');
                        if prependName
                            helpText = [' ' ci.element ' -' helpText]; %#ok<AGROW>
                        end
                        return;
                    end
                end
            end
        end
    end
    
    methods (Abstract, Access=protected)
        allElementHelps = getAllElementHelps(ci, classFile)        
    end

    methods (Static, Abstract, Access=protected)
        [helpText, prependName] = extractHelpText(elementHelp)
    end
end

%   Copyright 2012 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2012/11/15 13:56:24 $
