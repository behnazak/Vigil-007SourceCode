function overAllFailed=addPacketDropRatesTorToT1(torList, LinkList, numLinkFailures,p)
%%adds packet drops to tor-t1 links 
%% it is similar to the function that adds drops to t1-t2 links and 
%%you can refer to the comments in that function to understand how this function works.
%Written By: Behnaz Arzani
    failedDictSources=[];
    overAllFailed=[];
    numsoFar=0;
    connInfo=ConnectionInfo;
    lower = 0.0001;
    upper = 0.01;
    while(numsoFar<numLinkFailures)
        failedDict=[];
        tor=datasample(torList,1);
        tmp=arrayfun(@(x){x.Object},failedDictSources);
        if length(tmp)>0
            tmp=[tmp{:}];
        end
        if (ismember(tor.Object, tmp,'legacy' ))
            continue;
        end
        failedDictSources=[failedDictSources,tor];
        link=datasample(tor.Object.UpperNeighbors_,1);
        LinkList(link).Object.dropRate_=p;
	if p>=1
                
             LinkList(link).Object.dropRate_=random('unif',lower,upper);
        end
	failedDict=[failedDict,link];
        numsoFar=numsoFar+1;
        overAllFailed=[overAllFailed,link];
        while numsoFar<numLinkFailures
            p2=random('unif',0,1);
            if p2<connInfo.probabilityOfSameSwitchFailure
                link=datasample(tor.Object.UpperNeighbors_,1);
                if ismember(link,failedDict,'legacy')
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
        tor.Object=tor.Object.setNeighborDropRates(failedDict);
    end
    assert(numsoFar<=numLinkFailures);
end


