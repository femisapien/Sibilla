function out=OutsideBar(shigh,slow,g)
%verifies outside bar criterion using returns
%inputs are:
     %shigh, the first series, tipically high price
     %slow, the second series, tipically low price
     %g, the length used to compare both series
     
if length(shigh)~=length(slow),error('series have different sizes'),end

h=find(isnan(shigh));
l=find(isnan(slow));
hl=union(h,l);
shigh(hl,:)=[];
slow(hl,:)=[];
clear h l hl

rhigh=Returns(shigh,g,1);
rlow=Returns(slow,g,1);

signh=rhigh>0;
signl=rlow<0;

out=1.*signh.*signl;
