function [heavy, heavys, original,originals, intraday, intradays]=ADHO(date,last,open,volume,mavp,tspan)
% function to check if a security is in accumulation
%calculates total accumulation days for a security using 2 definitions,
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
%tspan: window to count number of accumulation days

if size(last,1)<=25,
    heavy=0;
    original=0;
    heavys=0;
    originals=0;
    intraday=0;
    intradays=0;
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
atest=double(atest>0);

%B
btest=volume-lagvol;
btest=double(btest>0);

%C
%POTENTIAL PROBLEM: HAVE TO CUT FISRT mavp DAYS
ctest=volume-mavol;
ctest=double(ctest>0);


heavys=atest.*btest.*ctest;
originals=atest.*btest;


heavy=sum(heavys(end-tspan+1:end,1));
original=sum(originals(end-tspan+1:end,1));

%NEW INTRADAY
% D
dtest=double((last-open)>0);
intradays=dtest.*btest.*ctest;

intradays=max(intradays,heavys);
intraday=sum(intradays(end-tspan+1:end,1));
end





