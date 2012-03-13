classdef Vehicle < inex.physicalObject
    
    properties
        speed
    end
    
    methods
        function obj = Vehicle(varargin)
            obj.speed = varargin{1};
        end
    end
end