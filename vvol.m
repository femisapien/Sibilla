function out=vvol(series,w,k,stype)
%computes the technical indicator Volatility of Standard Deviation
%inputs are:
     %series, the main input
     %w, the window to compute mving standard deviation of series
     %k, the parameter to adjust the volatility, tipically 252
     %stype, to adjust series
          %0 to use series as it is
          %1 to use linear returns of series
          %2 to use percentual returns of series
          %3 to use log returns of series
%exaample: out=vvol(series,30,252,3)          

series=series(~isnan(series));

if     stype==0
     v0=series;
     v1=mstd(v0,w);
     vf=k*v1;
else
     v0=Returns(series,1,stype);
     v1=mstd(v0,w);
     vf=k*v1;
end

out=vf;
