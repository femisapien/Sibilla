function out=Direction(series)
%just assigns -1, 0 or 1 for series direction 

out=sign(Returns(series,1,1));
