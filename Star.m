function out=Star(open,high,low,close)
%search for gaps/stars
%ATTENTION: Function needs at least two observations

if length(open)<2, error('Insufficient Observations'),end

laghigh=lagmatrix(high,1);
laglow=lagmatrix(low,1);

test1=double(low>laghigh);
test2=-1*double(high<laglow);

out=test1 + test2;
