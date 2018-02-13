%A T1 switch.
%written by: Behnaz Arzani
classdef T1 < Device
    methods
        function obj=T1(obj)
            obj.type_=deviceType.T1;
            obj.LowerNeighbors_=[];
            obj.UpperNeighbors_=[];
            obj.NeighborDropRates_=[];
            obj.podIndex_=0;
            obj.Name_=0;
        end
    end
end
    
   