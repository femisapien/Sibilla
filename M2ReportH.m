function [m2i, m2l, rsi_wm, m2i_spec]=M2Report(BBGDATA)
rsipw=5;%rsi 5 weeks
rsipm=14;%rsi 14 months
rsiwI=16;%intermediate 16 weeks
rsiwL=40;%%long 40 weeks
rsimI=6;%intermediate 6 months
rsimL=14;% long 14 months
lrsiwIb=20;%limit to buy intermediate weekly
lrsiwIs=80;%limit to sell intermediate weekly
lrsiwLb=20;%limit to buy long weekly
lrsiwLs=80;%limit to sell long weekly
lrsimIb=32;%limit to buy intermediate monthly
lrsimIs=75;%limit to sell intermediate monthly
lrsimLb=32;%limit to buy long monthly
lrsimLs=70;%limit to sell long monthly
map=200;%parameter for moving average daily
wI=20;% window to look m.a intermediate
wL=60;% window to look m.m long

s1=1;%100% above m.a - sell
s2=1.3;%130% above m.a - sell
s3=1.6;%130% above  m.a - sell
b1=-0.4;%40% below m.a - buy
b2=-0.5;%50% below m.a - buy
b3=-0.6;%60% below m.a - buy
pma1=0.5;% 0.5 point for verifying b1/s1
pma2=1.0;% 1.0 point for verifying b2/s2
pma3=1.5;% 1.5 point for verifying b3/s3
papL=2/7;%2/7 point for each each down - long
papI=1/7;%1/7 point for each year down - intermediate
prpL=1/7;%1/7 point for being worst 20% performer on each year - long
prpI=2/7;%2/7 point for being worst 20% performer on each year - intermediate
prsiwL=0.75;%0.75 point for rsi 5 weeks - long
prsiwI=0.75;%0.75 point for rsi 5 weeks - intermediate
prsimL=0.75;%0.75 point for rsi 14 months - long
prsimI=0.75;%0.75 point for rsi 14 months - intermediate

%MA Part
tollma=map+wL;
%toll is 260 days. 200 for moving average and 60 for comparisons. set by m.a window plus longer window to look

for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,2)),:)=[];
    if size(temp,1)<=tollma
        compL(:,i)=zeros(wL,1);
        compI(:,i)=zeros(wI,1);
    else
        macomp=ma(temp(:,2),map);
        compL(:,i)=(temp(end-wL+1:end,2)-macomp(end-wL+1:end,1))./macomp(end-wL+1:end,1);
        compI(:,i)=(temp(end-wI+1:end,2)-macomp(end-wI+1:end,1))./macomp(end-wI+1:end,1);
    end
    clear temp macomp
    %disp(i)
end
clear i

for i=1:size(compL,2)
cLb(i,1)=min(compL(:,i));
cLs(i,1)=max(compL(:,i));
end
clear i

for i=1:size(compI,2)
cIb(i,1)=min(compI(:,i));
cIs(i,1)=max(compI(:,i));
end
clear i
    
checkLb=[pma1.*double(cLb<b1) pma2.*double(cLb<b2) pma3.*double(cLb<b3)];
Lb1=max(checkLb,[],2);

checkLs=[pma1.*double(cLs>s1) pma2.*double(cLs>s2) pma3.*double(cLs>s3)];
Ls1=max(checkLs,[],2);
    
checkIb=[pma1.*double(cIb<b1) pma2.*double(cIb<b2) pma3.*double(cIb<b3)];
Ib1=max(checkIb,[],2);

checkIs=[pma1.*double(cIs>s1) pma2.*double(cIs>s2) pma3.*double(cIs>s3)];
Is1=max(checkIs,[],2);

%PERFORMANCE Part
%file created with the scripts yearly.m (to download bloomberg data, once a
% year) and scrap_annuals.m (to treat the data). REMEMBER TO UPDATE FIRST
% AND LAST YEAR
load('G:\101510\database\lists\T250_yearly_data_2011.mat');
clear tp2 tm2 BY RBY ys BBGDATAY

for i=1:size(BBGDATA,2)
    last_new(i)=BBGDATA{1,i}(end,2);
end
clear i

ret_new=(last_new-last_old)./last_old;

