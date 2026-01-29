function ext=ExtremeRangeBlp(BBGDATA,bp,bl)

for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,1)),:)=[];%date
    temp(isnan(temp(:,2)),:)=[];%close
    %temp(isnan(temp(:,3)),:)=[];%volume
    temp(isnan(temp(:,4)),:)=[];%high
    temp(isnan(temp(:,5)),:)=[];%low
    temp(isnan(temp(:,6)),:)=[];%open
    

    
    [outph,outsh]=ExtremeRange(temp(:,4),3,8,1);
    [outpl,outsl]=ExtremeRange(temp(:,5),3,8,-1);
    
    
    ext(i,:)=[outph outpl];
    
    clear out* temp
disp(i)
end
disp('Breakouts in 3 days computed!')