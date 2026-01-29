function out=CandleBody(BBGDATA,cp,mp1,mp2,f)
%cp is the minimum amount of valid days
%mp1 is the parameter for the short average
%mp2 is the parameter for the long average
%f is the multiplicative factor


for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,1)),:)=[];%date
    temp(isnan(temp(:,2)),:)=[];%close
    %temp(isnan(temp(:,3)),:)=[];%volume
    temp(isnan(temp(:,4)),:)=[];%high
    temp(isnan(temp(:,5)),:)=[];%low
    temp(isnan(temp(:,6)),:)=[];%open
    

    
    [us,rb,ls,tb,mb]=ConstructCandle(temp(:,6),temp(:,4),temp(:,5),temp(:,2));
    
    
    rbr=rb./temp(:,6);
    rbrp=rbr(find(rbr>=0));%positives
    rbrm=rbr(find(rbr<=0));%negatives
    
    if size(rbrp,1)<mp2+5,
   ss=0;
    else
    rbmp2=ma(rbrp,mp2);%average of positives
    lagp2=lagmatrix(rbmp2,mp1);%kill the last 3
    rbmp1=ma(rbrp,mp1);%moving average of 3 days
    ss=double(rbmp1<=f*lagp2);
    end
    
    if size(rbrm,1)<mp2+5,
    bb=0;
    else
    rbmm2=ma(rbrm,mp2);
    lagm2=lagmatrix(rbmm2,mp1);
    rbmm1=ma(rbrm,mp1);
    bb=double(abs(rbmm1)<=f*abs(lagm2));
    end
    
    out(i,:)=[bb(end,1) ss(end,1)];
    
    
    clear rb* ss bb mp22 mp23
    disp(i)
end
disp('Candle Body Calculations done!')
    
    