z=ret_new;
z=[ind';z];
z=z';
z2=sortrows(z,2);
z2=z2(~isnan(z2(:,2)),:);
lup=floor(size(z2,1)*0.2);%worst performers
ldw=floor(size(z2,1)*0.8);%best performers
bottom=z2(1:lup,1);
top=z2(ldw:end,1);

i2b=[ind zeros(size(ind))];
for j=1:size(bottom,1)
    i2b(find(i2b(:,1)==bottom(j)),2)=1;
end
clear j
    
B1n(:,1)=i2b(:,2);
    
i2s=[ind zeros(size(ind))];
for j=1:size(top,1)
    i2s(find(i2s(:,1)==top(j)),2)=1;
end
clear j
    
S1n(:,1)=i2s(:,2);
    
clear z* lup ldw bottom top i2b i2s

B1=[B1 B1n];B1=sum(B1,2);
S1=[S1 S1n];S1=sum(S1,2);

tnan2n=double(isnan(ret_new));%number of years with no data for all stocks
tp2n=double(ret_new>=0);%number of of years with positive returns for all stocks - sell
tm2n=double(ret_new<0);%number of of years with negative returns for all stocks - buy

B2=B2+tm2n';
S2=S2+tp2n';

clear B1n S1n tp2n tm2n

Lb2=papL.*B1+prpL.*B2;%performance part, long term
Ls2=papL.*S1+prpL.*S2;

Ib2=papI.*B1+prpI.*B2;%performance part, intermediate
Is2=papI.*S1+prpI.*S2;


%RSI WEEKLY Part
for j=1:size(BBGDATA,2)
temp=BBGDATA{1,j};%create one temp matrix for each security
temp=temp(~isnan(temp(:,2)),1:2);
temproll=temp(find(weekday(temp(:,1))==weekday(temp(end,1))),:);
clear temp

if size(temproll,1)<65
     temprollrsi=NaN(size(temproll));
else
temprollrsi=rsi(temproll(:,2),rsipw);
end
idate=temproll(:,1)-693960;%set dates in excel format
trsi=[idate temprollrsi];%apply above's changes
if size(trsi,1)<rsiwL
       rsiwLb(j,1)=0;
       rsiwLs(j,1)=0;
else   rt=trsi(end+1-rsiwL:end,2);
       rsiwLb(j,1)=max(double(rt<lrsiwLb));
       rsiwLs(j,1)=max(double(rt>lrsiwLs));
end
clear rt

if size(trsi,1)<rsiwI
       rsiwIb(j,1)=0;
       rsiwIs(j,1)=0;
       
else   rt=trsi(end+1-rsiwI:end,2);
       rsiwIb(j,1)=max(double(rt<lrsiwIb));
       rsiwIs(j,1)=max(double(rt>lrsiwIs));
end
rw(j,1)=trsi(end,2);
clear rt

clear temproll* trsi
end
clear j

Lb3=prsiwL.*rsiwLb;%rsi weekly part - long
Ls3=prsiwL.*rsiwLs;

Ib3=prsiwI.*rsiwIb;%rsi weekly part - intermediate
Is3=prsiwI.*rsiwIs;


%RSI MONTHLY Part
for j=1:size(BBGDATA,2)
temp=BBGDATA{1,j};%extracts data
temp(:,3:5)=[];%eliminates unuseful columns
temp(isnan(temp(:,2)),:)=[];%clear eventual NaN's
days=day(temp(:,1));%gets dates to cut
for i=2:size(days,1),if days(i-1)>days(i),di(i-1,1)=1;else di(i-1,1)=0;end;end;%identify last day of the month
di=find(di(:,1)==1);
di=[di;size(temp,1)];%last 1 is for today
clear i 
temp=temp(di,:);
clear di days
if size(temp,1)<30
     trsi=NaN(size(temp));
else trsi=rsi(temp(:,2),rsipm);
end
idate=temp(:,1)-693960;%set dates in excel format
trsi=[idate trsi];%apply above's changes

if size(trsi,1)<rsimL
       rsimLb(j,1)=0;
       rsimLs(j,1)=0;
else   rt=trsi(end+1-rsimL:end,2);
       rsimLb(j,1)=max(double(rt<lrsimLb));
       rsimLs(j,1)=max(double(rt>lrsimLs));
end

clear rt

if size(trsi,1)<rsimI
       rsimIb(j,1)=0;
       rsimIs(j,1)=0;
else   rt=trsi(end+1-rsimI:end,2);
       rsimIb(j,1)=max(double(rt<lrsimIb));
       rsimIs(j,1)=max(double(rt>lrsimIs));
end
rm(j,1)=trsi(end,2);
clear rt

clear temproll* trsi temp trsi idate 
end
clear j


Lb4=prsimL.*rsimLb;%rsi monthly part - long
Ls4=prsimL.*rsimLs;

Ib4=prsimI.*rsimIb;%rsi monthly part - intermediate
Is4=prsimI.*rsimIs;

LB=Lb1+Lb2+Lb3+Lb4;
LS=Ls1+Ls2+Ls3+Ls4;
IB=Ib1+Ib2+Ib3+Ib4;
IS=Is1+Is2+Is3+Is4;

m2l=[LB LS];
m2i=[IB IS];
rsi_wm=[rw rm];
m2i_spec=[Ib1 Ib2 Ib3 Ib4 Is1 Is2 Is3 Is4];
