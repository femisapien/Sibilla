function ext=ExtremeRangeBlp2(BBGDATA,bp,bl)

for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,1)),:)=[];%date
    temp(isnan(temp(:,2)),:)=[];%close
    %temp(isnan(temp(:,3)),:)=[];%volume
    temp(isnan(temp(:,4)),:)=[];%high
    temp(isnan(temp(:,5)),:)=[];%low
    temp(isnan(temp(:,6)),:)=[];%open
    
    if size(temp(:,1))<bl
        outph=0;outsh=0;outpl=0;outsl=0;
        
    else
    [outph,outsh]=ExtremeRange(temp(:,4),bp,bl,1);
    [outpl,outsl]=ExtremeRange(temp(:,5),bp,bl,-1);
    end
    
    
    ext(i,:)=[outph outpl];
    
    clear out* temp
disp(i)
end