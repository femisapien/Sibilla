function out=NWR(high,low,w_n,w_w)
%calculates narrowest and widest range in a time series of length "window"
%inputs are high and low prices in vector form
%output is a binary matrix with 1 if the narrowest/widest range is the last
%observation and zero otherwise

range_n=high-low;
if length(range_n)>w_n, range_n(1:end-w_n,:)=[];end
[~, id_nr] = min(range_n);
out(1,1) = (length(range_n) - id_nr + 1) * ((length(range_n) - id_nr + 1) <= 5);

range_w=high-low;
if length(range_w)>w_w, range_w(1:end-w_w,:)=[];end
[~, id_wr] = max(range_w);
out(1,2) = (length(range_w) - id_wr + 1) * ((length(range_w) - id_wr + 1) <= 10);

end
    