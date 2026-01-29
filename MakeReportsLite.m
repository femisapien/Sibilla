function [A_WEEKLY,LONG_LINE,SHORT_LINE,D_BREAKS,E_BREAKSr,G_AD,H_M2,I_MA_SIG]=MakeReportsLite(ifile,sectype,upto,dtype)
ipath='database/';
ipath2=sprintf('%s%s%s.mat',ipath,ifile,upto);
load(ipath2)
disp('Data Loaded')

disp('RSI Report Running')
[LONG_LINE, SHORT_LINE]=xRSIreport(BBGDATA);

disp('Calculating Difference between security RSI and weaker Index RSI')
todayRSI=SHORT_LINE(:,4);
if size(todayRSI)>1000,
    weaker=min(todayRSI(2,1),todayRSI(3,1)); %NYA is row 2, RSP is row 3 in MASTER file
else
    weaker=min(todayRSI(247,1),todayRSI(315,1)); %NYA is row 315, RSP is row 247 in AC file
end

diffRSIweaker=todayRSI-weaker;
SHORT_LINE=[SHORT_LINE diffRSIweaker];


if size(BBGDATA,2)>5000
disp('Model 2 Report Running')
[m2i, m2l, rsi_wm, m2i_spec]=M2Report(BBGDATA);
M_RSIS=rsi_wm;
H_M2=[m2i m2l];
disp('Model 2 Report Done')
else
    H_M2=[0 0 0 0];
end

disp('Weekly Report Running')
A_WEEKLY=WeeklyReportNew(BBGDATA);
disp('Weekly Report Done')


disp('Breakouts Report Running')
D_BREAKS=[BreaksReport2(BBGDATA,360) BreaksReport2(BBGDATA,120)];


D_BREAKS(:,[2 4 6 8])=[];
breakpoints=double(ismember(D_BREAKS,[(datenum(upto)-693960)-4,datenum(upto-693960)]));

disp('calculating ratio between security and SPX')
for i=1:size(BBGDATA,2)
    spx=BBGDATA{1,1};
    temp=BBGDATA{1,i};
    [dlist, indp, tempp]=intersect(spx(:,1),temp(:,1));%equalizes dates with index, since difference is required
    temp=temp(tempp,:);%load security data in common dates
    spx=spx(indp,:);%the same for index data
    BBGDATAr{1,i}=[dlist temp(:,2:end)./spx(:,2:end)];
    disp(i)
    clear temp tempp
end
clear i spx 

E_BREAKSr=[BreaksReport2(BBGDATAr,360) BreaksReport2(BBGDATAr,120)];
E_BREAKSr(:,[2 4 6 8])=[];
breakpoints=double(ismember(E_BREAKSr,[(datenum(upto)-693960)-4,datenum(upto-693960)]));
disp('Breakouts Report Done')


disp('calculating ratio between security and NYA/RSP')
for i=1:size(BBGDATA,2)
    idx=BBGDATA{1,3}; % RSP for now. IMPROVE LATER CREATING AN ALGO TO CHOOSE BY RSI
    temp=BBGDATA{1,i};
    [dlist, indp, tempp]=intersect(idx(:,1),temp(:,1));%equalizes dates with index, since difference is required
    temp=temp(tempp,:);%load security data in common dates
    idx=idx(indp,:);%the same for index data
    BBGDATAr2{1,i}=[dlist temp(:,2:end)./idx(:,2:end)];
    disp(i)
    clear temp tempp
end
clear i idx 


disp('comparing the ratio with the 50D MA')

for i = 1:size(BBGDATAr2,2)
    temp = BBGDATAr2{1, i}(:, 2); % Get the price series
    if length(temp) >= 50 && ~isnan(temp(end))
        ma_series = movmean(temp, 50, 'omitnan');
        I_MA_SIG(i,1) = double( temp(end) > ma_series(end) );
     else
        I_MA_SIG(i,1) = 0;
    end
end

disp('Accumulation/Distribution Report Running')
[ADD,MDD]=DDReport(BBGDATA);
G_AD=[ADD MDD];
disp('Accumulation/Distribution Report Done')

disp('Mean Reversion Model Running')
disp('Calculating Narrow/Wide Ranges')
for i=1:size(BBGDATA,2),nwr(i,:)=NWR_new(BBGDATA{1,i}(:,4),BBGDATA{1,i}(:,5),7,30);end, clear i
disp('Finding  Abnormal Volume Dates')
for i=1:size(BBGDATA,2),[obsDate(i,1), obsVol(i,1)]=abnormalVolume(BBGDATA{1,i}(:,1),BBGDATA{1,i}(:,3));end, clear i
disp('Calculating Highs/Lows of 4 days')
for i=1:size(BBGDATA,2),high4(i,:)=findDayOfHighestInWindow(BBGDATA{1,i}(:,4),4);end, clear i
for i=1:size(BBGDATA,2),low4(i,:)=findDayOfLowestInWindow(BBGDATA{1,i}(:,5),4);end, clear i
disp('Calculating Highs/Lows of 1M/3M')
for i=1:size(BBGDATA,2),[DT_HIGH_3M(i,:), DT_LOW_3M(i,:)] = findWindowExtremaDates(BBGDATA{1,i}(:,1), BBGDATA{1,i}(:,4), BBGDATA{1,i}(:,5), 90);end, clear i
for i=1:size(BBGDATA,2),[DT_HIGH_1M(i,:), DT_LOW_1M(i,:)] = findWindowExtremaDates(BBGDATA{1,i}(:,1), BBGDATA{1,i}(:,4), BBGDATA{1,i}(:,5), 30);end, clear i

E_BREAKSr=[E_BREAKSr nwr obsDate obsVol  high4 low4 DT_HIGH_3M DT_LOW_3M DT_HIGH_1M DT_LOW_1M];


clear BBGDATA
cd('C:\101510\database');
save(sprintf('%s-Reports-for-%s.mat',sectype,upto));

disp('Report Saved')

