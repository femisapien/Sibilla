function rsi=rsi(series,w)
%calculates RSI for a time series and a observation window
% inputs are data series and time window to calculate rsi
%data series has to be longer than window.

for i=2:size(series),sret(i-1,1)=series(i)-series(i-1);end,clear i
%3rd --> adjust return series, delete the last
% sret(end,:)=[];
% sret=[0;sret];
%4th --> create signal series
sup=sret>=0;
sdown=sret<0;sdown=sdown*(-1);
%5th --> create up and down series
retup=sup.*sret;
retdown=sdown.*sret;
%6th --> create the first point
fup=sum(retup(1:w,1))/w;
fdown=sum(retdown(1:w,1))/w;
rsfirst=fup/fdown;
rsifirst=100-(100/(1+rsfirst));
%7th --> create series of returns by direction     
retup2=zeros(size(retup,1),1);
retdown2=zeros(size(retdown,1),1);
%8th --> fill with first observation
retup2(w+1,1)=fup;
retdown2(w+1,1)=fdown;
%9th --> calculate averages for all observations
for i=w+2:size(sret,1)
     retup2(i,1)=((w-1)*retup2(i-1,1)+retup(i,1))/w;
     retdown2(i,1)=((w-1)*retdown2(i-1,1)+retdown(i,1))/w;
end
clear i
%10th --> finally compute RS and RSI
rs=retup2./retdown2;
rsi=100-(100./(1+rs));rsi=[NaN;rsi];%rsi(isnan(rsi),:)=0;