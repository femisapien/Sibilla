function [out,components]=Model3ReportN(BBGDATA,range1,range2,tol1,tol2,cp,mp1,mp2,f,mp,dp,bp,bl,sigma,dcc,w1,w2,w3,w4,w5)

%cut data to run faster
for i=1:size(BBGDATA,2)
    if size(BBGDATA{1,i},1)>500
        BBGDATA{1,i}(1:300,:)=[];
    end
end
clear i
        


%MA 13 days cross
MADC=ScrossBlp(BBGDATA,mp,dp);
b1=MADC(:,1).*w1;
s1=MADC(:,2).*w1;


%Accumulations and Distributions
ADDIFFS=AD2(BBGDATA,range1,range2);
q=nanmean(ADDIFFS)+sigma*nanstd(ADDIFFS);
b2=double(ADDIFFS(:,1)>=q(1)).*w2;
s2=double(ADDIFFS(:,2)>=q(2)).*w2;
% 
% 
% %Breakouts 3 days
EXT=ExtremeRangeBlp(BBGDATA,bp,bl);
b3=EXT(:,1);
s3=EXT(:,2);

%Candle Body
CB=CandleBody(BBGDATA,cp,mp1,mp2,f);
b4=CB(:,1);
s4=CB(:,2);


aux=CandleReversalBlpN(BBGDATA,tol1,tol2);

for i=1:size(aux,2)
    b5(i,1)=min(w5,sum(aux{1,i}(end-dcc+1:end,1))/2);
    s5(i,1)=min(w5,sum(aux{1,i}(end-dcc+1:end,2))/2);
    disp(i)
end
clear i aux

b=b1+b2+b3+b4+b5;
s=s1+s2+s3+s4+s5;
out=[b s];
components=[b1 b2 b3 b4 b5 s1 s2 s3 s4 s5];