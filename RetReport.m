function [out1,out2]=RetReport(BBGDATA,year,e)
%function out=RetReport(BBGDATA,year,e)
%calculates returns for a database 1-day and time-to-date
%corrects for dead/not-yet born stocks
%BBGDATA is the database
%year is the time-to-date to start
%e is the last valid date. If not present returns NaN


em=datenum(e);
ytd=sprintf('01-jan-%s',num2str(year));
ytd=datenum(ytd);
for i=1:size(BBGDATA,2)
    temp=BBGDATA{1,i}(:,1:2);
    rtemp=[temp(:,1) Returns(temp(:,2),1,2)];
    if isempty(find(rtemp(:,1)>=ytd))==0
    out1{1,i}=rtemp(find(rtemp(:,1)>=ytd,1):end,:);
    else
    out1{1,i}=[em NaN];
    end
    clear *temp
    disp(i)
end

for i=1:size(out1,2);
    temp=out1{1,i};
    out2(i,:)=[temp(end,1) temp(end,2) nansum(temp(:,2))];
    clear temp
    disp(i)
end


    

