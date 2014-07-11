function docTopic = getDocTopic(path, name, isClassElement)
    persistent refBookPattern;
    if isempty(refBookPattern)
        pathToToolboxes = [matlabroot, filesep, 'toolbox', filesep];
        escapedPathToToolboxes = regexptranslate('escape', pathToToolboxes);
        refBookPattern = ['^' escapedPathToToolboxes, '(?<refBook>\w+)'];
    end
    splitPath = regexp(path, refBookPattern, 'names');
    docTopic = '';
    if ~isempty(splitPath)
        refBook = [splitPath.refBook '/' name];
        docCmdArg = com.mathworks.mlwidgets.help.HelpUtils.getDocCommandArg(refBook, isClassElement);
        if ~isempty(docCmdArg)
            docTopic = char(docCmdArg);
        end
    end
end

%   Copyright 2008-2012 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2012/04/27 17:32:30 $
