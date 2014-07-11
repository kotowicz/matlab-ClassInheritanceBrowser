classdef raw < handle
    properties (SetAccess=protected, GetAccess=protected)
        isUnspecifiedConstructor = false;
    end

    methods (Abstract)
        classInfo = getConstructor(cw, justChecking);
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2012/09/05 07:24:23 $
