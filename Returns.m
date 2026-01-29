function out=Returns(series,nl,type)
%computes the return series of a time series
%inputs are:
     %series --> time series data
     %nl --> number of observation between the first point and the last point (periodicity)
     %type --> the method used to compute returns
     %1 for linear returns, x(i)-x(i-1)
     %2 for percentual returns, (x(i)-x(i-1))/x(i-1)
     %3 for logaritm returns, ln(x(i)/x(i-1))
%removes NaN's before computations

%series=series(~isnan(series));

if     type==1
     for i=nl+1:size(series,1), ret(i,1)=series(i,1)-series(i-nl,1);end,clear i
elseif type==2
     for i=nl+1:size(series,1), ret(i,1)=(series(i,1)-series(i-nl,1))/series(i-nl,1);end,clear i
elseif type==3
     for i=nl+1:size(series,1), ret(i,1)=log(series(i,1)/series(i-nl,1));end,clear i
end

out=ret;
out(1:nl,1)=NaN;
     