function out=CloudCover(open,high,low,close)
%ATTENTION: Function needs at least two observations

if length(open)<2, error('Insufficient Observations'),end


[us,rb,ls,tb,mb]=ConstructCandle(open,high,low,close);
lagrb=lagmatrix(rb,1);
laghigh=lagmatrix(high,1);
laglow=lagmatrix(low,1);
lagmb=lagmatrix(mb,1);

test10=double(sign(rb)<sign(lagrb));%past positive
test20=-1*double(sign(rb)>sign(lagrb));%past negative

test11=double(open>laghigh);%opens higher
test21=double(open<laglow);%opens lower

test12=double(close<lagmb);%closes below midpoint of previous day
test22=double(close>lagmb);%closes above 

test1=test10.*test11.*test12;
test2=test20.*test21.*test22;

out=test1+test2;

