classdef Bicycle < inex.Vehicle
    
    properties
        numGears
        type
    end
    
    methods
        function obj = Bicycle(varargin)
            obj.numGears = varargin{1};
            obj.type = varargin{2};
        end
    end
end