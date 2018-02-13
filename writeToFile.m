function x=writeToFile(x,myfile)
    %write the results of Vigil/007 to a file.
    %x is the link object.
    %it writes the index of the source object, the type of source object.
    %the index of the destination object, the type of destination object.
    %three types of scores, retransmitcount (total number of
    %retransmissions).
    % the score that is used by vigil,
    % and a different score which is based on the actual number of
    % retransmissions.
    %written by: Behnaz Arzani
    if x.Object.source_.Object.type_==deviceType.ToR && x.Object.dest_.Object.type_==deviceType.T1
            source=x.Object.source_;
            dest=x.Object.dest_;
            score=x.Object.score_;
            retransmitCount=x.Object.numHadRetransmit_ ;
            vigil=x.Object.vigilScore_;
	    newVigilScore=x.Object.reCountVigil;
	    fprintf(myfile,'%d,ToR,%d,T1,%f, %f,%f, %f\n',source.Object.Name_,...
            dest.Object.Name_,score,retransmitCount,vigil,newVigilScore);
            return
    end
    if x.Object.source_.Object.type_==deviceType.T1 && x.Object.dest_.Object.type_==deviceType.T2
        source=x.Object.source_;
            dest=x.Object.dest_;
            score=x.Object.score_;
             retransmitCount=x.Object.numHadRetransmit_ ;
            Vigil=x.Object.vigilScore_;
	    newVigilScore=x.Object.reCountVigil;
	    fprintf(myfile,'%d,T1,%d,T2,%f, %f, %f,%f\n',source.Object.Name_,...
            dest.Object.Name_,score,retransmitCount,Vigil,newVigilScore);
            return
    end
    if x.Object.source_.Object.type_==deviceType.T2 && x.Object.dest_.Object.type_==deviceType.T1
            source=x.Object.source_;
            dest=x.Object.dest_;
            score=x.Object.score_;
             retransmitCount=x.Object.numHadRetransmit_ ;
	    Vigil=x.Object.vigilScore_;
	    newVigilScore=x.Object.reCountVigil;
            fprintf(myfile,'%d,T2,%d,T1,%f, %f, %f,%f\n',source.Object.Name_,...
                dest.Object.Name_,score,retransmitCount,Vigil,newVigilScore);
            return
    end
    if x.Object.source_.Object.type_==deviceType.T1 && x.Object.dest_.Object.type_==deviceType.ToR
        source=x.Object.source_;
        dest=x.Object.dest_;
        score=x.Object.score_;
         retransmitCount=x.Object.numHadRetransmit_ ;
        Vigil=x.Object.vigilScore_;
	newVigilScore=x.Object.reCountVigil; 
	fprintf(myfile,'%d,T1,%d,ToR,%f, %f, %f, %f\n',source.Object.Name_,...
        dest.Object.Name_,score,retransmitCount, Vigil,newVigilScore);
        return;
    end
    if x.Object.source_.Object.type_==deviceType.ToR && x.Object.dest_.Object.type_==deviceType.Host
        source=x.Object.source_;
        dest=x.Object.dest_;
        score=x.Object.score_;
         retransmitCount=x.Object.numHadRetransmit_ ;
        Vigil=x.Object.vigilScore_;
	 newVigilScore=x.Object.reCountVigil;
	fprintf(myfile,'%d,ToR,%d,Host,%f, %f, %f,%f\n',source.Object.Name_,...
        dest.Object.Name_,score, retransmitCount,Vigil,newVigilScore);
        return
    end
    if x.Object.source_.Object.type_==deviceType.Host && x.Object.dest_.Object.type_==deviceType.ToR
        source=x.Object.source_;
        dest=x.Object.dest_;
        score=x.Object.score_;
         retransmitCount=x.Object.numHadRetransmit_ ;
        Vigil=x.Object.vigilScore_;
	newVigilScore=x.Object.reCountVigil;
        fprintf(myfile,'%d,Host,%d,ToR,%f, %f, %f,%f\n',source.Object.Name_,...
            dest.Object.Name_,score, retransmitCount,Vigil,newVigilScore);
    end
end
