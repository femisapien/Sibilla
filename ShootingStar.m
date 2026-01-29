function out=ShootingStar(open,high,low,close,tol)
%ATTENTION: Function needs at least two observations

if length(open)<2, error('Insufficient Observations'),end

[us,rb,ls,tb,mb]=ConstructCandle(open,high,low,close);

laglow=lagmatrix(low,1);
laghigh=lagmatrix(high,1);
lagrb=lagmatrix(rb,1);

tp=double(sign(lagrb)>0);
tm=-1*double(sign(lagrb)<0);

% op=double(open>laglow);
% om=double(open<laghigh);
% 
% tp=tp.*op;
% tm=tm.*om;
t=tp+tm;


lp=Lollipop(open,high,low,close,tol);

stars=Star(open,high,low,close);
s=abs(stars);

test1=double(lp==1);
test2=double(abs(lagrb)>abs(rb));
test=test1.*test2;

out=t.*lp.*test.*s;