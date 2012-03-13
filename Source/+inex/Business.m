classdef Business < inex.Building
    
    properties
        businessName
        hours
    end
    
    methods
        function obj = Business(varargin)
            obj.businessName = varargin{1};
            obj.hours = varargin{2};
        end
    end
end