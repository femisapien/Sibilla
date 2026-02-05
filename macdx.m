function [macdx,sig,macd2] = macdx(series,nper1,nper2,npersig)
%macd
%series
%nper1
%nper2
%npersig
%nper1=12;nper2=26;npersig=9;

%ema calc
series=series(~isnan(series(:,1)),:);
if size(series,1)<nper1+nper2
     macdx=-9999;
     sig=-9999;
     macd2=-9999;
else
ema1first=nanmean(series(1:nper1,:));%start with simple mean over the first nper observations
ema1=zeros(size(series,1),1);%create ema series populated with zeros
ema1(nper1+1,1)=ema1first;%set intial value equal to simple mean calculated above
factor1=2/(nper1+1);%set factor
%fill the series with recursion
for i=nper1+2:size(series,1)
     ema1(i,1)=ema1(i-1,1)+factor1*(series(i,1)-ema1(i-1,1));
end

clear i

ema2first=nanmean(series(1:nper2,:));
ema2=zeros(size(series,1),1);
ema2(nper2+1,1)=ema2first;
factor2=2/(nper2+1);
for i=nper2+2:size(series,1)
     ema2(i,1)=ema2(i-1,1)+factor2*(series(i,1)-ema2(i-1,1));
end

clear i

macdtemp=ema1(nper2+1:end,1)-ema2(nper2+1:end,1);
macdx=[zeros(nper2,1);macdtemp];

sigfirst=nanmean(macdtemp(1:npersig-1,:));
sig=zeros(size(series,1),1);
sig(nper1+nper2,1)=sigfirst;
factorsig=2/(npersig+1);

for i=nper1+nper2+1:size(series,1)
     sig(i,1)=sig(i-1,1)+factorsig*(macdx(i,1)-sig(i-1,1));
end

clear i

macd2=[zeros(nper1+nper2-1,1);macdx(nper1+nper2:end,1)-sig(nper1+nper2:end,1)];
%clear ema* factor* nper* macdtemp sigfirst
end