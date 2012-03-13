classdef Apt < inex.Dwelling
    
    properties
        rent
    end
    
    methods
        function obj = Apt(varargin)
            obj.rent = varargin{1};
        end
    end
end