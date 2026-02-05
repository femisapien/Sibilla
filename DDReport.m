function [ADD,MDD]=DDReport(BBGDATA)

%cut data to run faster
% for i=1:size(BBGDATA,2)
%     aa=size(BBGDATA{1,i},1);
%         BBGDATA{1,i}(1:aa,:)=[];
%     
% end
% clear i aa

for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i};
    
    temp(isnan(temp(:,2)),:)=[];
    temp(isnan(temp(:,3)),:)=[];
    if isempty(temp)==1, temp=zeros(80,6);end
    
    if isnan(temp(end,3))==1
        temp(end,3)=temp(end-1,3);
    end
    [dheavy, dheavys, doriginal,doriginals,dintra,dintras]=DDHO(temp(:,2),temp(:,6),temp(:,3),50,25);
    [aheavy, aheavys, aoriginal,aoriginals,aintra,aintras]=ADHO(temp(:,1),temp(:,2),temp(:,6),temp(:,3),50,25);
    %MDD(i,1)=dheavy;
    MDD(i,1)=doriginal;
    MDD(i,2)=max(dheavy,dintra);
    %ADD(i,1)=aheavy;
    ADD(i,1)=aoriginal;
    ADD(i,2)=max(aheavy,aintra);
    
    clear temp dheavy* doriginal* aheavy* aoriginal* dintra* aintra*
    %disp(i)
end
clear i

    
        