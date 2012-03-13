classdef Person < inex.physicalObject
    
    properties
        name
        gender
    end
    
    methods
        function obj = Person(varargin)
            obj.name = varargin{1};
            obj.gender = varargin{2};
        end
    end
end