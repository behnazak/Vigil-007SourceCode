function obj=AddFailedToObj(x,foundDrop,count)
%%
%Inputs x --> an object to add failure to
%foundDrop --> an indicator of whether or not a drop should be added
%count -->currently unused
%%
if foundDrop
    x.Object=x.Object.addFailed();
end
obj=x;
