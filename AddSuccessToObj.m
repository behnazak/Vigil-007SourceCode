%%If no drop is found on this object mark success on it.

function x=AddSuccessToObj(x,foundDrop)
 if ~foundDrop
    x.Object=x.Object.addSuccess();
 end
end
