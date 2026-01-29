function RL2=WeeklyReportNew(BBGDATA)
%clear temp* SERIES*
%clc

if size(BBGDATA,2)>700
   for q=1:size(BBGDATA,2)
       temp=BBGDATA{1,q};
       temp(1:end-360,:)=[];
       b{1,q}=temp;
       clear temp
   end, clear q

  clear  BBGDATA
  BBGDATA=b;
  clear b
end
%disp('Size adjustment: done.')

for i=1:size(BBGDATA,2)
     

     

temp=BBGDATA{1,i};%create one temp matrix for each security
temp=temp(~isnan(temp(:,2)),1:2);
if size(temp(find(weekday(temp(:,1))==6),:),1)<1
     tempfri=temp(find(weekday(temp(:,1))==1),:);%abu dhabi people don't work on friday's but they do on sundays...
else tempfri=temp(find(weekday(temp(:,1))==6),:);%create submatrix for weekly observations, fixing on fridays
end
temproll=temp(find(weekday(temp(:,1))==weekday(today)),:);%the same but rolling days
lastprice=temp(end,2);%get last price to compare with ma13 and ma30

[m1, s, m2]=macdx(tempfri(:,2),12,26,9);tempfrimacd=m2;clear m1 m2 s%calculate macd
%corrects eventual lack of data for short series
if length(tempfrimacd)==1,%just one observation, repeat it
     tempfrimacd=[tempfrimacd;tempfrimacd];
end

if length(tempfrimacd)==2%two observations, repeat most recent
     tempfrimacd=[tempfrimacd(1);tempfrimacd(2);tempfrimacd(2)];
end
%%%
%same for rolling macd
[m1, s, m2]=macdx(temproll(:,2),12,26,9);temprollmacd=m2;clear m1 m2 s
if length(temprollmacd)==1,
     temprollmacd=[temprollmacd;temprollmacd];
end

if length(temprollmacd)==2
     temprollmacd=[temprollmacd(1);temprollmacd(2);temprollmacd(2)];
end
%%%

%get macd direction
if tempfrimacd(end-2)<0&&tempfrimacd(end-1)>=0
     tempfrimacdsig(1)=1;
     tmacdft1{1,1}='BUY';
     elseif tempfrimacd(end-2)>0&&tempfrimacd(end-1)<=0
     tempfrimacdsig(1)=-1;
     tmacdft1{1,1}='SELL';
else tempfrimacdsig(1)=0;
     tmacdft1{1,1}=[];
end

if tempfrimacd(end-1)<0&&tempfrimacd(end)>=0
     tempfrimacdsig(2)=1;
     tmacdft2{1,1}='BUY';
elseif tempfrimacd(end-1)>0&&tempfrimacd(end)<=0
     tempfrimacdsig(2)=-1;
     tmacdft2{1,1}='SELL';
else tempfrimacdsig(2)=0;
     tmacdft2{1,1}=[];
end

%if no cross then count direction
if tempfrimacdsig(2)==0&&tempfrimacdsig(1)==0
     if tempfrimacd(end)>0
          MSDF=.5;
     elseif tempfrimacd(end)<0
          MSDF=-.5;
     else MSDF=0;
     end
else MSDF=0;
end

%%%

if temprollmacd(end-2)<0&&temprollmacd(end-1)>=0
     temprollmacdsig(1)=1;
     tmacdrt1{1,1}='BUY';
elseif temprollmacd(end-2)>0&&temprollmacd(end-1)<=0
     temprollmacdsig(1)=-1;
     tmacdrt1{1,1}='SELL';
else temprollmacdsig(1)=0;
     tmacdrt1{1,1}=[];
end

if temprollmacd(end-1)<0&&temprollmacd(end)>=0
     temprollmacdsig(2)=1;
     tmacdrt2{1,1}='BUY';
elseif temprollmacd(end-1)>0&&temprollmacd(end)<=0
     temprollmacdsig(2)=-1;
     tmacdrt2{1,1}='SELL';
else temprollmacdsig(2)=0;
     tmacdrt2{1,1}=[];
end

%if no cross then count direction
if temprollmacdsig(2)==0&&temprollmacdsig(1)==0
     if temprollmacd(end)>0
          MSDR=.5;
     elseif temprollmacd(end)<0
          MSDR=-.5;
     else MSDR=0;
     end
else MSDR=0;
end

%disp('MACD calculations: done.')

% %calculate ma 13 days
if size(temp,1)<15,
     tempdma13=[0;0;0];
else tempdma13=ma(temp(:,2),13);
end

tempdma13dir=tempdma13(end)-tempdma13(end-1);
tempma13crossd=FindCross(temp(:,2),tempdma13(end),5);
if tempma13crossd(1)~=0,tempma13crossd(1)=temp(tempma13crossd(1),1)-693960;end
if tempma13crossd(2)>0
     tma13dct='UP';
