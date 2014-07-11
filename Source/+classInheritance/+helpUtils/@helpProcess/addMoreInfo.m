function addMoreInfo(hp, infoStr, infoCommand, infoArg)
    infoAction = helpUtils.makeDualCommand(infoCommand, infoArg);
    if hp.wantHyperlinks
        moreInfo = sprintf('\n    %s\n       <a href="matlab:%s">%s</a>\n', infoStr, infoAction, infoAction);
    else
        moreInfo = sprintf('\n    %s\n       %s\n', infoStr, infoAction);
    end
    hp.helpStr = [hp.helpStr moreInfo];
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2011/10/22 22:03:57 $
