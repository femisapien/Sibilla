function out=prange(series1,series2,type)
%calculates amplitude or range for two time series
%inputs are:
     %series1, the first series
     %series2, the second series
     %type, a binary variable. type=0 for simple numeric range and type=1 for
     %percentual (over the lower value) range.

if length(series1)~=length(series2), error('series have different sizes'),end

n1=find(isnan(series1));
n2=find(isnan(series2));
nn=union(n1,n2);
series1(nn,:)=[];
series2(nn,:)=[];
clear n1 n2 nn

nobs=length(series1);
r1=series1-series2;%first calculate difference preserving sign

%then extract the sign. 1 for series 1 bigger and 2 for series 2 bigger.
for i=1:nobs
     if r1(i,1)>0, r2(i,1)=1;
     elseif r1(i,1)<0, r2(i,1)=2;
     else r2(i,1)=0;end
end
clear i

r1=abs(r1);%remove the sign

if type==0,
     r3=r1;
elseif type==1
     for i=1:nobs
          r3(i,1)=r1(i,1)/min(series1(i,1),series2(i,1));
     end
     clear i
end
%there is a better way of doing percentual range, using r2, but I can't
%figure it out right now.


%the other possible outputs r1 (simple range, useful when type=1) 
%and r2 (vector pointing, at each observation, twhich series has the bigger value) 
%are hidden in this version but ready to be included as outputs.
out=r3;

    
    
     
     