elseif tempma13crossd(2)<0
     tma13dct='DOWN';
else 
     tma13dct='.';
end
%points for ma 13 days 
ma13ddcbuy=(double(tempdma13dir>0)+double(tempma13crossd(2)>0))/2;
ma13ddcsell=(double(tempdma13dir<0)+double(tempma13crossd(2)<0))/2;

%calculate ma  weekly

%13 weeks
if size(tempfri,1)<15,
     tempfrima13=[0;0;0];
else tempfrima13=ma(tempfri(:,2),13);
end

lpc13=lastprice-tempfrima13(end);

%30 weeks
if size(tempfri,1)<32,
   tempfrima30=[0;0;0];  
else tempfrima30=ma(tempfri(:,2),30);
end

lpc30=lastprice-tempfrima30(end);

tempfrima13dir=tempfrima13(end)-tempfrima13(end-1);
if tempfrima13dir>0,
     tfma13dt='UP';
elseif tempfrima13dir<0,
     tfma13dt='DOWN';     
else 
    tfma13dt='UNCHANGED';  
end

tempfrima30dir=tempfrima30(end)-tempfrima30(end-1);
if tempfrima30dir>0,
     tfma30dt='UP';
elseif tempfrima30dir<0,
     tfma30dt='DOWN';     
else 
    tfma30dt='UNCHANGED';  
end


tempma13cross=FindCross(temp(:,2),tempfrima13(end),5);
if tempma13cross(1)~=0,tempma13cross(1)=temp(tempma13cross(1),1)-693960;end
if tempma13cross(2)>0
     tma13ct='UP';
elseif tempma13cross(2)<0
     tma13ct='DOWN';
else 
     tma13ct='.';
end

tempma30cross=FindCross(temp(:,2),tempfrima30(end),5);
if tempma30cross(1)~=0,tempma30cross(1)=temp(tempma30cross(1),1)-693960;end
if tempma30cross(2)>0
     tma30ct='UP';
elseif tempma30cross(2)<0
     tma30ct='DOWN';
else 
     tma30ct='.';
end

%disp('MA 13 and MA 30 calculations: done.')

if size(tempfri,1)<10
     tempfrirsi=NaN(size(tempfri));
else
tempfrirsi=rsi(tempfri(:,2),5);
end

% % tempfrirsialert90=tempfrirsi>=90;
% % 
% % tempfrirsialert10=tempfrirsi<=10;
% % 
% % 
% % tempfrirsi=[tempfrirsi tempfrirsialert10 tempfrirsialert90];
% 
% 
% 
% 
%disp('RSI 5 weeks calculations: done.')

tempALL={tempfri(:,1)-693960 tempfri(:,2) tempfrimacd tmacdft1 tmacdft2 ...
         temprollmacd tmacdrt1 tmacdrt2 tempfrima13 tempfrima30};% tempfrirsi};
         %tfrsit10 tfrsit90}; % temprollrsi trrsit10 trrsit90};


tempLAST=[...
     tempfri(end,1)-693960 ...%1. last friday                                   *** 1
     tempfri(end,2) ...%2. price last priday                                    *** 2
     tempfrimacd(end) ...%3. macd fri signal most recent                        *** 3
     tempfrimacd(end-1)...%4. macd fri signal previous                          *** 4
     tempfrimacd(end-2) ...%5. macd fri signal 2 weeks ago                      *** 5
     tempfrimacdsig ...%6. numeric signal fri (2 columns)                       *** 6                 
     tmacdft1 ...%7. name signal 1 fri                                          *** 7   p1
     tmacdft2 ...%8. name signal 2 fri                                          *** 8   
     temprollmacd(end) ...%9. macd roll signal most recent                      *** 9
     temprollmacd(end-1) ...%10. macd roll signal previous                      *** 10
     temprollmacd(end-2) ...%11. macd roll signal 2 weeks ago                   *** 11
     temprollmacdsig ...%12. numeric signal roll (2 columns)                    *** 12
     tmacdrt1 ...%13. name signal 1 roll                                        *** 13  p2
     tmacdrt2 ...%14. name signal 2 roll                                        *** 14  
     tempfrima13(end) ...%15. ma 13                                             *** 15
     tempfrima13dir ...%16. ma 13 numerical dir                                 *** 16  
     tfma13dt ...%17. ma 13 name dir                                            *** 17  p3
     tempma13cross(1) ...%18. ma 13 numerical cross date                        *** 18
     tempma13cross(2) ...%19. ma 13 numerical cross numerical sign              *** 19
     tma13ct ...%20. ma 13 name cross                                           *** 20  p4
     tempfrima30(end) ...%21. ma 30                                             *** 21
     tempfrima30dir ...%22. ma 30 numerical dir                                 *** 22  p5
     tfma30dt ...%23. ma 30 name dir                                            *** 23
     tempma30cross(1)...%24. ma 30 numerical cross date                         *** 24
     tempma30cross(2) ...%25. ma 30 numerical cross numerical sign              *** 25
     tma30ct ...
     tempfrirsi(end,1) ...%27. rsi 5 weeks fri value                            *** 26
     ]; %...%26. ma 30 name cross                                           *** 26  p6
