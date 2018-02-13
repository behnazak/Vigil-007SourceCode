%% the model of the device.
%Written by: Behnaz Arzani
classdef  Device
    properties
      %%properties of a device. its type specifies where in the topology
      %%the switch is.
      type_=deviceType.Unknown;
      %%downstream and upstream neighbor lists.
      LowerNeighbors_=[]
      UpperNeighbors_=[]
      %%the drop rates of its links 
      NeighborDropRates_={}
      %% the index of the pod it belongs to 
      podIndex_ = 0
      %the node index (an identifier for this switch)
      Name_ = 0
      %%global index. keeps track of the total number of switches, 
      % can be used to index new switches.
      numCreated_ = 0
      %% a copy of the simulation settings
      connInfo=ConnectionInfo
      %
      LinkList_=[];
      %%noise rate to use on its links.
      noiseRate_ = 0.000001
      %change this if you dont want any noise to be added.
      addNoise = true
    end
    properties(Constant)
      %%number of Tors in each pod, number of T1s in each pod
      %and number of t2 switches.
      ToRs_=20
      K_=8
      R_=10
    end
     methods (Static)
      %%We need to test each of these functions later on.
      
      function out = updateGetNumCreated(update)
         persistent totalNumCreated_;
         if nargin
            if update
                 totalNumCreated_ = totalNumCreated_+1;
            else
                totalNumCreated_=0;
            end
         end
         out = totalNumCreated_;
      end
     end

   methods
       %%checks to see if there are links that are dropping packets
       function [res, numRetrans]=checkForPacketDrops(obj, nextLink,...
               numPackets,source,dest)
           %checks to see if this link is dropping any packets for that
           %connection. Outputs the number of packets dropped and an
           %indicator.
           found=false;
           %% assertion checks if the route makes sense.
           assert(ismember(nextLink,obj.UpperNeighbors_) || ismember(nextLink,obj.LowerNeighbors_));
           %If this link is not one that drops packets go here and apply
           %noise appropriately.
           if isempty(find(nextLink==obj.NeighborDropRates_, 1))
               if obj.addNoise
                   %%finds how many packets should be dropped on this link.
                   droprate=random('unif',obj.connInfo.defaultLinkDropRate, ...
                       obj.noiseRate_);
                   numRetrans=binornd(numPackets,droprate);
               else
                   droprate=0;
                   numRetrans=0;
               end
           else
               %this is a failed link so use the drop rate that is in the
               %link object itself.
               index = (nextLink==obj.NeighborDropRates_);
               droprate=obj.LinkList_(obj.NeighborDropRates_(index)).Object.dropRate_;
               numRetrans=binornd(numPackets,droprate);
               found=true;
           end
           prob=1-(1-droprate)^numPackets;
           p=rand();
           
           if((p<=prob && ~obj.connInfo.sourcebiased) &&  ~obj.connInfo.destbiased)
               res=true;
               return;
           else if (obj.connInfo.sourcebiased && found)
                   if(rem(source.Object.Name_,10)==0)
                       res=true;
                       return;
                   end
               else if (obj.connInfo.destbiased && found)
                        if(rem(dest.Object.Name_,10)==0)
                            res=true;
                            return;
                        end
                   end
               end
           
           end
           res=false;
           return;
       end
       function res=ne(obj,comp)
           res=~eq(obj,comp);
       end
       function res=eq(obj,comp)
           if isempty(comp)
               res=false;
               return;
           end
           if isempty(obj)
               res=false;
               return;
           end
           if length(obj)>1
               res=[];
               for i=1:length(obj)
                   if ~eq(obj(i),comp)
                       res=[res,false];
                   else
                       res=[res,true];
                   end
                   
               end
             
               return;
             
           end
           if length(comp)>1
                res=[];
               for i=1:length(comp)
                   if ~eq(obj,comp(i))
                       res=[res,false];
                   else
                       res=[res,true];
                   end
               end
               
               return;
           end
           
           if (obj.type_~=comp.type_)
               res=false;
               
               return;
           end
           if obj.podIndex_ ~=comp.podIndex_
               res=false;
               
               return;
           end
           if obj.Name_ ~=comp.Name_
               res=false;
               
               return;
           end
           res=true;
           return;
       end

       %%routing function. 
       function link=routeToDest(obj,source,dest,destToR)
            if obj==destToR.Object
                link=nan;
                return;
            end
            
            if obj.type_==deviceType.ToR
                index=random('unid',obj.K_);
                
                
                link= obj.UpperNeighbors_(index);
                return;
            end
            if obj.type_==deviceType.T1
                
                tmp=arrayfun(@(x){x.Object.dest_.Object},obj.LinkList_(obj.LowerNeighbors_));
                tmp=[tmp{:}];
                
                if ~isempty(find(ismember(obj.LinkList_(source.Object.UpperNeighbors_(1)).Object.dest_.Object,tmp)==1, 1))
                  
                   if(~isempty(find(tmp==destToR.Object, 1)))
                       
                       link=obj.LowerNeighbors_(find(destToR.Object==tmp));
                       
                       return 
                   end
                end
                if(~isempty(find(ismember(destToR.Object,tmp)==1,1)))
                    
                    link=obj.LowerNeighbors_(find(destToR.Object==tmp));
                    return;
               end
               if ~isempty(find(ismember(obj.LinkList_(source.Object.UpperNeighbors_(1)).Object.dest_.Object,tmp)==1, 1))
                  
                    index= random('unid',obj.R_);
                    link=obj.UpperNeighbors_(index);
                    return;
               end
               
               assert(0)
            end
            if obj.type_==deviceType.T2
               
                lowerneighbors=obj.LinkList_(obj.LowerNeighbors_);
                tmp=arrayfun(@(x){x.Object.dest_.Object},lowerneighbors);
                tmp=[tmp{:}];   
                tmp=arrayfun(@(x){x.podIndex_==destToR.Object.podIndex_},tmp);
                tmp=[tmp{:}];
                %tmp
                res=obj.LowerNeighbors_(tmp);  
%                 res=obj.LinkList_(res);
%                 res(1).Object.dest_.Object
%                 destToR.Object
                assert(length(res)==obj.K_);
                
                index=random('unid',obj.K_);
              
                link=res(index);
               
            end
            
       end
       function obj=setLowerNeighbors(obj,lowerNeighbors)
           obj.LowerNeighbors_=[obj.LowerNeighbors_,lowerNeighbors];
       end
       function obj=setUpperNeighbors(obj,upperNeighbors)
           obj.UpperNeighbors_=[obj.UpperNeighbors_,upperNeighbors];
       end
       function obj=setpodIndex(obj,index)
           obj.podIndex_=index;
       end
       function obj=setNeighborDropRates(obj,dropRateMap)
           obj.NeighborDropRates_=[obj.NeighborDropRates_,dropRateMap];
       end

   end
   
end




