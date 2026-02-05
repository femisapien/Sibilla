function out=xMRC(update,reports,ipath,sectype,sold,eold,snew,enew,listname,updq,type)
%update, join and reports are binaries to choose which parts will be executed
%BASE
% ipath='C:/Users/Lorenzo/Documents/MATLAB/database/';
% sectype='RStocks';
% sold='01-Jan-2005';
% eold='14-Jul-2008';
% snew='15-Jul-2008';
% enew='15-Jul-2008';
% listadd='brlist071508.mat';
% updq=1;
% dtype=0 for traditional historical download from Blommberg or
% dtype=1 for 'GETDATA' download (similar to BDP in Excel)

ifile=sprintf('-START%s-END',sold);
% if isempty(strfind(sectype,'ROtherSecs'))~=1,ifile='-START01-Jan-2008-END';else,ifile='-START01-Jan-2008-END';end
ifile=strcat(sectype,ifile);
upto=enew;
if isempty(strfind(sectype,'Stocks'))~=1,fix=1;else fix=0;end
seclistpath=strcat(ipath,'lists/');
seclistpath=strcat(seclistpath,listname);
savepath=strcat(ipath,sectype);


%% UPDATE
if update==1
fields={'PX_LAST','PX_VOLUME','PX_HIGH','PX_LOW','PX_OPEN'};
period={'daily','calendar'};
sdate=sold;
edate=enew;
out=xRDD(sdate,edate,fields,period,listname,type,sectype)
% out=xRDD(sdate,edate,fields,period,listname,type)
else
     disp('UPDATE not selected')
end


%% REPORTS
if reports==1
savequestion=1;
[A_WEEKLY]=xM12026(ifile,sectype,upto,savequestion);
disp('Reports: Done!')
else
     disp('REPORTS not selected')
end



out='Done!'


