%The metadata for the simulation. Note that addNoise is now a variable in
%the Device class and needs to be changed there in order to be used.
classdef ConnectionInfo
    properties
        numConnectionsPerHostPerSec_=2
        numSecsInDiagnosisPeriod_ =30
        numPacketsInConnectionMax=100
        defaultLinkDropRate= pow(10,-12)
        probabilityOfSameSwitchFailure=0.1
        sourcebiased=false
        destbiased = false
        addNoise=true
        Sample=true
    end
end