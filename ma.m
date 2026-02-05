function ma=ma(series,lag)

series(isnan(series))=[];
srows=size(series,1);
window=0:1:lag-1;
fill=zeros(lag-1,1);
for i=1:srows-lag+1
     ma(i,1)=mean(series(i+window));
end
ma=[fill;ma];
