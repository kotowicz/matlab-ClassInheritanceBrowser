classdef Dwelling < inex.Building
    
    properties
        residents
    end
    
    methods
        function obj = Dwelling(varargin)
            obj.residents = varargin{1};
        end
    end
end