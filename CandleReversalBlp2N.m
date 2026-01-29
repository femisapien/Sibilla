function REV=CandleReversalBlp2N(BBGDATA,tol1,tol2)
%tol1 is for LoneStarr 
%tol2 is for ShootingStar

for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,1)),:)=[];%date
    temp(isnan(temp(:,2)),:)=[];%close
    %temp(isnan(temp(:,3)),:)=[];%volume
    temp(isnan(temp(:,4)),:)=[];%high
    temp(isnan(temp(:,5)),:)=[];%low
    temp(isnan(temp(:,6)),:)=[];%open
    
    out1=CloudCover(temp(:,6),temp(:,4),temp(:,5),temp(:,2));
    out2=Engulfing(temp(:,6),temp(:,4),temp(:,5),temp(:,2));
    out3=LoneStar(temp(:,6),temp(:,4),temp(:,5),temp(:,2),1);
    out4=ShootingStar(temp(:,6),temp(:,4),temp(:,5),temp(:,2),1);
    
    
   b=double(out1==1)+double(out2==1)+double(out3==1)+double(out4==1);
   s=double(out1==-1)+double(out2==-1)+double(out3==-1)+double(out4==-1);
   
   
   REV{1,i}=[b s];
   clear temp out* b s
    
    
    clear temp out
    
    disp(i)
end
