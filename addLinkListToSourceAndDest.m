%
% adds the topology to the source and destination objects of a given link
% x -> A link
%LinkList --> A list of all links in the topology
%
function x=addLinkListToSourceAndDest(x,LinkList)
    x.Object.source_.Object.LinkList_=LinkList;
    x.Object.dest_.Object.LinkList_=LinkList;
end
