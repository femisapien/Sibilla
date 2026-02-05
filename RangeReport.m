
function [rangereportline,gap]=RangeReport(BBGDATA)
% version 1.1, nov-20-08
% included 5-day average range to identify gaps, at line 56


%"Range Report"
clear rangereportline

for i=1:size(BBGDATA,2);
%get data from one security
temp=BBGDATA{1,i};

%set the sample space to 80 days
temp(1:end-360,:)=[];

%create vectors and prevent nan's
%1
tdate=temp(:,1);nt1=find(isnan(tdate));
%2
tplast=temp(:,2);nt2=find(isnan(tplast));
%3
tpvolume=temp(:,3); 
nt3=find(isnan(tpvolume));
if sum(isnan(tpvolume))>=0.9*size(tpvolume,1)%sometimes zeros appear instead of NaN's
     tpvolume=zeros(size(temp,1),1);
     nt3=[];
end

%4
tphigh=temp(:,4);nt4=find(isnan(tphigh));
%5
tplow=temp(:,5);nt5=find(isnan(tplow));

nn=[nt1;nt2;nt3;nt4;nt5];
nn=unique(nn);%union of nan's in all vectors

tdate(nn,:)=[];
tplast(nn,:)=[];
tpvolume(nn,:)=[];
if size(tpvolume,1)<50
     tpvolume=zeros(55,1);
end
tphigh(nn,:)=[];
tplow(nn,:)=[];

clear nt* nn

trange=prange(tphigh,tplow,0);
if size(trange,1)<6
     avp=1;
elseif size(trange,1)<80
     avp=size(trange,1)-5;
else avp=80;
end

if or(isempty(trange)==1,size(trange,1)<6);avgr5d=0;else avgr5d=mean(trange(end-4:end,1));end
alpha=0.2; %parameter to identify gaps
if size(trange,1)>1,avgr80d=mean(trange(end-avp+1:end,1));elseif isempty(trange)==1,avgr80d=NaN;else avgr80d=trange;end

if avgr5d < alpha*avgr80d, gap(i,1)=1; else gap(i,1)=0;end
avgl25=avgr80d-.5*avgr80d;
avgp25=avgr80d+.5*avgr80d;

if isempty(trange)==0
if trange(end,1)>avgp25
   crange=trange(end,1)-avgp25;
elseif trange(end,1)<avgl25
     crange=trange(end,1)-avgl25;
else 
     crange=[];
end
else 
     crange=[];
end
%disp('Range Calculations: done!')
if size(tpvolume,1)<=50,x=size(tpvolume,1)-10;else x=50;end

tvcond=TestMACond(tpvolume,5,x,2);
if tvcond(end,1)==1
     cv='YES';
else
     cv=[];
end

mavol=ma(tpvolume,x);
volmadiff=(tpvolume(end)-mavol(end))/mavol(end);


if size(tplast,1)<90
     tvvol=0;
     else
     tvvol=vvol(tplast,50,252,3);
end
%disp('Volume Calculations: done!')
%disp(i)

if or(size(tphigh,1)<6,size(tplow,1)<6)
     OBar=0;
else
OBar=OutsideBar(tphigh,tplow,1);
end

if OBar(end,1)==1
     cob='YES';
else cob=[];
end
if isempty(trange)==1
     trange=0;
end
rangereportline(i,:)={trange(end,1) avgr80d trange(end,1)/avgr80d ...
                      crange cv volmadiff tpvolume(end) mavol(end) tvvol(end,1) cob};

clear temp tdate tp* trange avgr80d crange tvcond cv tvvol OBar cob avgl25 avgp25 avp volmadiff x
%disp(i)
end
clear i

%

% if size(BBGDATA,2)>500
%      type='Stocks';
% else
%      type='OtherSecs';
% end

%save(sprintf('C:/Users/Lorenzo/Documents/MATLAB/database/RangeReportDaily-%s-%s.mat',type,datestr(today)),'rangereportline');


