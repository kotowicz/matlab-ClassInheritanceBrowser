classdef simpleMCOSElement < helpUtils.classInformation.simpleElement
    properties (SetAccess=private, GetAccess=private)
        elementMeta;
    end    

    methods
        function ci = simpleMCOSElement(className, elementMeta, classPath, elementKeyword, packageName)
            ci = ci@helpUtils.classInformation.simpleElement(className, elementMeta.Name, classPath, elementKeyword, packageName);
            ci.elementMeta = elementMeta;
        end
        
        function b = isAccessibleElement(ci, classElement)
            b = helpUtils.isAccessible(classElement, ci.elementKeyword);
        end
        
        function [helpText, needsHotlinking] = getSecondaryHelp(ci, ~)
            helpText = ci.elementMeta.Description;
            needsHotlinking = true;
        end
    end

    methods (Access=protected)
        function [helpText, needsHotlinking] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            needsHotlinking = true;
            helpText = getElementHelp(ci, ci.whichTopic);
        end 

        function allElementHelps = getAllElementHelps(ci, classFile)
            elementSections = regexp(classFile, ['^\s*', ci.elementKeyword, '\>.*(?<inside>.*\n)*?^\s*end\>'], 'names', 'dotexceptnewline', 'lineanchors');
            % cast the input to regexp to char so empty will do the right thing
            allElementHelps = regexp(char([elementSections.inside]), '^(?<preHelp>[ \t]*+%.*+\n)*[ \t]*+(?<element>\w++)[^\n%]*+(?<postHelp>%.*+\n)?', 'names', 'dotexceptnewline', 'lineanchors');
        end
    end
    
    methods (Static, Access=protected)
        function [helpText, prependName] = extractHelpText(elementHelp)
            prependName = false;
            if ~isempty(elementHelp.preHelp)
                helpText = elementHelp.preHelp;
            else
                prependName = true;
                helpText = elementHelp.postHelp;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2012/09/05 07:24:19 $
