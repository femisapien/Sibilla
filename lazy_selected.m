%% timer: startat(timer('TimerFcn','lazy_selected'),'17:16:00');

addpath('C:\101510\functions')
% SELECTED SECURITIES
cd('C:\101510\database\lists')

%%
update=1; %get bloomberg data
join=0;   %complete database. 
reports=1;%run complete set of reports

%%
ipath='database\';sectype='ROtherSecs2';listname='dLISTSELECTED20210121'; 
%listname='dLISTSELECTED20180918'; 

%%
 sold='01-Jan-2015'; 
 eold='02-Jan-2009';%<<---
 snew='01-Jan-2011';%<<---
 enew='18-May-2021';%<<---
%%
updq=1;%to create a new DB from the beginning use only sold and enew
type='A2';%asset classes

%%
out=xMRC(update,join,reports,ipath,sectype,sold,eold,snew,enew,listname,updq,type)

%%
clear type eold fdel ipath join listname out reports sectype snew sold update updq
clc

%%
d='C:\101510\database';out=WriteOut2(d,'ROtherSecs2',enew);
clear
exit