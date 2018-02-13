
function [x,t]=optimizeV2(connectionList, status)
%code for the integer optimization problem.
%input: connectionlist: a matrix whose size is N (number of connections) by
% M (number of links). The matrix has a 1 in position (i,j) if connection i
% went through link j.
% status = The number of retransmisssions seen by each connection. its a N
% by 1 matrix.
%Output: x = 1 if link i is failed and 0 otherwise.
% t = the number of retransmissions that the optimization attributed to
% each link. its a M by 1 matrix.
% written by: Behnaz Arzani
pack


[m,n]=size(connectionList);
cvx_solver mosek
cvx_begin
variable p(n,1) integer;
variable a(n,1) binary;
variable t(1,n) integer;
%The formulation of the integer optimization is modified in order to
%formulate it as a convex problem.
%To minimize the norm 0 of p, we take advantage of the fact that the number
%of retransmissions encountered are bounded. This means that we can use the
%upper bound of the number of retransmissions to create an indicator variable a.
% we therefore use a binary variable a the norm 1 of a is equal to the norm
%0 or p, as a(i) is 1 if p(i) >0 and 0 otherwise. 
%sum(p)==sum(status) is the constraint that specifies that the total number
%of retransmissions allocated to each link should be equal to the total
%number of retransmissions observed.
%t captures the total number of retransmissions assigned to each link.
minimize ((norm(a,1))-0.0001*sum(t))
subject to
connectionList * p >=status;
(connectionList * diag(p))'* ones(m,1) >=t';
sum(p)==sum(status);
p<=6000*a;
p>=0;
cvx_end


if sum(status)~=0
    x=(t/sum(status)>=0.001);
else
    x=t;
end

