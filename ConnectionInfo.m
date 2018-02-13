%%High level information about the links in the network.
%Written By: Behnaz Arzani.
classdef ConnectionInfo
    properties
        %%defines the number of connections per host per second
        numConnectionsPerHostPerSec_ = 16
        %% defines the total length of the diagnosis period.
        numSecsInDiagnosisPeriod_ = 30
        %% maximum number of packets sent in each connection.
        numPacketsInConnectionMax = 100
        %%the minimum level of noise.
        defaultLinkDropRate = 0 
        %% the probability that the same switch has multiple failed links.
        probabilityOfSameSwitchFailure = 0.1
        %%whether or not there should be bias towards the source or destination
        %%whether the packet is dropped on the ingress of the destination switch or egress of the source.
        sourcebiased=false
        destbiased = false
        %%whether or not there should be noisy packet drops.
        addNoise=false
        %%Whether good connections should be sampled or not?
        Sample=true
    end
end
