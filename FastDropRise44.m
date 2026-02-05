function fast=FastDropRise44(SRSI,dir,hot,w)

b2=10;
lp=73;
rlp=58;
llp=30;
sp=25;
rsp=44;
lsp=70;
%find rsi above 75
for i=1:size(SRSI,2)
     temp=SRSI{1,i};%same extraction method
       w=60;
    hot=60;
    if size(temp,1)<=w-2,w=size(temp,1)-1;hot=size(temp,1)-1;end
     temp(:,3:end)=[];%cuts unecessary data
     TODAY(i,1)=temp(end,2);
     x=size(temp,1);%number of observations in each security
     a=b2-x+1:1:b2;a=a';%create distance from first observation, controlling eventual discrepancies in series lengths
     f=[temp temp(:,2)>=lp (b2+1)-a];%date // condition (0 or 1) // position relative to db
     f(find(f(:,3)==0),:)=[];
     if isempty(f)==1%if there's no obs meeting condition
          longpure(i,:)=NaN(1,3);%just put NaN's
     else
          longpure(i,:)=[f(end,1:2) f(end,4)];%else list last obs meeting condition
     end
     clear f ff temp x a     
end
clear i
%disp('Search for longs  (>=75) done')




%find rsi below 25
for i=1:size(SRSI,2)
     temp=SRSI{1,i};
       w=60;
    hot=60;
    if size(temp,1)<=w-2,w=size(temp,1)-1;hot=size(temp,1)-1;end
     temp(:,3:end)=[];
     x=size(temp,1);
     a=b2-x+1:1:b2;a=a';
     f=[temp temp(:,2)<=sp (b2+1)-a];
     f(find(f(:,3)==0),:)=[];
     if isempty(f)==1
          shortpure(i,:)=NaN(1,3);
     else
          shortpure(i,:)=[f(end,1:2) f(end,4)];
     end
     clear f ff temp x a     
end
clear i
%disp('Search for shorts (<=25) done')

%hot long and hot short
for q=1:size(SRSI,2)
     temp=SRSI{1,q};
    if size(temp,1)<=w||size(temp,1)==0,
 hotlong(q,1)=0;
 hotshort(q,1)=0;
    else
     
     temp(:,3:end)=[];
%      temp=temp(:,2);
     hotlong(q,:)=HotLongShort(temp,hot,6,lp);
     hotshort(q,:)=HotLongShort(temp,hot,4,sp);
     clear temp
   end  
    end

clear q
hotlong=hotlong.*(1-double(shortpure(:,1)>0));
hotshort=hotshort.*(1-double(longpure(:,1)>0));


if dir==-1
for i=1:size(SRSI,2)
    temp=SRSI{1,i}; 
     if size(temp,1)<=w||size(temp,1)==0,
         fast(i,1)=0;
         fast(i,2)=0;
         fast(i,3)=0;
    else
    temp=temp(end-w+1:end,:);%limits window to 80 days
    a1=min(temp(:,2));%finds min rsi
    a2=max(temp(:,2));%finds max rsi
    if a1>sp,fast(i,:)=zeros(1,3);% if never was hot short then zero
    elseif a2>lsp,fast(i,:)=zeros(1,3);% if hits 70 then zero
    else
         x2=double(find(temp(:,2)>=rsp)>max(find(temp(:,2)<=sp))).*double(find(temp(:,2)>=rsp));
         x2(find(x2(:,1)==0))=[];
         if isempty(x2)==1,
              fast(i,:)=zeros(1,3);
         else x2=min(x2);
         fast(i,1)=1;
         fast(i,2)=temp(x2,1);
         fast(i,3)=x2;%-min(find(temp(:,2)==a1));
         end
    end
    clear a* temp x
    end
end
clear i
elseif dir==1
    for i=1:size(SRSI,2)
    temp=SRSI{1,i}; 

    if size(temp,1)<=w||size(temp,1)==0,
        fast(i,1)=0;
         fast(i,2)=0;
         fast(i,3)=0;
    else
    temp=temp(end-w+1:end,:);%limits window to 80 days
    a1=max(temp(:,2));
    a2=min(temp(:,2));
    if a1<lp,fast(i,:)=zeros(1,3);
    elseif a2<llp,fast(i,:)=zeros(1,3);
    else
         x2=double(find(temp(:,2)<=rlp)>max(find(temp(:,2)>=lp))).*double(find(temp(:,2)<=rlp));
         x2(find(x2(:,1)==0))=[];
         if isempty(x2)==1,
              fast(i,:)=zeros(1,3);
         else x2=min(x2);
         fast(i,1)=1;
         fast(i,2)=temp(x2,1);
         fast(i,3)=x2;%-min(find(temp(:,2)==a1));
         end
    end
    clear a* temp x
    end
    end
    disp(i)
clear i 
end

