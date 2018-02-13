%the host class.
classdef Host < Device
    methods
        function obj=Host(obj)
            obj.type_= deviceType.Host;
            obj.LowerNeighbors_=[];
            obj.UpperNeighbors_=[];
            obj.NeighborDropRates_=[];
            obj.podIndex_=0;
            obj.Name_=0;
        end
    end
end

 