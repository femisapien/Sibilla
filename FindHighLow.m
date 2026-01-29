function out=FindHighLow(highs,lows,dates,range)

if size(dates,1)<range
     range=size(dates,1);
end

highs=highs(end-range+1:end);
lows=lows(end-range+1:end);
dates=dates(end-range+1:end);

Mdata=max(highs);
Mloc=dates(find(highs(:,1)==Mdata,1,'last'));

mdata=min(lows);
mloc=dates(find(lows(:,1)==mdata,1,'last'));

out=[Mloc-693960 mloc-693960];