function out=xMRC2026(update,reports,ipath,sectype,sold,eold,snew,enew,listname,updq,type)


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
[A_WEEKLY,L_DROP,S_RISE,D_BREAKS,E_BREAKSr,G_AD,I_MA_SIG]=xMakeReportsLite(ifile,sectype,upto,type);
disp('Reports: Done!')
else
     disp('REPORTS not selected')
end



out='Done!'



