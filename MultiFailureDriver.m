%%The first code to run with this might be to look at different degrees of
%skew in number of connections.
display('starting')


%%Put here the type of experiment you are running, this will be used in
%%generating a file name
experimentType = 'example_filename';

%%Specify the number of failures as a list.
numberOfFailures = (1:1:10);
%number of pods in the topology (note, that larger topologies have longer
%runtimes.
numPods = 2;

%%Put here any prefix you want to add to the filename.
VigilResults = 'vigilResults';

counter = 1;

BinaryOpt = 'binaryOpt';
IntegerOpt = 'integerOpt';
failedLinkSet = 'failedLinkSet';

blamedByUs = cell(1,length(numberOfFailures));
blamedByInt = cell(1,length(numberOfFailures));
blamedByBinary = cell(1,length(numberOfFailures));





for k=1:10
parfor(i=1:length(numberOfFailures))
    i
    pause(100*random('unif',0,1));
   
    %%Take n as the number of failures.
    n = numberOfFailures(i);


    %%First I need to create the topology.
    [HostList, ToRList, T1List, topology, LinkList, T2List] = ...
    createTopology(numPods);

    rng(random('unid',100));

    %Next I need to create the link list.
    LinkList = arrayfun(@(x){addLinkListToSourceAndDest(x,LinkList)},...
    LinkList);
    LinkList = [LinkList{:}];

    %%Find how many of the link failures are from each failure
    %%type.
    overAllFailed = [];
    numFailures = mnrnd(n,[0.25,0.25,0.25,0.25]);
    while sum(isnan(numFailures))>0	
     numFailures = mnrnd(n,[0.25,0.25,0.25,0.25]);
    end
     
    %get the list of failed links.
    overAllFailed = [overAllFailed,addPacketDropRatesTorToT1(ToRList, ...
        LinkList, numFailures(1),2)];
   
    overAllFailed = [overAllFailed,addPacketDropRatesT1ToT2(T1List, ...
        LinkList, numFailures(2),2)];
    
    overAllFailed = [overAllFailed,addPacketDropRatesT2ToT1(T2List,...
        LinkList, numFailures(3),2)];
	
    overAllFailed = [overAllFailed,addPacketDropRatesT1ToToR(T1List,...
        LinkList, numFailures(4),2)];

    %make sure that exactly n links have failed.
    assert(length(overAllFailed)==n);
    
    %%Default is to run the experiment as unbiased.
    [connectionList,status,mycount,droppedOn] = handle30SecPeriod(topology,...
        ToRList,HostList,LinkList, overAllFailed,0);

     %%run the integer and binary optimizations.
     p1= optimize(connectionList, status);
    [p2,original] = optimizeV2(connectionList, mycount);
    p = p1;

    %%Wrote results to file.
    filename = sprintf('%s_%s_%d_%d_%f.csv',VigilResults, experimentType,...
        counter,k,n);
    
    fileID = fopen(filename,'w');
    
    fprintf(fileID,...
        'source,source type,dest, dest type, score, retransmitCount, vigilScore\n');
    
    %%update vigil scores and write them to file.
    LinkList = arrayfun(@(x){computeScore(x)},LinkList);
    LinkList = [LinkList{:}];
    arrayfun(@(x){writeToFile(x,fileID)},LinkList);
    fclose(fileID);
    
    
    %Write the list of failed links to file.
    filename = sprintf('listofFailedLinks_%s_%d_%d_%f.csv',...
        experimentType, counter,k,n);
    fileID = fopen(filename,'w');
    for j= 1:length(overAllFailed)
    fprintf(fileID, '%d,%d\n', LinkList(overAllFailed(j)).Object.source_.Object.Name_,...
                                    LinkList(overAllFailed(j)).Object.dest_.Object.Name_)
    end
    fclose(fileID)
    
    
    %write the reults of the two optimization algorithms to file.
    filename = sprintf('%s_%s_%d_%d_%f.csv',BinaryOpt, experimentType,...
        counter,k,n);
    fileID = fopen(filename,'w');
    
    x1 = find(p1==1);
    x2 = find(p2 == 1);
    
    fprintf(fileID,...
        'index of first failed link,opt output,failed link source, failed Link dest\n');
    for j=1:length(x1)
        fprintf(fileID,'%d, %d,%d,%d\n',overAllFailed(1),...
            x1(j),LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
            LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    
    
    if length(x1)==0
        fprintf(fileID,'%d,-,%d,%d\n',overAllFailed(1),...
            LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
           LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    
    fclose(fileID);


    %write results of integer optimization to file.
    filename=sprintf('%s_%s_%d_%d_%d_%f.csv',IntegerOpt,...
        experimentType,counter,k,n);
    fileID = fopen(filename,'w');
    fprintf(fileID,...
        'index of first failed link,opt output, failed link source, failed Link dest\n');
    for j = 1:length(x2)
        fprintf(fileID,'%d, %d,%d,%d\n',overAllFailed(1),...
            x2(j),LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
            LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    if length(x2)==0
        fprintf(fileID,'%d,-,%d,%d\n',overAllFailed(1),...
            LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
           LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    fclose(fileID)
   



%%%%%%PerConnection%%%%%%%%%
%results of the per connection failure identification are gathered here.
    %initiate datastructures.
    blamedByUs{i} = zeros(length(droppedOn),1);
    blamedByInt{i} = zeros(length(droppedOn),1);
    blamedByBinary{i} = zeros(length(droppedOn),1);
   
    %number of connections that actually had drops.
    numfailed = full( sum(droppedOn ~= 0) );
    %index of the links that had packet drops.
    indexes = find(droppedOn ~= 0);
    for o = 1:length(indexes)
      l = indexes(o);
      %If we don't have the path for that connection continue.
      if(sum(connectionList(l,:)) == 0)
           continue;
      end
      %find the index of the links along that connection's path.
      myindex = find(connectionList(l,:) == 1);
      %thse are the links that are not along its path.
      notmyIndex = find(connectionList(l,:) == 0);
      %get the score of the links along the path.
      tmp = arrayfun(@(x){x.Object.vigilScore_},LinkList);
      tmp = [tmp{:}];
      %set the score of all links that are not along this path to a 
      %very low value so that they are not used in the analysis.
      tmp(notmyIndex) = -100;
      %find link with max score.
      [t , idx] = max(tmp);
      %check if this is a noise drop. If yes, just disregard this drop.
      if t <= 0.2
         if(length(find(droppedOn(l) == overAllFailed)) == 0)
            droppedOn(l) = 0;
         end
         continue;
      end 
      %else count this as the link that we blame.
      blamedByUs{i}(l) = idx;
      %next we look at the results of the optimization
      y1 = x1;
      y2 = original;
      %If not on the path of the connection set the link as not failed.
      y1(notmyIndex) = 0;
      y2(notmyIndex) = 0;
      [t1, idx1] = max(y1);
      [t2, idx2] = max(y2);
      if(length(idx1) == 0)
          idx1 = 0;
      end
      if(length(idx2) == 0)
          idx = 0;
      end
      %if multiple lengths are blamed then the algorithm has failed.
      if(length(idx1) > 1)
          idx1 = -1;
      end
      if(length(idx2) > 1)
          idx2 = -1;
      end
      blamedByInt{i}(l) = idx2;
      blamedByBinary{i}(l) = idx1;

    end
    %find how many we identified correctly.
   correct = sum(blamedByUs{i} == droppedOn);
   incorrect = sum(blamedByUs{i} ~= droppedOn);

    %output the results.
    filename = sprintf('%s_%s_PerConnection_%d_%f.csv',VigilResults,...
        experimentType,k,n);
    fileID = fopen(filename, 'w');
    fprintf(fileID,...
        'correct, incorrect, total number of links, number of failed, \n');
    fprintf(fileID, '%d,%d,%d,%d\n',...
        full(correct), full(incorrect), length(droppedOn),numfailed);
    fclose(fileID);




    correct = sum(blamedByBinary{i} == droppedOn);
    incorrect = sum(blamedByBinary{i} ~= droppedOn);
   
    filename = sprintf('%s_%s_PerConnection_%d_%f.csv', BinaryOpt,...
        experimentType,k,p1);
    fileID = fopen(filename,'w');
    fprintf(fileID, 'correct,incorrect\n');
    fprintf(fileID, '%d,%d\n',full(correct),full(incorrect));
    fclose(fileID);


    correct = sum(blamedByInt{i} == droppedOn);
    incorrect = sum(blamedByInt{i} ~= droppedOn);
    filename  = sprintf('%s_%s_PerConnection_%d_%f.csv',IntegerOpt,...
        experimentType,k,p1);
    fileID = fopen(filename,'w');
    fprintf(fileID,'correct,incorrect\n');
    fprintf(fileID, '%d,%d\n',full(correct),full(incorrect));
    fclose(fileID);

    
end
end
