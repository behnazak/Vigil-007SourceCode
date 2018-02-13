%this is a tor object.
% has the device type, which is a TOR.
%keeps track of the lowerneighbors, 
%the upperneighbors,
%and the neighbor drop rates
%and the podIndex and device name.
%written by: Behnaz Arzani
classdef ToR < Device
    methods
        function obj=ToR(obj)
            obj.type_=deviceType.ToR;
            obj.LowerNeighbors_=[];
            obj.UpperNeighbors_=[];
            obj.NeighborDropRates_=[];
            obj.podIndex_=0;
            obj.Name_=0;
        end
    end
end


  