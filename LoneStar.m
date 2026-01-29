function out=LoneStar(open,high,low,close,tol)
%Reversal pattern called Abandoned Baby or Lone Star
%Requires at least 3 data points
%tol is for Doji

if length(open)<3, error('Insufficient Observations'),end


[us,rb,ls,tb,mb]=ConstructCandle(open,high,low,close);

test0=sign(rb);
lagtest0=lagmatrix(test0,2);
test1=double(lagtest0~=0).*double(test0~=0).*double(test0>lagtest0);
test2=-1*double(lagtest0~=0).*double(test0~=0).*double(test0<lagtest0);
    
test3=Doji(open,close,tol);
test3=lagmatrix(test3,1);
test4=abs(Star(open,high,low,close));
test5=lagmatrix(test4,1);
test6=test4.*test5;

test11=test1.*test3.*test6;
test21=test2.*test3.*test6;

out=test11+test21;
    