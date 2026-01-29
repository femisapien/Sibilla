function [us,rb,ls,tb,mb]=ConstructCandle(open,high,low,close)
%calculate sizes of candle components

us=high-max(close,open);%upper shadow
rb=close-open;%real body
ls=min(open,close)-low;%lower shadow
tb=high-low;%total body
mb=abs(close-open)./2;%mid-body point