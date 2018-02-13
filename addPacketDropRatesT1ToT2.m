
function overAllFailed=addPacketDropRatesT1ToT2(t1List, LinkList, numLinkFailures,p)
%%%This function adds packet drops to a T1-T2 link.
%% In its current form if p is greater than one, it picks a failure probability chosen uniformly
%% at random between 0.0001-0.01 (note these are probabilities and between 0-1 not percentages). These values are hardcoded but can be changed if needed.
%% Inputs:
%% t1List-> the list of all T1 switches
%% LinkList -> the linklist of all links in the topology
%% numLinkFailures--> number of link failures to have
%% p-> the probability of packet drop on the failed link, will be ignored if p>=1.
%Written By: Behnaz Arzani
    failedDictSources=[];
    overAllFailed=[];
    numsoFar=0;

    %connInfo has the high level configuration of the simulation.
    connInfo=ConnectionInfo;

    %%The probability of packet drop is chosen uniformly at random between these two values.
    %%These values will be ignored if p<1.
    lower = 0.0001;
    upper = 0.01;
    while(numsoFar<numLinkFailures)
        failedDict=[];
   
        %% Pick a t1 switch uniformly at random from the set of all t1 switches.
        t1=datasample(t1List,1); 
        tmp=arrayfun(@(x){x.Object},failedDictSources);
        if length(tmp)>0
            tmp=[tmp{:}];
        end
          
        %%If we have already marked this t1 as having one or more 
        %%failed links go back and try finding another t1 switch.
        %%Having multiple failured links on the same switch is allowed
        %% but we want to control its probability. The following achieves this. 
        if (ismember(t1.Object, tmp ))
            continue;
        end

        %% Add switch to the dictionary.
        failedDictSources=[failedDictSources,t1];

        %Pick one of the links on this t1 switch to be marked as a failed link.
        link=datasample(t1.Object.UpperNeighbors_,1);
      
        %%assign a drop rate of p to this link.
        LinkList(link).Object.dropRate_=p;
        if p>=1
             %If p>1 replace drop rate with one that is chosen uniformly at random between 0.01% and 1%.
             LinkList(link).Object.dropRate_=random('unif',lower,upper);
	end
        %% add the link to the list of failed links.
	failedDict=[failedDict,link];
        %%we have successfully marked a single t1-t2 link as a failed link with 
        %% a probability of packet drop.
        numsoFar=numsoFar+1;

        %%add this to the total list of failed links.
        overAllFailed=[overAllFailed,link];

        %%Here we allow more links on the same switch to fail.
        while numsoFar<numLinkFailures
            p2=random('unif',0,1);
            %%with probability equal to that set in the high level properties of the 
            %%simulation, we assign another link on the switch as failed as well.
            if p2<connInfo.probabilityOfSameSwitchFailure
                link=datasample(t1.Object.UpperNeighbors_,1);
                if ismember(link,failedDict)
                    %%If another link on the switch has been chosen we skip and repeat
                    %%this process, note that this is unlikely, but the current choice of implementation
                    %% means that the probability of the second link on that switch to fail is slightly less than p2.
                    continue;
                end
                LinkList(link).Object.dropRate_=p;
                if p>=1
       		 LinkList(link).Object.dropRate_=random('unif',lower,upper);
		end
		failedDict=[failedDict,link];
                overAllFailed=[overAllFailed,link];
                numsoFar=numsoFar+1;
            else
                break;
            end
        end
        
        %%We next add the failed links to the neighboring nodes for future reference.
        t1.Object=t1.Object.setNeighborDropRates(failedDict);
    end
    assert(numsoFar<=numLinkFailures);
end


