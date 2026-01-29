function BBGDATA=xEZUpdate(StockNames,sdate,edate,fields,period)
%javaaddpath('D:\Dropbox\MATLAB\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar');



c=blp;
for i=1:length(StockNames)
    iName=StockNames{i,1};
    iData=history(c,iName,fields,sdate,edate,period);
    if iscell(iData)==1 %dates come in strings
        if isempty(iData)==0 % stock is dead
           td=iData(:,1);
           td=datenum(td);
           iData=iData(:,2:end);
           iData=cell2mat(iData);
           iData=[td iData];
        end
    end
    BBGDATA{1,i}=iData;
    clear iData iName td
    disp(i)
end
close(c)
clear i  fields period c


