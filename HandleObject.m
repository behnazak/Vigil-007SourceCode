%creates a pointer like object in matlab.
classdef HandleObject < handle
   properties
      Object=[];
   end
 
   methods
      function obj=HandleObject(receivedObject)
         obj.Object=receivedObject;
      end
   end
end