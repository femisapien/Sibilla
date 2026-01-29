function [outp,outs]=ExtremeRange(h1,bp,bl,flag)
%verifies if extreme point of a series occurred in a given interval
%h1 is the series
%bp is the length of moving interval used to look for extreme
%bl is the interval in which the extreme can occur
%flag is 1 to look for max and -1 to look for min
%
%outputs are 
%outp, a binary scalar with the condition verified for last bl days
%and outs, the series of moving extremes in the intervals set by bp
%
%example: Find the maximum of a three-days interval which can occur in any
%of last 5 days (thus involving 8 days of series)

if flag==1

q1=mmax(h1,bp);
outs=double(q1==h1);
outp=max(outs(end-bl+1:end,1));

elseif flag==-1
    
q1=mmin(h1,bp);
outs=double(q1==h1);
outp=max(outs(end-bl+1:end,1));

end
