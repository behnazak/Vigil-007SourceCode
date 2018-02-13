function [connectionList,status,mycount,droppedOn]=handle30SecPeriod(topology,ToRList,HostList,LinkList,overAllFailed,isbiased)
    %takes as input:
    % topology: the topology that was created by the createTopology
    % function
    %ToRList: the list of all ToRs.
    %HostList: the list of all Hosts.
    %LinkList: the list of all Links.
    %overAllFailed: the list of all failed links.
    %isbiased: whether this is a biased experiment or not, if 0 the
    %experiment is unbiased, otherwise has to be a value in (0,1) and
    %specify the fraction of connections that are sent to the ``hot'' TOR
    %(which is 1-this value)
    %Written by Behnaz Arzani
    %% Initialize...
    myTorList=[];
    connInfo=ConnectionInfo;
    numConnections=connInfo.numConnectionsPerHostPerSec_*...
            connInfo.numSecsInDiagnosisPeriod_;
    connectionList=sparse(length(HostList)*numConnections,length(LinkList));
    status=sparse(length(HostList)*numConnections,1);
    mycount=sparse(length(HostList)*numConnections,1);
  
    index=0;
    droppedOn=sparse(length(HostList)*numConnections,1);
    biasedTor = datasample(ToRList,1);
         

    %%Use 0 to avoid biased tor, use 1-p to have a fraction p of connections go to the biasedTor 
    %% hot Tor scenario.
    biased = isbiased;
   
    %%Loops through host list to find the number of packets dropped on each.
    for i=1:length(HostList)

        hostFailedCount = 0;   
        
        for j=1:numConnections
            path=[];
            index=index+1;
            p = random('unif',0,1);
            %check if this is a biased example or not.
            if p >= biased
               %pick a destination TOR at random to use as destination
               tmpSample=datasample(ToRList,1);
  
               while(tmpSample.Object==LinkList(HostList(i).Object.UpperNeighbors_(1)).Object.dest_.Object)
                  tmpSample=datasample(ToRList,1);
               end

            else
                %use the biased tor as the destination for this connection.
                tmpSample = biasedTor;     
            end
                     
            dest=tmpSample;         
            destIp=datasample(dest.Object.LowerNeighbors_,1);
            nexthop=HostList(i).Object.UpperNeighbors_(1);
            foundDrop=false;
            %Specify the number of packets that this connection is sending.
            %This is a number between 0-x. you can specify x by changing
            %the connection info.
            numPackets=random('unid',connInfo.numPacketsInConnectionMax);
            
         
            
            conn=zeros(1,length(LinkList));
            stop=false;
            oldInfo=[];
            failedCheckList=[];
            failedIndex=[];
            iteration=0;
            
            count=0;
            while ~stop
                iteration=iteration+1;
                if iteration>6
                    assert(0)
                end
                oldhop=nexthop;
                %find next hop.
                nexthop=LinkList(nexthop).Object.dest_.Object;
                myhop=nexthop;
                %add old hop to the path list.
                path=[path,LinkList(oldhop)];
                %%Actually routes the packet using the next hop routing
                %%table.
                nexthop=nexthop.routeToDest(HostList(i),destIp,dest);
                
                %%check if we reached the destination or not.
                if(isnan(nexthop))
                    stop=true;
                    nexthop=destIp;
                end
                
                %check if the packet was dropped. 
                [drop,newcount]=LinkList(oldhop).Object.source_.Object.checkForPacketDrops(oldhop,numPackets,HostList(i),dest);
                %update the number of packets dropped on this connection so
                %far.
                count=newcount+count;
	            %If this connection has had packet drops
                if  drop || foundDrop
                    
                    foundDrop=true;
                    %%models the upper bound on the number of  traceroutes allowed per second. 
                    %%note this is only taken into account in the computation of link scores.
                    %%not in the actual recording of path as we want to test the binary/integer optimization with
                    %%full path information.                   
                    if hostFailedCount <= (10 * connInfo.numSecsInDiagnosisPeriod_)
                    	LinkList(oldhop).Object=LinkList(oldhop).Object.addFailed();
                        hostFailedCount = hostFailedCount + 1;
                    end
                     
                    conn(oldhop)=1;
		    %%checks whether one of the "failed" links has dropped packets for this connection. If yes, it 
                    %%leaves the index as is, as that link will drop more packets than noise, otherwise marks the packet as being dropped on the current link.
                    if(length(find(overAllFailed==droppedOn(index)))==0)
		                droppedOn(index)=oldhop;
                    end
                    
                else
                    failedCheckList=[failedCheckList,LinkList(oldhop)];
                    failedIndex=[failedIndex,oldhop];
                end
                
            end
            %addsfailure to all hops allong the path.
            failedCheckList=arrayfun(@(x){AddFailedToObj(x,foundDrop)},failedCheckList);
            %adds successcount to all successful connections.
            oldInfo=arrayfun(@(x){AddSuccessToObj(x,foundDrop)},oldInfo);

            %add 1's to the connection matrix if the connection dropped a
            %packet.
            if foundDrop
                for k=1:length(failedCheckList)
                    conn(failedIndex(k))=1;
                end
            end
            if foundDrop
                status(index)=1;
                mycount(index)=count;
                %update the hopbased score.
                arrayfun(@(x){AddToVigilScore(x,length(path),count)},path);
            else
                status(index)=0;
            end
            connectionList(index,:)=conn;
           
        end
        
    end
end


%             
% 
%     #for eachElem in  ToRList:
%         # assert(eachElem in myTorList)  
%     return {'LinkList':LinkList, 'connectionList':connectionList, 'status':status}    
