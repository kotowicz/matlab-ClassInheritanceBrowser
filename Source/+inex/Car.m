classdef Car < inex.Vehicle
    
    properties
        Manufacturer
        NumSeats
    end
    
    methods
        function obj = Car(varargin)
            obj.Manifacturer = varargin{1};
            obj.NumSeats = varargin{2};
        end
    end
end