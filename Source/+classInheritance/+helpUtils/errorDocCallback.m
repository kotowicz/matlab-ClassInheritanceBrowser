function errorDocCallback(topic, fileName, lineNumber)
    if ~isempty(help(topic))
        helpPopup(topic);
    else
        functionName = topic;
        split = regexp(functionName, filemarker, 'split', 'once');
        hasFileMarker = numel(split) > 1;
        if hasFileMarker
            functionName = split{1};
            if ~isempty(help(functionName))
                helpPopup(functionName);
                return;
            end
        end
        className = regexp(functionName, '.*?(?=/[\w.]*$|\.\w+$)', 'match', 'once');
        if ~isempty(meta.class.fromName(className)) && ~isempty(help(className))
            helpPopup(className);
        else
            editTopic = topic;
            if ~hasFileMarker && isempty(className)
                editTopic = [topic, filemarker, topic];
            end
            if ~edit(editTopic)
                if nargin == 3 && ~isempty(fileName)
                    opentoline(fileName, lineNumber, 0);
                else
                    helpdlg(getString(message('MATLAB:classInheritance.helpUtils.errorDocCallback:Undocumented', topic)), getString(message('MATLAB:classInheritance.helpUtils.errorDocCallback:UndocumentedTitle')));
                end
            end
        end
    end
end

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2011/10/22 22:03:55 $
