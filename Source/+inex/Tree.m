classdef Tree < inex.physicalObject
    
    properties
        height
        species
    end
    
    methods
        function obj = Tree(varargin)
            obj.height = varargin{1};
            obj.species = varargin{2};
        end
    end
end