function out=Doji(open,close,tol)
%verifies if days of a time series have the "Doji" formation
%Ideal is close-open=0, but in real world a tolerance (tol) is allowed
%tol is a percentage, relative to open price. It can be entered in the interval [0,100]
%example tol=0.1 will be 0.1%

test=abs(close-open)./open;

if tol>100, tol=100;end
tol=tol/100;
out=double(test<=tol);
