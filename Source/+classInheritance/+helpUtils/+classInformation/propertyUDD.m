classdef propertyUDD < classInheritance.helpUtils.classInformation.simpleElement
    properties (SetAccess=private, GetAccess=private)
        classWrapper;
    end    

    methods
        function ci = propertyUDD(classWrapper, classPath, propertyName, packageName)
            ci = ci@classInheritance.helpUtils.classInformation.simpleElement(classWrapper.className, propertyName, classPath, 'properties', packageName);
            ci.classWrapper = classWrapper;
        end

        function [helpText, superClassInfo] = getSuperHelp(ci)
            helpText = ci.localHelp;
            if ci.foundElement
                superClassInfo = ci;
            else
                [helpText, superClassInfo] = ci.classWrapper.getSuperPropertyHelp(ci.element);
            end
        end
    end

    methods (Access=protected)
        function [helpText, needsHotlinking] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            needsHotlinking = true;
            helpText = ci.localHelp;
            if ~ci.foundElement
                [helpText, superClassInfo] = ci.classWrapper.getSuperPropertyHelp(ci.element);
                ci.definition = superClassInfo.definition;
                ci.superWrapper = superClassInfo.classWrapper;
            end
        end

        function allElementHelps = getAllElementHelps(~, classFile)
            allElementHelps = regexp(classFile, '^(?<help>[ \t]*+%.*+\n)*.*\<schema\.prop[ \t]*\([^,]*,[ \t]*''(?<element>\w++)''', 'names', 'dotexceptnewline', 'lineanchors');
        end        
    end
    
    methods (Static, Access=protected)
        function [helpText, prependName] = extractHelpText(elementHelp)
            prependName = true;
            helpText = elementHelp.help;
        end
    end
    
    methods (Access=private)
        function helpText = localHelp(ci)
            classFileName = regexprep(ci.whichTopic, '\w*.m$', 'schema.m');
            helpText = getElementHelp(ci, classFileName);
        end
    end
end

%   Copyright 2007-2012 The MathWorks, Inc.
