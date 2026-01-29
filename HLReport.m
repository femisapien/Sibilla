function out=HLReport(BBGDATA,range)
%find highs and lows over a period

for i=1:size(BBGDATA,2)
     temp=BBGDATA{1,i};
     temp(isnan(temp(:,2)),:)=[];%clear eventual NaN's
     temp(isnan(temp(:,4)),:)=[];%clear eventual NaN's
     temp(isnan(temp(:,5)),:)=[];%clear eventual NaN's
    
     dates=temp(:,1);
     highs=temp(:,4);
     lows=temp(:,5);
     hli(i,:)=FindHighLow(highs,lows,dates,range);
     clear highs lows dates temp
end
clear i

out=hli;