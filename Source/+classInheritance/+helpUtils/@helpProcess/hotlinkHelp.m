function hotlinkHelp(hp)
    %HOTLINKHELP Reformat help output so that the content has hyperlinks
    
    %   Copyright 1984-2006 The MathWorks, Inc.
    %   $Revision: 1.1.6.21 $  $Date: 2012/09/05 07:24:36 $
    
    packageName = '';
    className = '';
    inClass = false;
    
    [pathName, fcnName] = fileparts(hp.topic);
    if hp.isOperator
        if isempty(pathName)
            fcnName = hp.topic;
        end
    else
        if hp.isDir
            pathName = hp.topic;
            fcnName = regexp(fcnName, '\w+', 'match', 'once');
        elseif any(fcnName==filemarker)
            methodSplit = regexp(fcnName, filemarker, 'split', 'once');
            pathName = fullfile(pathName, methodSplit{1});
            fcnName = methodSplit{2};
        elseif strcmp(getFinalObjectEntity(pathName), fcnName);
            % @ dir Class
            inClass = true;
            packageName = classInheritance.helpUtils.getPackageName(fileparts(pathName));
            className = fcnName;
        elseif ~isempty(fcnName);
            packageName = classInheritance.helpUtils.getPackageName(pathName);
            if hp.isMCOSClass
                inClass = true;
                className = fcnName;
                if isempty(pathName)
                    pathName = className;
                else
                    pathName = [pathName '/' className];
                end
            end
        end
    end
    
    % hotlink all URLs in the help
    hp.helpStr = linkURLs(hp.helpStr, hp.command);
    
    [dirHelps, dirSplit] = regexp(hp.helpStr, '\{\b (?<text>.*?)\}\b ', 'names', 'split');
        
    for i = 1:length(dirHelps) 
        dirHelps(i).text = linkContents(hp, dirHelps(i).text, pathName, fcnName, false);
    end
    
    if hp.isOperator || hp.isContents || strcmp(fcnName,'debug')
        % hotlink these files like directories
        dirSplit{end} = linkContents(hp, dirSplit{end}, pathName, fcnName, false);
    else
        dirSplit{end} = linkSeeAlsos(hp, dirSplit{end}, pathName, fcnName, inClass);
        if inClass
            dirSplit{end} = linkMethods(hp, dirSplit{end}, packageName, className, pathName);            
        end
    end
    
    helpPieces = [dirSplit; {dirHelps.text, ''}];
    hp.helpStr = [helpPieces{:}];

    if hp.commandIsHelp
        hp.helpStr = classInheritance.helpUtils.highlightHelp(hp.helpStr, hp.objectSystemName, fcnName, '<strong>', '</strong>');
    end
end

%% ------------------------------------------------------------------------
function helpStr = linkSeeAlsos(hp, helpStr, pathName, fcnName, inClass)
    helpParts = classInheritance.helpUtils.helpParts(helpStr);
    seeAlsoPart = helpParts.getPart('seeAlso');
    if ~isempty(seeAlsoPart)
        % Parse the "See Also" portion of help output to isolate function names.
        seealsoStr = seeAlsoPart.getText;
        
        seealsoStr = linkList(hp, seealsoStr, pathName, fcnName, false, inClass);
        
        seeAlsoPart.replaceText(seealsoStr);

        % Replace "See Also" section with modified string (with links)
        helpStr = helpParts.getFullHelpText;
    end
end
    
%% ------------------------------------------------------------------------
function helpStr = linkURLs(helpStr, actionName)
    replaceLink = @(url)makeURLLink(url, actionName); %#ok<NASGU>
    helpStr = regexprep(helpStr, '(<a\s*href.*?</a>)?((?<!'')\<\w{2,}://\S*(?<=[\w\\/])\>(?!''))?', '$1${replaceLink($2)}', 'ignorecase');
end

%% ------------------------------------------------------------------------
function linkText = makeURLLink(url, actionName)
    if isempty(url)
        linkText = '';
    else
        if strcmp(actionName, 'help')
            linkText = createMatlabLink('web', url, url);
        else
            linkText = ['<a href="' url '">' url '</a>'];
        end
    end
end

%% ------------------------------------------------------------------------
function helpStr = linkMethods(hp, helpStr, packageName, className, pathName)
    % If there is a list of methods, make these act as links.
    if ~isempty(packageName)
        packageName = [packageName '.'];
    end
    methodsPattern = regexptranslate('escape', getString(message('MATLAB:classInheritance.helpUtils.helpProcess:Methods', className)));
    methodsPattern = [methodsPattern '|' getString(message('MATLAB:classInheritance.helpUtils.helpProcess:MethodsEnglish', className))];
    propertiesPattern = regexptranslate('escape', getString(message('MATLAB:classInheritance.helpUtils.helpProcess:Properties', className)));
    propertiesPattern = [propertiesPattern '|' getString(message('MATLAB:classInheritance.helpUtils.helpProcess:PropertiesEnglish', className))];
    methodsOrProperties = regexprep([methodsPattern '|' propertiesPattern], '\s+', '\\s+');
    methodsStart = regexpi(helpStr, ['^\s*(' packageName ')?(?:' methodsOrProperties '):\s*$'], 'lineanchors', 'once');
    
    if ~isempty(methodsStart)
        % Parse the "Methods" portion of help output to link like a Contents.m file.
        methodsStr = helpStr(methodsStart:end);
        methodsStr = linkContents(hp, methodsStr, pathName, className, true);
        
        % Replace "Methods" section with modified string (with links)
        helpStr = [helpStr(1:methodsStart-1) methodsStr];
    end
