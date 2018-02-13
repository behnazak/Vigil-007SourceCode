function p=optimize(connectionList, status)
%the code for the binary optimization problem.
%connection list is an N (number of connections) by M (number of links)
%matrix. Where element (i,j) is 1 if connection i went through link j and 0
%otherwise.
%status = whether connection i experienced a packet drop or not. 
%Output = the list of failed links.
%written by: Behnaz Arzani

[m,n]=size(connectionList);
cvx_solver mosek
cvx_begin
variable p(n,1) binary;
minimize (norm(p,1))
subject to
connectionList * p >=status;
cvx_end
%
