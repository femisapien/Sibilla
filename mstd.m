function mstd=mstd(series,lag)

series(isnan(series))=[];
srows=size(series,1);
window=0:1:lag-1;
fill=zeros(lag-1,1);
for i=1:srows-lag+1
     mstd(i,1)=nanstd(series(i+window));
end
mstd=[fill;mstd];