end

%% ------------------------------------------------------------------------
function helpStr = linkContents(hp, helpStr, pathName, fcnName, inClass)
    if ~inClass
        helpStr = linkSeeAlsos(hp, helpStr, pathName, fcnName, inClass);
    end
    replaceList = @(list)linkList(hp, list, pathName, fcnName, true, inClass); %#ok<NASGU>
    helpStr = regexprep(helpStr, '^(.*?)([ \t]-[ \t])', '${replaceList($1)}$2', 'lineanchors', 'dotexceptnewline');
end

%% ------------------------------------------------------------------------
function list = linkList(hp, list, pathName, fcnName, inContents, inClass)
    list = strrep(list, '&amp;', '&');
    replaceLink = @(name)makeHyperlink(hp, name, pathName, fcnName, inContents, inClass); %#ok<NASGU>
    list = regexprep(list, ['(<a\s*href.*?</a>)?([\w\\/.' filemarker ']+(?<!\.))?'], '$1${replaceLink($2)}', 'ignorecase');
end

%% ------------------------------------------------------------------------
function linkText = makeHyperlink(hp, word, pathName, fcnName, inContents, inClass)
    linkText = word;
    if isempty(word)
        return;
    end
    % Make sure the function exists before hyperlinking it.
    if strcmpi(word, fcnName)
        if hp.isMCOSClass
            if builtin('helpfunc', hp.fullTopic, '-justChecking')
                constructorTopic = [hp.fullTopic(1:end-2) '>' fcnName];
                if builtin('helpfunc', constructorTopic, '-justChecking')
                    % class or constructor self link, in which both exist
                    if inClass
                        % link to the constructor
                        linkTarget = [hp.objectSystemName '/' fcnName];
                    else
                        % link to the class
                        linkTarget = regexp(hp.objectSystemName, '[^/]*', 'match', 'once');
                    end
                    linkText = createMatlabLink(hp.command, linkTarget, fcnName);
                    return;
                end
            end
        end
        pathName = '';
    end
    if inContents || ~strcmp(word,'and')
        [shouldLink, fname, qualifyingPath, whichTopic] = isHyperlinkable(word, pathName);
        if shouldLink
            linkWord = classInheritance.helpUtils.extractCaseCorrectedName(fname, word);
            if isempty(linkWord)
                % word is overqualified
                [overqualifiedPath, linkWord] = classInheritance.helpUtils.splitOverqualification(fname, word, whichTopic);
                linkWord = [overqualifiedPath, linkWord];
            elseif ~isempty(qualifyingPath)
                % word is underqualified
                qualifyingPath(qualifyingPath=='\') = '/';
                fname = [qualifyingPath, '/', fname];
            end
            linkText = createMatlabLink(hp.command, fname, linkWord);
        end
    end
end

%% ------------------------------------------------------------------------
function linkText = createMatlabLink(command, linkTarget, linkText)
    linkText = ['<a href="matlab:' classInheritance.helpUtils.makeDualCommand(command, linkTarget) '">' linkText '</a>'];
end

%% ------------------------------------------------------------------------
function [shouldLink, fname, qualifyingPath, whichTopic] = isHyperlinkable(fname, helpPath)
    whichTopic = '';
    
    % Make sure the function exists before hyperlinking it.
    [fname, hasLocalFunction, shouldLink, qualifyingPath] = classInheritance.helpUtils.fixLocalFunctionCase(fname, helpPath);
    if hasLocalFunction
        return;
    end
    
    [fname, shouldLink, qualifyingPath, whichTopic] = isHyperlinkableMethod(fname, helpPath);
    if ~shouldLink
        % Check for directories on the path
        dirInfo = classInheritance.helpUtils.hashedDirInfo(fname);
        if ~isempty(dirInfo)
            fname = classInheritance.helpUtils.extractCaseCorrectedName(dirInfo(1).path, fname);
            if exist(fname, 'file') == 7
                shouldLink = true;
                return;
            end
        end
        
        % Check for files on the path
        [fname, qualifyingPath, ~, hasMFileForHelp, alternateHelpFunction] = classInheritance.helpUtils.fixFileNameCase(fname, helpPath, whichTopic);
        shouldLink = hasMFileForHelp || ~isempty(alternateHelpFunction);
    end
end

%% ------------------------------------------------------------------------
function [fname, shouldLink, qualifyingPath, whichTopic] = isHyperlinkableMethod(fname, helpPath)
    shouldLink = false;
    qualifyingPath = '';
    [classInfo, whichTopic] = classInheritance.helpUtils.splitClassInformation(fname, helpPath);
    if ~isempty(classInfo)
        shouldLink = true;
        % qualifyingPath includes the object dirs, so remove them
        qualifyingPath = regexp(fileparts(classInfo.minimalPath), '^[^@+]*(?=[\\/])', 'match', 'once');
        newName = classInfo.fullTopic;
        
        if classInfo.isConstructor && isempty(regexpi(fname, '\<(\w+)[\\/.]\1(\.[mp])?$', 'once'))
            fname = regexprep(newName, '\<(\w+)/\1$', '$1');
        else
            fname = newName;
        end
    end
end

%% ------------------------------------------------------------------------
function entity = getFinalObjectEntity(objectPath)
    entity = regexp(objectPath, '(?<=[@+])[^@+]*$', 'match', 'once');
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.21 $  $Date: 2012/09/05 07:24:36 $
