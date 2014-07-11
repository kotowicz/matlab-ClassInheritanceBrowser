function demoTopic = getDemoTopic(hp)
    demoTopic = '';
    [path, name] = fileparts(hp.fullTopic);
    if ~isempty(dir(fullfile(path, 'html', [name '.html'])))
        [path, demoTopic] = fileparts(hp.fullTopic);
        while ~strcmp(hp.fullTopic, helpUtils.safeWhich(demoTopic))
            [path, demoDir] = fileparts(path);
            demoTopic = [demoDir, '/', demoTopic]; %#ok<AGROW>
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2012/04/14 04:14:44 $
