classdef Taxi < inex.Car
    
    properties
        Rate
        GoodDriver
    end
    
    methods
        function obj = Taxi(varargin)
            obj.Rate = varargin{1};
            obj.GoodDriver = varargin{2};
        end
    end
end