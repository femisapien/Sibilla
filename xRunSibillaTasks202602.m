%% timer:   startat(timer('TimerFcn','xlazy2025'),'17:06:00');

addpath('C:\101510\functions') 
cd('C:\101510\database\lists')

%%

% RUN MODEL 1

%% PARAMETERS
ma_p = 31;         % MA period
ma_consecutive = 52; % Stock must be above MA for >52 days (i.e., at least 53 days)
gap_pct = 0.20;    % 20% gap up
gap_lookback = 45; % Lookback for gap in the last 45 trading days
db_path = 'C:\101510\database\'; % Path to your data files
f1  = '-START';
f2  = '-END';
sold='01-Jan-2024';
eold='16-May-2025';%<<---
snew='01-Jan-2024';%<<---
enew='03-Feb-2026';%<<---

%% INDICES MODEL 1 FOR PAGES 1/2
update=1; %get bloomberg data
reports=1;%run complete set of reports

cd('C:\101510\')
ipath='database/';sectype='ROtherSecs';listname='dM1List2025'; 

sold='01-Jan-2022';
eold='02-Jun-2022';%<<---
snew='08-Jun-2022';%<<---

updq=1;%to create a new DB from the beginning use only sold and enew
type='A'; %asset classes

out=xMRC(update,reports,ipath,sectype,sold,eold,snew,enew,listname,updq,type)

clear type eold fdel ipath join listname out reports sectype snew sold update updq
clc

d='C:\101510\database';out=WriteOut(d,'ROtherSecs',enew);

clear
clc

%%

% RUN THE SCORING MODEL


%% PARAMETERS
ma_p = 31;         % MA period
ma_consecutive = 52; % Stock must be above MA for >52 days (i.e., at least 53 days)
gap_pct = 0.20;    % 20% gap up
gap_lookback = 45; % Lookback for gap in the last 45 trading days
db_path = 'C:\101510\database\'; % Path to your data files
f1  = '-START';
f2  = '-END';
sold='01-Jan-2022';
eold='16-May-2025';%<<---
snew='01-Jan-2024';%<<---
enew='02-Feb-2026';%<<---
a_upt=1;  %get bloomberg data for assets
s_upt=1;  %get bloomberg data for stocks



%% ASSET CLASSES
indicators=1;%run complete set of reports

cd('C:\101510\')
ipath='database/';sectype='ASSETS';listname='dListASSETS2025'; 

updq=1;%to create a new DB from the beginning use only sold and enew
type='A'; %asset classes

out=xINDICATORS(a_upt,indicators,ipath,sectype,sold,eold,snew,enew,listname,updq,type, ...
    ma_p, ma_consecutive, gap_pct, gap_lookback, db_path, f1, f2);

clear type fdel ipath listname out indicators sectype   updq 
clc

%% MASTER FILE
indicators=1;%run complete set of reports

cd('C:\101510\')
ipath='database/';sectype='STOCKS';listname='dListMASTER2025'; 

updq=1;%to create a new DB from the beginning use only sold and enew
type='A'; %asset classes

out=xINDICATORS(s_upt,indicators,ipath,sectype,sold,eold,snew,enew,listname,updq,type, ...
    ma_p, ma_consecutive, gap_pct, gap_lookback, db_path, f1, f2);


clear type fdel ipath listname out indicators sectype updq sold eold snew ma_p ma_consecutive gap_pct gap_lookback db_path f1 f2
clc

%% RUN REPORTS TO COMPLETE MR AND SHORT MODEL AND OTHER INDICATORS

addpath('C:\101510\functions') 
cd('C:\101510\database\lists')

% PARAMETERS
db_path = 'C:\101510\database\'; % Path to your data files
f1  = '-START';
f2  = '-END';
sold='01-Jan-2022';
eold='16-May-2025';%<<---
snew='01-Jan-2024';%<<---


% ASSET CLASSES
reports=1;%run complete set of reports

cd('C:\101510\')
ipath='database/';sectype='ASSETS';listname='dListASSETS2025'; 

updq=1;%to create a new DB from the beginning use only sold and enew
type='A'; %asset classes

out=xMRC2026(a_upt,reports,ipath,sectype,sold,eold,snew,enew,listname,updq,type)

status = WriteOutImproved(db_path, 'ASSETS', enew, 'AC')

clear type fdel ipath listname out indicators sectype  update updq 
clc


%% MASTER
reports=1;%run complete set of reports
ipath='database/';sectype='STOCKS';listname='dListMASTER2025';

sold='01-Jan-2022';
eold='16-May-2025';%<<---
snew='01-Jan-2024';%<<---

updq=1;%to create a new DB from the beginning use only sold and enew
type='S'; %stocks

out=xMRC2026(s_upt,reports,ipath,sectype,sold,eold,snew,enew,listname,updq,type)

status = WriteOutImproved(db_path, 'STOCKS', enew, 'SR')


clear type eold fdel ipath listname out reports sectype snew sold update updq
clc


%%
% exit
