function [classElement, elementKeyword] = getSimpleElement(metaClass, elementName)
    for elementType = helpUtils.getSimpleElementTypes
        elementKeyword = elementType.keyword;
        classElement = filterElement(metaClass, elementType.list, elementName);
        if ~isempty(classElement)
            break;
        end
    end
end

function classElement = filterElement(metaClass, elementType, elementName)
    classElement = [];
    elementList = metaClass.(elementType);
    if ~isempty(elementList)
        % remove elements that do not match elementName
        elementList(~strcmpi({elementList.Name}, elementName)) = [];
        if ~isempty(elementList)
            % just in case this filtered down to more that one
            classElement = elementList(1);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2012/09/05 07:24:06 $
