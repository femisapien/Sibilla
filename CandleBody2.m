function out=CandleBody2(BBGDATA,cp,mp1,mp2,f)
%cp is the minimum amount of valid days
%mp1 is the parameter for the short average
%mp2 is the parameter for the long average
%f is the multiplicative factor


for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    temp(isnan(temp(:,1)),:)=[];%date
    temp(isnan(temp(:,2)),:)=[];%close
    %temp(isnan(temp(:,3)),:)=[];%volume
    temp(isnan(temp(:,4)),4)=temp(isnan(temp(:,4)),2);%high
    temp(isnan(temp(:,5)),5)=temp(isnan(temp(:,5)),2);%low
    temp(isnan(temp(:,6)),6)=temp(isnan(temp(:,6)),2);%open
%     temp(isnan(temp(:,4)),:)=[];%high
%     temp(isnan(temp(:,5)),:)=[];%low
%     temp(isnan(temp(:,6)),:)=[];%open
    
    [us,rb,ls,tb,mb]=ConstructCandle(temp(:,6),temp(:,4),temp(:,5),temp(:,2));
    
    
    rbr=rb./temp(:,6);
    rbrp=rbr(find(rbr>0));
    rbrm=rbr(find(rbr<0));
    
    if size(rbrp,1)>mp2 
    rbmp2=ma(rbrp,mp2);
    else
    rbmp2=nanmean(rbrp);
    end
    
    lagp2=lagmatrix(rbmp2,mp1);
    if size(rbrp,1)>mp1 
    rbmp1=ma(rbrp,mp1);
    else
    rbmp1=nanmean(rbrp);
    end
    
    if size(rbrm,1)>mp2
    rbmm2=ma(rbrm,mp2);
    else
    rbmm2=nanmean(rbrm);
    end
    lagm2=lagmatrix(rbmm2,mp1);
    
    if size(rbrm,1)>mp1
    rbmm1=nanmean(rbrm);
    else
    rbmm1=nanmean(rbrm);    
    end
    
    
    
    ss=double(rbmp1<=f*lagp2);
    bb=double(abs(rbmm1)<=f*abs(lagm2));
    
    out(i,:)=[bb(end,1) ss(end,1)];
    
    
    clear rb* ss bb
    disp(i)
end

    
    