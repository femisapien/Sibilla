function [out,hfix]=BlpHolidayFix(BBGDATA,opt,cols,avg)

% opt=0;%delete last observation with all zeros
% opt=1;%repeat last valid observation
% opt=2;%fill last observation with means of last 5 days
% avg=5
% cols=5

for i=1:size(BBGDATA,2)
     temp=BBGDATA{1,i};
     t=sum(temp(end,:));
     if ismember(opt,[0,1,2])==0,opt=0; end
     if t==0
          if opt==0
               hfix='delete holiday';
          temp(end,:)=[];
          elseif opt==1
               hfix='repeat last valid observation';
               temp(end,1)=temp(end-1,1)+1;
          temp(end,2:end)=temp(end-1,2:end);
          elseif opt==2
               hfix='fill with 5 averages';
          temp(end,1)=temp(end-1,1)+1;
          temp(end,2:end)=nanmean(temp(end-avg-1:end-1,2:end));
          end
     end
     out{1,i}=temp;
     disp(i)
     clear temp
end
clear i