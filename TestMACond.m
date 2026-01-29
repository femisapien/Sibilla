function out=TestMACond(series,ct,maw,sf)
%function to test conditions in a time series and its moving average series.
%inputs:
     %series --> time series of data
     %ct --> cond type
          %1 FOR "EQUAL"
          %2 FOR "NOT EQUAL"
          %3 FOR "LESS THAN"
          %4 FOR "LESS THAN OR EQUAL TO"
          %5 FOR "GREATER THAN"
          %6 FOR "GREATER THAN OR EQUAL TO"
     %maw --> the window used to calculate ma series     
     %sf --> scale factor to multiply ma series
%output is a binary series, 0 for condition not met and 1 for condition met.     
     
ma1=ma(series,maw);%create ma series
ma2=sf.*ma1;%apply scale factor
cond1=ma1>0;%find non existent moving average points (size of window) and construct series to eliminate them from any comparison.

if     ct==1
     cond=series.*cond1==ma2;
elseif ct==2
     cond=series.*cond1~=ma2;
elseif ct==3
     cond=series.*cond1<ma2;
elseif ct==4
     cond=series.*cond1<=ma2;
elseif ct==5
     cond=series.*cond1>ma2;
elseif ct==6
     cond=series.*cond1>=ma2;
end

out=1.*cond;



     