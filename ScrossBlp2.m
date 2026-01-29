function out=ScrossBlp2(BBGDATA,mp,dp)

for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,1)),:)=[];%date
    temp(isnan(temp(:,2)),:)=[];%close
    %temp(isnan(temp(:,3)),:)=[];%volume
    temp(isnan(temp(:,4)),:)=[];%high
    temp(isnan(temp(:,5)),:)=[];%low
    temp(isnan(temp(:,6)),:)=[];%open
    
    if size(temp(:,1))<mp,
        t1=temp(end,2);
        t2=0;
    else
        t1=SCross(temp(:,2),ma(temp(:,2),mp));
        t2=Direction(temp(:,2));
    end
    
    
    tp=double((t1.*t2)>0);
    tm=double((t1.*t2)<0);
    
    if size(temp(:,1))<mp,
        tp=0;
        tm=0;
    else
        tp=max(tp(end-dp+1:end));
        tm=max(tm(end-dp+1:end));
    end
    
    
    out(i,:)=[tp tm];
    disp(i)
end
