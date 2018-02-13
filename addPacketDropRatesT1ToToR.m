function overAllFailed=addPacketDropRatesT1ToToR(t1List, LinkList, numLinkFailures,p)
%%adds packet drops to t1-Tor links 
%% it is similar to the function that adds drops to t1-t2 links and 
%%you can refer to the comments in that function to understand how this function works.
%Written By: Behnaz Arzani
    failedDictSources=[];
    overAllFailed=[];
    numsoFar=0;
    lower = 0.00001;
    upper = 0.01
    connInfo=ConnectionInfo;
    while(numsoFar<numLinkFailures)
        failedDict=[];
        t1=datasample(t1List,1);
        tmp=arrayfun(@(x){x.Object},failedDictSources);
        if length(tmp)>0
            tmp=[tmp{:}];
        end
        if (ismember(t1.Object, tmp ))
            continue;
        end
   
        %%Unless p is greater than 1, drop rate is equal to Otherwise, it is chosen
	%%uniformly at random.
        failedDictSources=[failedDictSources,t1];
        link=datasample(t1.Object.LowerNeighbors_,1);
        LinkList(link).Object.dropRate_=p;


	if p >= 1
           LinkList(link).Object.dropRate_=random('unif',lower,upper);
        end
	failedDict=[failedDict,link];
        numsoFar=numsoFar+1;
        overAllFailed=[overAllFailed,link];
        while numsoFar<numLinkFailures
            p2=random('unif',0,1);
            if p2<connInfo.probabilityOfSameSwitchFailure
                link=datasample(t1.Object.LowerNeighbors_,1);
                if ismember(link,failedDict)
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
        t1.Object=t1.Object.setNeighborDropRates(failedDict);
    end
    assert(numsoFar<=numLinkFailures);
 
end


