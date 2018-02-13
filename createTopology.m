%%This function creates a topology,
%% takes as input the number of pods to be in the topology.
%%the topology it creates is a Clos topology.

%%Output: the list of hosts, tors, and t1 switches, the topology, the linklist of all links, and the list of
%% all t2 switches.
%Written By: Behnaz Arzani.
function [HostList, ToRList, T1List, topology, LinkList,T2List]=createTopology(numPods)
    HostList=[];
    ToRList=[];
    deviceList=[];
    LinkList=[];
    T2List=[];
    T1List=[];

    Device.updateGetNumCreated(false);

    %%create R_ T2 switches.
    for i=1:Device.R_
       Device.updateGetNumCreated(true);
       dev=T2();
       %%asign and id to the device.
       dev.Name_=Device.updateGetNumCreated();

       dev=HandleObject(dev);
       %%add the device to the device list and the list of t2 switches.
       deviceList=[deviceList,dev];
       T2List=[T2List,dev];
    end

%% Now all t2 switches are created, we need to add t1 switches.
    for pod=1:numPods
        podT1s=[];
        podTors=[];
    
        %%creaete K_ t1 switches per pod.
        for j=1:Device.K_
            Device.updateGetNumCreated(true);
            dev=T1();
            %%assign an ID to the deice.
            dev.Name_=Device.updateGetNumCreated();
            %%assign a pod Id to the t1 switch.
            dev=dev.setpodIndex(pod);
            
            %create a pointer of dev.
            dev=HandleObject(dev);
            
            %%now add the T2 switches as upstream neighbors of these t1 switches.          
            upperNeighbors=[];
            for i=1:length(T2List)
                info=LinkInfo;
                info=info.setSource(dev);
                info=info.setDest(T2List(i));
                info=HandleObject(info);

                
                LinkList=[LinkList,info];
                %%put the index of this link in the upstream neighbors list.
                upperNeighbors=[upperNeighbors,length(LinkList)];
            end
            %% assign the results to the node.
            dev.Object=dev.Object.setUpperNeighbors(upperNeighbors);
            %%assign the device to the pods and the t1 list.
            podT1s=[podT1s,dev];
            T1List=[T1List,dev];
        end
            %%add tors to the pod.
            for i=1:Device.ToRs_
                 Device.updateGetNumCreated(true);
                 dev=ToR();
                 dev.Name_=Device.updateGetNumCreated();
                 dev=dev.setpodIndex(pod);
                 dev=HandleObject(dev);
                 upperNeighbors=[];
                 
                 %%add the tor-t1 links.
                 for j=1:length(podT1s)
                     info=LinkInfo();
                     info=info.setSource(dev);
                     info=info.setDest(podT1s(j));
                     info=HandleObject(info);
                     LinkList=[LinkList,info];
                     upperNeighbors=[upperNeighbors,length(LinkList)];
                 end
                 dev.Object=dev.Object.setUpperNeighbors(upperNeighbors);
                 ToRHosts=[];
                 %%add the hosts.
                 for k=1:40
                     Device.updateGetNumCreated(true);
                     mydev=Host();
                     mydev.Name_=Device.updateGetNumCreated();
                     mydev=mydev.setpodIndex(pod);
                     mydev=HandleObject(mydev);
                     info=LinkInfo();
                     info=info.setSource(mydev);
                     info=info.setDest(dev);
                     info=HandleObject(info);
                     LinkList=[LinkList,info];
                     upperNeighbors=[length(LinkList)];
                     mydev.Object=mydev.Object.setUpperNeighbors(upperNeighbors);
                     ToRHosts=[ToRHosts,mydev];
                     HostList=[HostList,mydev]; 
                 end
                 lowerNeighbors=[];
                 for k=1:length(ToRHosts)
                     info=LinkInfo();
                     info=info.setSource(dev);
                     info=info.setDest(ToRHosts(k));
                     info=HandleObject(info);
                     LinkList=[LinkList,info];
                     lowerNeighbors=[lowerNeighbors,length(LinkList)];
                 end
                 dev.Object=dev.Object.setLowerNeighbors(lowerNeighbors);
                 podTors=[podTors,dev];
                 ToRList=[ToRList,dev];
                 deviceList=[deviceList,dev];
            end
            %%add the tors downstream to the t1s.
            for i=1:length(podT1s)
                lowerNeighbors=[];
                for j=1:length(podTors)
                    info=LinkInfo();
                    info=info.setSource(podT1s(i));
                    info=info.setDest(podTors(j));
                    info=HandleObject(info);
                    LinkList=[LinkList,info];
                    lowerNeighbors=[lowerNeighbors,length(LinkList)];
                end
                podT1s(i).Object=podT1s(i).Object.setLowerNeighbors(lowerNeighbors);
            end
            %%add t1s downstream to the t2s.
            deviceList=[deviceList,podT1s];
            for i=1:length(T2List)
                lowerNeighbors=[];
                for j=1:length(podT1s)
                    info=LinkInfo();
                    info=info.setSource(T2List(i));
                    info=info.setDest(podT1s(j));
                    info=HandleObject(info);
                    LinkList=[LinkList,info];
                    lowerNeighbors=[lowerNeighbors,length(LinkList)];
                end
                T2List(i).Object=T2List(i).Object.setLowerNeighbors(lowerNeighbors);
            end
        
    end
    topology=deviceList;
end


