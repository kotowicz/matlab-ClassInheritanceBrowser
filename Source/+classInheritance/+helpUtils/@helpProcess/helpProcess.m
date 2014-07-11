classdef helpProcess < handle
    properties (SetAccess=private, GetAccess=public)
        helpStr = '';
        docTopic = '';
    end

    properties (SetAccess=private, GetAccess=private)
        suppressDisplay = false;
        wantHyperlinks = false;
        commandIsHelp = true;

        command = '';
        topic = '';
        fullTopic = '';

        isDir = false;
        isContents = false;
        isOperator = false;
        needsHotlinking = false;
        objectSystemName = '';
        isMCOSClass = false;
    end

    methods
        function hp = helpProcess(nlhs, nrhs, prhs)
            hp.suppressDisplay = (nlhs ~= 0);
            if ~hp.suppressDisplay
                hp.wantHyperlinks = feature('hotlinks');
                if hp.wantHyperlinks
                    hp.command = 'help';
                end
            end

            commandSpecified = false;
            topicSpecified = false;

            for i = 1:nrhs
                arg = prhs{i};
                switch arg
                case {'-help', '-helpwin', '-doc', '-helpPopup'}
                    if commandSpecified
                        hp.suppressDisplay = true;
                        throwAsCaller(MException('MATLAB:help:TooManyCommands','%s', getString(message('MATLAB:help:TooManyCommands'))));
                    end
                    hp.command = arg(2:end);
                    hp.commandIsHelp = strcmp(hp.command, 'help');
                    hp.wantHyperlinks = true;
                    commandSpecified = true;
                otherwise
                    if topicSpecified
                        hp.suppressDisplay = true;
                        throwAsCaller(MException('MATLAB:help:TooManyInputs','%s', getString(message('MATLAB:help:TooManyInputs'))));
                    end
                    hp.topic = arg;
                    topicSpecified = true;
                end
            end
            
            % enable the directory hashtable
            classInheritance.helpUtils.hashedDirInfo(true);
        end

        getHelpText(hp);
        prepareHelpForDisplay(hp);

        function delete(hp)
            % disable the directory hashtable
            classInheritance.helpUtils.hashedDirInfo(false);

            hp.displayHelp;
        end
    end

    methods (Access=private)
        hotlinkHelp(hp);
        getTopicHelpText(hp);
        getDocTopic(hp);
        demoTopic = getDemoTopic(hp);
        addMoreInfo(hp, infoStr, infoCommand, infoArg);
        displayHelp(hp);
        [qualifyingPath, pathItem] = getPathItem(hp);
        extractFromClassInfo(hp, classInfo);
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2011/08/13 17:29:50 $
