function out=DeleteWeekends(BBGDATA)

for i=1:size(BBGDATA,2)
     temp=BBGDATA{1,i};
     %saturday==7
     temp2=weekday(temp(:,1));
     temp3=temp2-7;%the saturdays will be zero. All other will be positive
     temp4=find(temp3(:,1)==0);
     if length(temp4)~=0
     temp(temp4,:)=[];
     end
     clear temp3 temp4
     %sunday==1
     temp3=temp2-1;
     temp4=find(temp3(:,1)==0);
     if length(temp4)~=0
     temp(temp4,:)=[];
     end
     out{1,i}=temp;
     clear temp*;
     %disp(i)
end
clear i