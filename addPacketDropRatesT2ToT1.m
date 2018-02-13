
function overAllFailed=addPacketDropRatesT2ToT1(t2List, LinkList, numLinkFailures,p)

%%adds packet drops to t2-t1 links 
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
        t2=datasample(t2List,1);
        tmp=arrayfun(@(x){x.Object},failedDictSources); 
        if length(tmp)>0
            tmp=[tmp{:}];
        end
        if (ismember(t2.Object, tmp ))
            continue;
        end
        failedDictSources=[failedDictSources,t2];
        link=datasample(t2.Object.LowerNeighbors_,1);
        LinkList(link).Object.dropRate_=p;%random('unif',0.00001,0.01);
        if p>=1
             LinkList(link).Object.dropRate_=random('unif',lower,upper);
	end
	failedDict=[failedDict,link];
        numsoFar=numsoFar+1;
        overAllFailed=[overAllFailed,link];
        while numsoFar<numLinkFailures
            p2=random('unif',0,1);
            if p2<connInfo.probabilityOfSameSwitchFailure
                link=datasample(t2.Object.LowerNeighbors_,1);
                if ismember(link,failedDict)
                    continue;
                end
                LinkList(link).Object.dropRate_=p;%random('unif',0.00001,0.01);
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
        t2.Object=t2.Object.setNeighborDropRates(failedDict);
    end
    assert(numsoFar<=numLinkFailures);
end


