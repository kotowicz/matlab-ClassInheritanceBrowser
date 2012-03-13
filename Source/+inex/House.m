classdef House < inex.Dwelling
    
    properties
        NumRooms
        Pool
    end
    
    methods
        function obj = House(varargin)
            obj.NumRooms = varargin{1};
            obj.Pool = varargin{2};
        end
    end
end