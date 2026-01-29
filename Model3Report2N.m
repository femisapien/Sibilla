function [out,components]=Model3Report2N(BBGDATA,range1,range2,tol1,tol2,cp,mp1,mp2,f,mp,dp,bp,bl,sigma,dcc,w1,w3,w4,w5)


%TRICK TO FILL MISSING OPEN LOW HIGH
for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(:,4)=nansum([double(isnan(temp(:,4))).*temp(:,2),temp(:,4)],2);
    temp(:,5)=nansum([double(isnan(temp(:,5))).*temp(:,2),temp(:,5)],2);
    temp(:,6)=nansum([double(isnan(temp(:,6))).*temp(:,6),temp(:,6)],2);
    B{1,i}=temp;
    clear temp;
    disp(i)
end
clear i
clear BBGDATA
BBGDATA=B;
clear B;
% END OF TRICK

%MA 13 days cross
MADC=ScrossBlp2(BBGDATA,mp,dp);
b1=MADC(:,1).*w1;
s1=MADC(:,2).*w1;

%NOT USED WITH ASSET CLASSES
% %Accumulations and Distributions
% ADDIFFS=AD2(BBGDATA,range1,range2);
% q=nanmean(ADDIFFS)+sigma*nanstd(ADDIFFS);
% b2=double(ADDIFFS(:,1)>=q(1)).*w2;
% s2=double(ADDIFFS(:,2)>=q(2)).*w2;


%Breakouts 3 days
EXT=ExtremeRangeBlp2(BBGDATA,bp,bl);
b3=EXT(:,1);b3=b3.*w3;
s3=EXT(:,2);s3=s3.*w3;

%Candle Body
CB=CandleBody2(BBGDATA,cp,mp1,mp2,f);
b4=CB(:,1);b4=b4.*w4;
s4=CB(:,2);s4=s4.*w4;


aux=CandleReversalBlp2N(BBGDATA,tol1,tol2);

for i=1:size(aux,2)
    if size(aux{1,i}(:,1))<=dcc,
        b5(i,1)=0;
        s5(i,1)=0;
    else
    b5(i,1)=min(w5,sum(aux{1,i}(end-dcc+1:end,1))/2);
    s5(i,1)=min(w5,sum(aux{1,i}(end-dcc+1:end,2))/2);
    disp(i)
    end
end
clear i aux

b=b1+b3+b4+b5;
s=s1+s3+s4+s5;
out=[b s];
components=0;