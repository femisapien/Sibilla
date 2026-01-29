function [LONGline, LONGline2, SHORTline, SHORTline2,pLS,HLS2,SRSI]=RSIreport(BBGDATA)
%% runs RSI daily report and saves data for weekly report


clear DC SRSI indrsi 
%% SET PARAMETERS
b=360;%initial window to calculate
b2=80;%final window to report
mec=693960;%matlab2excel constant
rsip=14;%rsi parameter
lp=73;%long parameter
sp=25;%short parameter
cp=25;%index comparison parameter
fastdrop=58;%parameter to compare securitites which hit the long parameter and came back to 58 or lower
fastdbound=30;%bound to fast drop
fastrise=44;%parameter to compare securitites which hit the short parameter and went up to 44 or bigger
fastrbound=70;%bound to fast increase
seql=5;
hotp=20; %parameter for hot longs/shorts

%% CALCULATE INDEX RSI
tind=BBGDATA{1,1};%extracts data
tind(:,3:end)=[];%eliminates unuseful columns
tind(isnan(tind(:,2)),:)=[];%eliminates NaN's
tind(1:end-b,:)=[];%eliminates observations older than one year. substitute 360 by a variable
tindrsi=rsi(tind(:,2),rsip);%calculates rsi for index
inddate=tind(:,1)-mec;%adjusts to excel format
indrsi=[inddate tindrsi];%constructs matrix with dates and rsi
clear inddate tindrsi tind
indrsi(1:end-b2,:)=[];%clear unuseful dates
fdate=indrsi(:,1);%creates index of dates to cut the other secs below


%% CALCULATE RSI
for i=1:size(BBGDATA,2)
temp=BBGDATA{1,i};%extracts data
temp(1:end-b,:)=[];%eliminates observations older than one year. 
%temp(:,3:5)=[];%eliminates unuseful columns
temp(isnan(temp(:,2)),:)=[];%clear eventual NaN's
if size(temp(:,2),1)<rsip+2,
trsi=rsi(temp(:,2),size(temp(:,2),1)-3);%calculates rsi for index
else trsi=rsi(temp(:,2),rsip);
end
idate=temp(:,1)-mec;%set dates in excel format
trsi=[idate trsi temp(:,3) temp(:,4) temp(:,5)];%apply above's changes

SRSI{1,i}=trsi;

disp(i)
clear temp trsi dlist fp  ip irsi idate
end
clear i
disp('RSI Calculations done')

clear b db mec rsip fdate 


%% FIND OVERBOUGHT + OVERSOLD
%disp('find oldest matches (lp and sp)')
for q=1:size(SRSI,2)
temp=SRSI{1,q};
temp(:,3:end)=[];
if isempty(find(temp(:,2)>=lp))==1
     firstlong(q,1)=0;
else
     firstlong(q,1)=81-find(temp(:,2)>=lp,1);
end
if isempty(find(temp(:,2)<=sp))==1
     firstshort(q,1)=0;
else
     firstshort(q,1)=81-find(temp(:,2)<=sp,1);
end
clear temp
end
clear q


%disp('find rsi above 75')
for i=1:size(SRSI,2)
     temp=SRSI{1,i};%same extraction method
     temp(:,3:end)=[];
     TODAY(i,1)=temp(end,2);
     x=size(temp,1);%number of observations in each security
     a=b2-x+1:1:b2;a=a';%create distance from first observation, controlling eventual discrepancies in series lengths
     f=[temp temp(:,2)>=lp (b2+1)-a];%date // condition (0 or 1) // position relative to db
     f(find(f(:,3)==0),:)=[];
     if isempty(f)==1%if there's no obs meeting condition
          longpure(i,:)=NaN(1,3);%just put NaN's
     else
          longpure(i,:)=[f(end,1:2) f(end,4)];%else list last obs meeting condition
     end
     clear f ff temp x a     
end
clear i
disp('Search for longs  (>=73) done')

%find rsi below 25
for i=1:size(SRSI,2)
     temp=SRSI{1,i};
     temp(:,3:end)=[];
     x=size(temp,1);
     a=b2-x+1:1:b2;a=a';
     f=[temp temp(:,2)<=sp (b2+1)-a];
     f(find(f(:,3)==0),:)=[];
     if isempty(f)==1
          shortpure(i,:)=NaN(1,3);
     else
          shortpure(i,:)=[f(end,1:2) f(end,4)];
     end
     clear f ff temp x a     
end
clear i
disp('Search for shorts (<=25) done')
% % 

%% FAST DROP AND FAST RISE

l_drop=FastDropRise44(SRSI,1,60,60);
s_rise=FastDropRise44(SRSI,-1,60,60);

L_DROP=l_drop(:,1);
S_RISE=s_rise(:,1);
dfd=l_drop(:,2);
dfs=s_rise(:,2);
disp('Search for fasts (>=73+<=58-<=30 and <=25+>=44-<=70) done')


