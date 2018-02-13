

function x = AddToVigilScore(x,n,count)
%This function adds a weighted score instead of a vanila score%
%The score/vote of each link is equal to 1/n where n is the number of hops along its path.
% The count is used to compute a different type of score where the score is in proportion to the number of 
% packets dropped on that link.
%Written By: Behnaz Arzani
	x.Object.vigilScore_=x.Object.vigilScore_+1.0/n;
	
        x.Object.reCountVigil=x.Object.reCountVigil+count*1.0/n;

end
