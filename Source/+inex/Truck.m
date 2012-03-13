classdef Truck < inex.Vehicle
    
    properties
        fourWheelDrive
        towingCapacity
    end
    
    methods
        function obj = Truck(varargin)
            obj.fourWheelDrive = varargin{1};
            obj.towingCapacity = varargin{2};
        end
    end
end