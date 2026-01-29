function out=Engulfing(open,high,low,close)
%ATTENTION: Function needs at least two observations

if length(open)<2, error('Insufficient Observations'),end


[us,rb,ls,tb,mb]=ConstructCandle(open,high,low,close);
maxbody=max([open,close],[],2);
minbody=min([open,close],[],2);

lagmax=lagmatrix(maxbody,1);
lagmin=lagmatrix(minbody,1);
lagrb=lagmatrix(rb,1);

tp=double(sign(rb)>sign(lagrb));
tm=-1*double(sign(rb)<sign(lagrb));

signal=tp+tm;

lb=double(minbody<lagmin);
ub=double(maxbody>lagmax);
bound=lb.*ub;

out=signal.*bound;