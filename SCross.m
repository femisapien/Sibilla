function out=SCross(series1,series2)
%finds points where two series cross
%inputs are two vectors of same length
%output is a vector with zeros for no cross and ones for cross points

f1=sign(series1-series2);
for i=2:size(f1,1)
    if sign(f1(i))~=sign(f1(i-1))
        out(i,1)=1;
    else 
        out(i,1)=0;
    end
end
