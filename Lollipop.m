function out=Lollipop(open,high,low,close,tol)
%search for the Lollipop formation
%tol in [0,100]

[us,rb,ls,tb,mb]=ConstructCandle(open,high,low,close);


if tol>100, tol=100;end
tol=tol/100;

test1=double((us+ls)>abs(rb));
test2=double(min(us,ls)<=tol);

out=test1.*test2;