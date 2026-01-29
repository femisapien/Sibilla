function out=AD2(BBGDATA,range1,range2)


for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,1)),:)=[];%date
    temp(isnan(temp(:,2)),:)=[];%close
    temp(isnan(temp(:,3)),:)=[];%volume
    temp(isnan(temp(:,4)),:)=[];%high
    temp(isnan(temp(:,5)),:)=[];%low
    temp(isnan(temp(:,6)),:)=[];%open
    
    if length(temp)<range1+3
        A_diff=0;
        D_diff=0;
    else
    temp_old=temp(1:end-range1+1,:);
    [x1, x2, AO_old, x3, x4, x5]=ADHO(temp_old(:,1),temp_old(:,2),temp_old(:,6),temp_old(:,3),13,range2-range1);
    [x6, x7, DO_old, x8, x9, x0]=DDHO(temp_old(:,2),temp_old(:,6),temp_old(:,3),13,range2-range1);
    clear x*
    
    [x1, x2, AO_new, x3, x4, x5]=ADHO(temp(:,1),temp(:,2),temp(:,6),temp(:,3),13,range1);
    [x6, x7, DO_new, x8, x9, x0]=DDHO(temp(:,2),temp(:,6),temp(:,3),13,range1);
    clear x*
    
    A_diff=100*(AO_new-AO_old)./AO_old;
    D_diff=100*(DO_new-DO_old)./DO_old;
    end
    
    out(i,:)=[A_diff D_diff];
    
    clear temp* A* D*
    
    %disp(i)
    
end
out(find(out==inf))=0;
disp('Acc/Dist Computed!')