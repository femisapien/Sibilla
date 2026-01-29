function out=xRDD(sdate,edate,fields,period,listname,type,sectype)
%type='A' --> asset classes
%type 'A2' --> selected securities
%type='S' --> stocks

listname=strcat(listname,'.mat');
cd('C:\101510\database\lists')
load(listname)
cd ..
% sdate='01-Jan-2008';
% edate='25-Nov-2015';
% fields={'PX_LAST','PX_VOLUME','PX_HIGH','PX_LOW','PX_OPEN'};
% period={'daily','calendar'};
BBGDATA=xEZUpdate(StockNames,sdate,edate,fields,period);
sname=strcat(sectype,'-START',sdate,'-END',edate,'.mat');
clear fields period
save(sname);
clear 
clc

% if type=='A',
% sname=strcat('ROtherSecs-START',sdate,'-END',edate,'.mat');
% clear fields period
% save(sname);
% clear 
% clc
% elseif type=='S'
% % load dLISTSR20151110
% % sdate='25-Nov-2015';
% % edate='25-Nov-2015';
% % fields={'PX_LAST','PX_VOLUME','PX_HIGH','PX_LOW','PX_OPEN'};
% % period={'daily','calendar'};
% BBGDATA=xEZUpdate(StockNames,sdate,edate,fields,period);
% sname=strcat('RStocks2-START',sdate,'-END',edate,'.mat');
% clear fields period
% save(sname);
% clear 
% clc
% end
out='Database Update: Done.'