%% LONG INDEX (security's rsi minus index rsi above limit )
for i=1:size(SRSI,2)
     temp=SRSI{1,i};
     temp(:,3:end)=[];
     [dlist, indp, tempp]=intersect(indrsi(:,1),temp(:,1));%equalizes dates with index, since difference is required
     temp2=temp(tempp,:);%load security data in common dates
     tindrsi=indrsi(indp,:);%the same for index data
     x=size(temp2,1);%gets size, in case it is smaller than b2
     a=b2-x+1:1:b2;a=a';%creates artificial day count, in case security's matrix is smaller than b2. simply stars to count from the difference
     tdiff=[temp2(:,1) temp2(:,2)-tindrsi(:,2) (b2+1)-a];%dates //difference // day count
%      lt=length(temp2);
%      li=length(tindrsi);
%      ld=length(tdiff);
%      if lt==0,temp2=NaN(80,2);end
%      if li==0,tindrsi=NaN(80,1);end
%      if ld==0,tdiff=NaN(80,3);end
   
     TODAYDIFF(i,1)=temp2(end,2)-tindrsi(end,2);
     %TODAYDIFF(i,1)=temp2(lt,2)-tindrsi(li,2);%last difference
     [xv,xi]=max(temp2(:,2));%max security rsi
     MAXS(i,:)=[temp2(xi,1) temp2(xi,2) tdiff(xi,2)];%uses max position to get the other points
     f=[tdiff tdiff(:,2)>=cp];%check the index comparison limit
     f(find(f(:,4)==0),:)=[];%search for positive indicators
     if isempty(f)==1
          longindex(i,:)=NaN(1,4);
     else
          longindex(i,:)=f(end,:);%prints the results
          %[f(end,1:2) f(end,4)];
     end
     clear f ff temp* dlist indp tindrsi tdiff x a xi xv    
disp(i)
end
clear i
disp('Search for longs  relative to index done')

%% SHORT INDEX (find index rsi minus security rsi above limit) 
for i=1:size(SRSI,2)
     temp=SRSI{1,i};
     temp(:,3:end)=[];
     [dlist, indp, tempp]=intersect(indrsi(:,1),temp(:,1));
     temp2=temp(tempp,:);
     tindrsi=indrsi(indp,:);  
     x=size(temp2,1);
     a=b2-x+1:1:b2;a=a';     
     tdiff=[temp2(:,1) tindrsi(:,2)-temp2(:,2) (b2+1)-a];
      lt=length(temp2);
     li=length(tindrsi);
     ld=length(tdiff);
     if lt==0,temp2=NaN(80,2);end
     if li==0,tindrsi=NaN(80,1);end
     if ld==0,tdiff=NaN(80,3);end
     [xv,xi]=min(temp2(:,2));
     MINS(i,:)=[temp2(xi,1) temp2(xi,2) tdiff(xi,2)];
     f=[tdiff tdiff(:,2)>=cp];
     f(find(f(:,4)==0),:)=[];
     if isempty(f)==1
          shortindex(i,:)=NaN(1,4);
     else
          shortindex(i,:)=f(end,:);%[f(end,1:2) tmec-f(end,1)];
     end
     clear f ff temp* dlist indp tindrsi tdiff x a xv xi    
     disp(i)
end
clear i
disp('Search for shorts relative to index done')



%% HOT LONG + HOT SHORT
for q=1:size(SRSI,2)
     temp=SRSI{1,q};
     temp(:,3:end)=[];
%      temp=temp(:,2);
     hotlong(q,:)=HotLongShort(temp,hotp,6,lp);
     hotshort(q,:)=HotLongShort(temp,hotp,4,sp);
     clear temp
end
clear q
hotlong=hotlong.*(1-double(shortpure(:,1)>0)).*hotlong(:,2);
hotshort=hotshort.*(1-double(longpure(:,1)>0)).*hotshort(:,2);
% 
% %hot longs and shorts for mean revrsion - different limits
% for q=1:size(SRSI,2)
%      temp=SRSI{1,q};
%      temp(:,3:end)=[];
% %      temp=temp(:,2);
%      hotlong2(q,:)=HotLongShort(temp,5,6,70);
%      hotshort2(q,:)=HotLongShort(temp,5,4,30);
%      clear temp
% end
% clear q
% hotlong2=hotlong2.*(1-double(shortpure(:,1)>0));
% hotshort2=hotshort2.*(1-double(longpure(:,1)>0));
% 
% HLS2=[hotlong2 hotshort2];


L_DROP=L_DROP.*double(TODAY<=fastdrop);
dfd=dfd.*double(TODAY<=fastdrop);
S_RISE=S_RISE.*double(TODAY>=fastrise);     
dfs=dfs.*double(TODAY>=fastrise); 


LONGline= [TODAY TODAYDIFF longpure  shortpure longindex  MAXS];
LONGline2= [hotlong(:,1) L_DROP dfd TODAY TODAYDIFF longpure(:,1) longpure(:,3)  shortpure(:,1) ...
            shortpure(:,3) longindex(:,1) longindex(:,3)  MAXS ];
pointslong=~isnan(LONGline2(:,6))+~isnan(LONGline2(:,10));       

SHORTline=[TODAY (-1)*TODAYDIFF shortpure longpure  shortindex MINS];
SHORTline2=[hotshort(:,1) S_RISE dfs TODAY (-1)*TODAYDIFF shortpure(:,1) shortpure(:,3) ...
            longpure(:,1) longpure(:,3)  shortindex(:,1) shortindex(:,3) MINS ];
pointsshort=~isnan(SHORTline2(:,6))+~isnan(SHORTline2(:,10));    



FASTS=[double(L_DROP>0) double(S_RISE>0)];

pLS=[pointslong pointsshort];
pLS=pLS+FASTS;
pLS2=[min(ones(size(pLS,1),1),pLS(:,1)) min(ones(size(pLS,1),1),pLS(:,2))] ;
clear points*

clear cp lp sp  b2

if size(BBGDATA,2)>500
     type='Stocks';
else
     type='OtherSecs';
end

