%A T2 switch.
%written by: Behnaz Arzani
classdef T2 < Device
    methods
        function obj=T2(obj)
            obj.type_=deviceType.T2;
            obj.LowerNeighbors_=[];
            obj.UpperNeighbors_=[];
            obj.NeighborDropRates_=[];
            obj.podIndex_=0;
            obj.Name_=0;
        end
    end
    methods
        function obj=changeName(obj,val)
            obj.Name_=val;
        end
    end
end


    