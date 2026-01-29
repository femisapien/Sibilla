function mmax=mmax(series,lag)

series(isnan(series))=[];
srows=size(series,1);
window=0:1:lag-1;
fill=zeros(lag-1,1);
for i=1:srows-lag+1
     mmax(i,1)=nanmax(series(i+window));
end
mmax=[fill;mmax];