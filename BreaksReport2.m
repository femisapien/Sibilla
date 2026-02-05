function out=BreaksReport2(BBGDATA,x)


for i=1:size(BBGDATA,2)
     temp=BBGDATA{1,i};
     temp(isnan(temp(:,2)),:)=[];%clear eventual NaN's
     temp(isnan(temp(:,4)),:)=[];%clear eventual NaN's
     temp(isnan(temp(:,5)),:)=[];%clear eventual NaN's
        
     
     if size(temp,1)<=x+0.2*x
          temp=zeros(2*x,size(temp,2));
     end
     
 %cut the series to x+20%
x1=x+0.2*x;
sh=size(temp,1);
dh=sh-x1;
if dh>0
    temp(1:dh,:)=[];
end
    
     
     thigh=temp(:,4);%thigh=thigh(~isnan(thigh));
     tlow=temp(:,5);%tlow=tlow(~isnan(tlow));
     
     tbhigh=[temp(:,1) FindBreaks(thigh,x,2,1)];
     tbhigh=tbhigh(find(tbhigh(:,2)>0),:);if isempty(tbhigh)==1,tbhigh=[693960 0];end
     tblow=[temp(:,1) FindBreaks(tlow,x,2,-1)];
     tblow=tblow(find(tblow(:,2)==1),:);if isempty(tblow)==1,tblow=[693960 0];end
     out(i,:)=[tbhigh(end,1)-693960 tbhigh(end,2) tblow(end,1)-693960 tblow(end,2)];
     clear t*
     %disp(i)
end
clear i
