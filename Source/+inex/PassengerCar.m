classdef PassengerCar < inex.Car
    
    properties
        AirBags
        Automatic
    end
    
    methods
        function obj = PassengerCar(varargin)
            obj.AirBags = varargin{1};
            obj.Automatic = varargin{2};
        end
    end
end