%this is the link class.
%Written by: Behnaz Arzani
classdef LinkInfo
    properties
        score_ = 0;
        numSeen_ = 0;
        numHadRetransmit_ = 0;
        source_ = nan;
        dest_ = nan;
        failed_=false;
        connInfo= ConnectionInfo;
        dropRate_ = 0;
	    vigilScore_=0;
        reCountVigil=0;     
    end
    methods
        function obj=setSource(obj,source)
            obj.source_=source;
        end
        function obj=setDest(obj,dest)
            obj.dest_=dest;
        end
        function obj=addFailed(obj)
            obj.numHadRetransmit_=obj.numHadRetransmit_+1;
            obj.numSeen_=obj.numSeen_+1;
        end
        function obj=addSuccess(obj)
            obj.numSeen_=obj.numSeen_+1;
        end
        function obj=markAsFailed(obj)
            obj.failed_=true;
        end
        function obj=computeScore(obj)
            if obj.numSeen_==0
                return;
            end
            if obj.connInfo.Sample
              obj.numSeen_=(obj.numSeen_-obj.numHadRetransmit_)*100/15.0+...
                  obj.numHadRetransmit_;
            end
          obj.score_ = obj.numHadRetransmit_*1.0/obj.numSeen_;
        end
        function res=eq(obj,comp)
            res=true;
            if obj.source_~=comp.source_
                res=false;
            else if obj.dest_~=comp.dest_
                    res=false;
                end
            end
        end
    end
end


