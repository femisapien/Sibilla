function [ddhc, ddh, ddoc,ddo,ddic,ddi]=DDHO(last,open,volume,mavp,tspan)
% function to check if a security is in distribution
%calculates total distribution days for a security using 2 definitions,
%given by 4 conditions
% A)  last(t)>last(t-1)
% B)  volume(t)>volume(t-1)
% C)  volume(t)>MA(volume,mavp)

%
%    HEAVY: A+B+C
% ORIGINAL: A+B

%parameters are:
%last: last price
%volume: traded volume
%mavp: window to calculate moving average of volume
%tspan: window to count number of distribution days

if size(last,1)<=25,
    ddhc=0;
    ddoc=0;
    ddh=0;
    ddo=0;
    ddic=0;
    ddi=0;
else

if size(last,1)<=mavp
    mavp=size(last,1)-5;
end


laglast=[0;last(1:end-1,1)];
last=[0;last(2:end,1)];

lagvol=[0;volume(1:end-1,1)];
volume=[0;volume(2:end,1)];
mavol=ma(volume,mavp);

%A
atest=last-laglast;
atest=double(atest<0);

%B
btest=volume-lagvol;
btest=double(btest>0);

%C
%POTENTIAL PROBLEM: HAVE TO CUT FISRT mavp DAYS
ctest=volume-mavol;
ctest=double(ctest>0);


ddh=atest.*btest.*ctest;
ddo=atest.*btest;


ddhc=sum(ddh(end-tspan+1:end,1));
ddoc=sum(ddo(end-tspan+1:end,1));

%NEW INTRADAY
dtest=double((last-open)<0);
ddi=dtest.*btest.*ctest;
ddi=max(ddi,ddh);
ddic=sum(ddi(end-tspan+1:end,1));

end
% disp('DDHO: Done!')




