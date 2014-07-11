function displayHelp(hp)
    if ~hp.suppressDisplay
        if ~isempty(hp.helpStr)
            disp(hp.helpStr);
        else
            if ~isempty(hp.fullTopic)
                if ~isempty(hp.objectSystemName)
                    correctName = hp.objectSystemName;
                else
                    correctName = helpUtils.extractCaseCorrectedName(hp.fullTopic, hp.topic);
                    if isempty(correctName)
                        correctName = hp.topic;
                    elseif isempty(regexp(correctName, '\.\w+$', 'once'))
                        correctName = [correctName regexp(hp.fullTopic, '\.\w+$', 'match', 'once')];
                    end
                end
                disp(getString(message('MATLAB:helpUtils:displayHelp:NoHelpFound', correctName)));
            else
                unknownTopic = false;
                if ~isempty(hp.topic)
                    if ~helpUtils.isObjectDirectorySpecified(fileparts(hp.topic)) && ~isempty(helpUtils.hashedDirInfo(hp.topic))
                        disp(getString(message('MATLAB:helpUtils:displayHelp:NoHelpFound', hp.topic)));
                    else
                        disp(getString(message('MATLAB:helpUtils:displayHelp:TopicNotFound', hp.topic)));
                        unknownTopic = true;
                    end
                end
                if unknownTopic
                    if hp.wantHyperlinks
                        disp(getString(message('MATLAB:helpUtils:displayHelp:SearchMessageWithLinks', helpUtils.makeDualCommand('docsearch', hp.topic))));
                    else
                        disp(getString(message('MATLAB:helpUtils:displayHelp:SearchMessageNoLinks')));
                    end
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2011/08/13 17:29:49 $