%      tempfrirsi(end,:) ...%27. rsi 5 weeks fri value                            *** 27
%      ];

RepSeries{1,i}=tempALL;
RepLine(i,:)=tempLAST;
ab(i,1)=max(0,max(MSDF,MSDR));
db(i,1)=ma13ddcbuy;
ds(i,1)=ma13ddcsell;
as(i,1)=min(0,min(MSDF,MSDR));
lpc13i(i,1)=lpc13;
lpc30i(i,1)=lpc30;
clear temp* tma* tfma* tmacd*  MS* ma13dd* lpc13 lpc30 lastprice
disp(i);
end

clear i

if size(BBGDATA,2)<=500
     sectype='OtherSecs'; else sectype='Stocks'; end

macdcrossbuy=max(cell2mat(RepLine(:,6)),[],2)+max(cell2mat(RepLine(:,12)),[],2);
macdcrossbuy=double(macdcrossbuy~=0);
macddirbuy=ab;
ma13dirbuy=double(cell2mat(RepLine(:,16))>0)/2;
ma13crossbuy=double(cell2mat(RepLine(:,19))>0)/2;
ma30dirbuy=double(cell2mat(RepLine(:,22))>0)/2;
ma30crossbuy=double(cell2mat(RepLine(:,25))>0)/2;
BB=[min(macdcrossbuy+macddirbuy,1) double((ma13dirbuy.*ma13crossbuy)>0) double((ma30dirbuy.*ma30crossbuy)>0) db (2.*ma13dirbuy.*double(lpc13i>0))./2  (2.*ma30dirbuy.*double(lpc30i>0))./2];
B=sum(BB,2);

macdcrosssell=min(cell2mat(RepLine(:,6)),[],2)+min(cell2mat(RepLine(:,12)),[],2);
macdcrosssell=double(macdcrosssell~=0);
macddirsell=as;
ma13dirsell=double(cell2mat(RepLine(:,16))<0)/2;
ma13crosssell=double(cell2mat(RepLine(:,19))<0)/2;
ma30dirsell=double(cell2mat(RepLine(:,22))<0)/2;
ma30crosssell=double(cell2mat(RepLine(:,25))<0)/2;
SS=[min(macdcrosssell+abs(macddirsell),1) double((ma13dirsell.*ma13crosssell)>0) double((ma30dirsell.*ma30crosssell)>0) ds (2.*ma13dirsell.*double(lpc13i<0))./2  (2.*ma30dirsell.*double(lpc30i<0))./2];
S=sum(SS,2);

% Score	Signal
% 0.5	Hot
% 1.0	MACD Signal (Friday or Roll)
% 1.0	MACD Direction (Friday or Roll)
% 0.5	MA 13 weeks Direction + MA 13 Weeks Cross
% 0.5	MA 30 weeks Direction + MA 30 Weeks Cross
% 0.5	MA 13 days Direction
% 0.5	MA 13 Days Cross
% 0.5	MA 13 weeks Direction + Last Price above it
% 0.5	MA 30 weeks Direction + Last Price above it



%sum points with daily
%load(sprintf('C:/Users/Lorenzo/Documents/MATLAB/database/%s-pointsdaily-%s.mat',sectype, datestr(today-1)))
% B=[max(cell2mat(RepLine(:,6)),[],2) ...
%  + max(cell2mat(RepLine(:,12)),[],2)...
%  + double(cell2mat(RepLine(:,16))>0)...
%  + double(cell2mat(RepLine(:,19))>0)...
%  + double(cell2mat(RepLine(:,22))>0)...
%  + double(cell2mat(RepLine(:,25))>0)];
% S=[abs(min(cell2mat(RepLine(:,6)),[],2))+ abs(min(cell2mat(RepLine(:,12)),[],2))+ double(cell2mat(RepLine(:,16))<0)+ double(cell2mat(RepLine(:,19))<0) + double(cell2mat(RepLine(:,22))<0) + double(cell2mat(RepLine(:,25))<0)];
% % B=B+pLS(:,1);
% S=S+pLS(:,2);
signsBS=[min(4*ones(size(B,1),1),B) min(4*ones(size(S,1),1),S)];

%clear pLS

printrows=[18 19 20 24 25 26];
RL2=RepLine(:,printrows);
clear printrows ab as ma13* ma30* macdcross* macddir* db ds lpc13i lpc30i

%clear BBGDATA

%save(sprintf('C:/Users/Lorenzo/Documents/MATLAB/database/TEST%s-WeeklyReport-%s.mat',sectype,datestr(today)))
%disp('MACD/MA/RSI 5 Weeks Report: done!')

