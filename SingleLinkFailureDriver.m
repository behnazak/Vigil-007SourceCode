%This is the driver for the single failure experiments.
%Written by: Behnaz Arzani

%Specify what prefix you want to assign to this experiment.
experimentType = 'SingleFailureT1ToToR_SingleLinkFailure';

%%Failure probabilities that you want to try. this goes from 0.01% to 10%
%%in increments of 0.1%.
probValues=(0.0001:.001:0.1);

%number of pods.
numPods = 2;

%Note this only enables failures of a single link type not all link types. 
%to check how this works with the link types chosen at random you need to
%modify this driver script.
numberOfFailedLinks = 1;

%This is used as the base of the filename used for vigil's results.
VigilResults = 'vigilResults';
counter = 1;

%%This is used as the base of the filename for 
%the binary optimization results.
BinaryOpt = 'binaryOpt';

%%Base file name for the integer optimization algorithm
IntegerOpt = 'integerOpt';

%initialize.
blamedByUs = cell(1,length(probValues));
blamedByInt = cell(1,length(probValues));
blamedByBinary = cell(1,length(probValues));


for k=1:20
parfor i=1:length(probValues)
    i
    p1=probValues(i);
   
    %create the topology.
    [HostList, ToRList, T1List, topology, LinkList, T2List] = createTopology(numPods);

    %get the list of all links.
    LinkList=arrayfun(@(x){addLinkListToSourceAndDest(x,LinkList)},LinkList);
    LinkList=[LinkList{:}];


     
    %%Add packet drop rate to a single link type.
    %Modify this part of the code if you want to randomize what link type
    %has drop rates.
    overAllFailed=addPacketDropRatesT1ToToR(T1List, LinkList,...
        numberOfFailedLinks, p1);
    
    %run simulation.
    [connectionList,status,mycount,droppedOn]=handle30SecPeriod(topology,...
        ToRList,HostList,LinkList,overAllFailed,0);

    %% run the optimizations.
    p=optimize(connectionList, status);
    [p2, original] = optimizeV2(connectionList, mycount);


    %%WriteOurResultsToFile
    filename=sprintf('%s_%s_%d_%d_%f.csv',VigilResults,experimentType,...
        counter, k,p1);
    fileID = fopen(filename,'w');
    fprintf(fileID,...
        'source,source type,dest, dest type, score, retransmitCount, harryScore\n');
    LinkList=arrayfun(@(x){computeScore(x)},LinkList);
    LinkList=[LinkList{:}];
    arrayfun(@(x){writeToFile(x,fileID)},LinkList);
    fclose(fileID);
    

    %%Write the results of the binary optimization to file.
    filename=sprintf('%s_%s_%d_%d_%f.csv',...
        BinaryOpt,experimentType,counter,k,p1);
    fileID = fopen(filename,'w');
    fprintf(fileID,...
        'index of failed link,opt output, failed link source, failed Link dest\n');
    x1=find(p==1);
    
    
    for j=1:length(x1)
        fprintf(fileID,'%d, %d,%d,%d\n',...
            overAllFailed(1),x1(j),LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
            LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    if length(x1)==0
        fprintf(fileID,'%d,-,%d,%d\n',...
            overAllFailed(1),LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
           LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    
    fclose(fileID);


    %write the result of the integer optimization to file.
    filename=sprintf('%s_%s_%d_%d_%f.csv',...
        IntegerOpt,experimentType, counter,k,p1);
    fileID = fopen(filename,'w');
    fprintf(fileID,...
        'index of failed link,opt output, failed link source, failed Link dest\n');
    x2=find(p2==1);
    
    
    for j=1:length(x2)
        fprintf(fileID,'%d, %d,%d,%d\n',...
            overAllFailed(1),x2(j),LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
            LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    if length(x2)==0
        fprintf(fileID,'%d,-,%d,%d\n',overAllFailed(1),...
            LinkList(overAllFailed(1)).Object.source_.Object.Name_,...
           LinkList(overAllFailed(1)).Object.dest_.Object.Name_);
    end
    fclose(fileID);
       

%%%%%%%%%%%%PER CONNECTION%%%%%%%%%%%%%%
    %initialize.
    blamedByUs{i} = zeros(length(droppedOn),1);
    sample=random('unif',0,100);
    blamedByInt{i} = zeros(length(droppedOn),1);
    blamedByBinary{i} = zeros(length(droppedOn),1);
    %This is the number of connections that experienced at least one failure.
    numfailed = full(sum(droppedOn~=0));
    %find the indexes that had at least one failure.
    indexes = find(droppedOn~=0);
    for o = 1:length(indexes)
       l = indexes(o);
       %If we don't have the path for this connection, skip.
       if(sum(connectionList(l,:))==0)
          continue
       end
       myindex = find(connectionList(l,:)==1);
       notmyIndex = find(connectionList(l,:)==0);
       tmp = arrayfun(@(x){x.Object.harryScore_},LinkList);
       tmp = [tmp{:}];
       %set the score of all links that are not along the connection path
       %to a low value so that they are not considered.
       tmp(notmyIndex) = -100;
       [t, idx] = max(tmp);
       %check if noisy drop.
        if t <= 0.2
             if(length(find(droppedOn(l)==overAllFailed))==0)
                   droppedOn(l) = 0;
             end
             continue
         end
         blamedByUs{i}(l) = idx;
         y1 = x1;
         y2 = original;
         y1(notmyIndex) = 0;
         y2(notmyIndex) = 0;
         [t1,idx1] = max(y1);
         [t2,idx2] = max(y2);
         if(length(idx1) == 0)
             idx1 = 0;
         end
         if(length(idx2) == 0)
             idx2 = 0;
         end
         if(length(idx1) > 1)
            idx1 = -1;
         end
         if(length(idx2) > 1)
           idx2 = -1;
         end
         blamedByInt{i}(l) = idx2;
         blamedByBinary{i}(l) = idx1;

    end
      %%write to file.     
      correct = sum(blamedByUs{i} == droppedOn);
      incorrect = sum(blamedByUs{i} ~= droppedOn);
      filename =  sprintf('%s_%s_PerConnection_%d_%f.csv',...
          VigilResults,experimentType,k,p1);
      fileID = fopen(filename, 'w');
      fprintf(fileID, ...
          'correct, incorrect, total number of links, number of failed flows\n');
      fprintf(fileID, '%d,%d,%d,%d\n',...
          full(correct), full(incorrect),length(droppedOn), numfailed);
      fclose(fileID);
      
      correct = sum(blamedByBinary{i} == droppedOn);
      incorrect = sum(blamedByBinary{i} ~= droppedOn);
      filename = sprintf('%s_%s_PerConnection_%d_%f.csv',...
          BinaryOpt,experimentType,k,p1);
      fileID = fopen(filename, 'w');
      fprintf(fileID, 'correct , incorrect\n');
      fprintf(fileID, '%d,%d\n', full(correct),full(incorrect));
      fclose(fileID);
  
      correct = sum(blamedByInt{i} == droppedOn);
      incorrect = sum(blamedByInt{i} ~= droppedOn);
      filename = sprintf('%s_%s_PerConnection_%d_%f.csv',...
          IntegerOpt,experimentType,k,p1);
      fileID = fopen(filename, 'w');
      fprintf(fileID, 'correct, incorrect\n');
      fprintf(fileID, '%d,%d\n',full(correct), full(incorrect));
      fclose(fileID);
    

end
end








