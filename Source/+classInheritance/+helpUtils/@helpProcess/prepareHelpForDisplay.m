function prepareHelpForDisplay(hp)
    if ~isempty(hp.helpStr)
        if hp.wantHyperlinks && hp.needsHotlinking
            % Make "see also", "overloaded methods", etc. hyperlinks.
            hp.hotlinkHelp;
        end

        hp.getDocTopic;
        if ~isempty(hp.docTopic) && hp.commandIsHelp
            hp.addMoreInfo(getString(message('MATLAB:helpUtils:displayHelp:ReferencePageInHelpBrowser')), 'doc', hp.docTopic);
        end

        if ~hp.isDir
            demoTopic = hp.getDemoTopic;
            if ~isempty(demoTopic)
                hp.addMoreInfo(getString(message('MATLAB:helpUtils:displayHelp:PublishedOutputInTheHelpBrowser')), 'showdemo', demoTopic);
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2011/08/13 17:29:51 $
