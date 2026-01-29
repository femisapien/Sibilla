function FindCross=FindCross(series,fv,sw)
%search for series crossing a fixed value, over a pre-specified window
%series is the test series
%fv is the value which upon the cross will be tested
%sw is the window where crosses will be searched for

temp=series-fv;
up=temp>=0;
down=temp<0;down=-1*down;
ind1=up+down;%assings positive indicator to series bigger than fv and negative indicator otherwise
clear up down temp

x=size(series,1);
if x<=sw-2,FindCross=[0 0];
else
ind2=zeros(x,1);%find signal reversals, represented by negative products
for i=2:size(ind2,1)
     ind2(i,1)=ind1(i)*ind1(i-1);
end
clear i

ind3=ind2<0;%assigns null to non reversals
ind4=ind1.*ind3;%product with original signal. If positive CROSS UP, if negative CROSS DOWN, otherwise, NULL.

sw=x-sw:1:x;%transform lenght in timely placed length

ind5=ind4(sw);
if isempty(find(ind5(:,1)~=0))==1
     FindCross=[0 0];
else temp=sw(find(ind5(:,1)~=0));ind6=ind5(find(ind5(:,1)~=0));
     FindCross=[temp(end) ind6(end)];
end
end

