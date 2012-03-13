classdef Building < inex.physicalObject
    
    properties
        height
        occupancy
    end
    
    methods
        function obj = Building(varargin)
            obj.height = varargin{1};
            obj.occupancy = varargin{2};
        end
    end
end