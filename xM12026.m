function [A_WEEKLY]=xM12026(ifile,sectype,upto,dtype)
ipath='database/';
ipath2=sprintf('%s%s%s.mat',ipath,ifile,upto);
load(ipath2)
disp('Data Loaded')

disp('RSI Report Running')
[longaux, B_LONG, shortaux, C_SHORT,pLS]=RSIreport(BBGDATA);
%if RSI is NaN (result of new trick of putting 1 in old series), them make
%it zero
B_LONG((isnan(B_LONG(:,12))),12)=0;
C_SHORT((isnan(C_SHORT(:,12))),12)=0;
disp('RSI Report Done')



disp('Weekly Report Running')
[repauxcell, repauxmatrix, A_WEEKLY, signsBS]=WeeklyReport(BBGDATA);
disp('Weekly Report Done')
A_WEEKLY=A_WEEKLY(:,[7 11]);A_WEEKLY=cell2mat(A_WEEKLY);




disp('Breakouts Report Running')
if size(BBGDATA,2)>1500
D_BREAKS=[BreaksReport2(BBGDATA,360) BreaksReport2(BBGDATA,120) HLReport(BBGDATA,360) HLReport(BBGDATA,120)];
else D_BREAKS=[BreaksReport2(BBGDATA,360) BreaksReport2(BBGDATA,120)];
end

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
end
clear i spx temp tempp

if size(BBGDATAr,2)>1500
N_BREAKSr=[BreaksReport2(BBGDATAr,360) BreaksReport2(BBGDATAr,120) HLReport(BBGDATAr,360) HLReport(BBGDATAr,120)];
else N_BREAKSr=[BreaksReport2(BBGDATAr,360) BreaksReport2(BBGDATAr,120)];
end

N_BREAKSr(:,[2 4 6 8])=[];
breakpoints=double(ismember(N_BREAKSr,[(datenum(upto)-693960)-4,datenum(upto-693960)]));



disp('Breakouts Report Done')

disp('Accumulation/Distribution Report Running')
if size(BBGDATA,2)>500
[ADD,MDD]=DDReport(BBGDATA);
G_AD=[ADD MDD];
else G_AD=0;
end
disp('Accumulation/Distribution Report Done')



 

for i=1:size(BBGDATA,2),nwr(i,:)=NWR_new(BBGDATA{1,i}(:,4),BBGDATA{1,i}(:,5),7,30);end, clear i
for i=1:size(BBGDATA,2),[obsDate(i,1), obsVol(i,1)]=abnormalVolume(BBGDATA{1,i}(:,1),BBGDATA{1,i}(:,3));end, clear i
for i=1:size(BBGDATA,2),high4(i,:)=findDayOfHighestInWindow(BBGDATA{1,i}(:,4),4);end, clear i
for i=1:size(BBGDATA,2),low4(i,:)=findDayOfLowestInWindow(BBGDATA{1,i}(:,5),4);end, clear i



a_bs=[breakpoints(:,1)+signsBS(:,1)+pLS(:,1)./2   breakpoints(:,2)+signsBS(:,2)+pLS(:,2)./2];
a_bs=[min(a_bs(:,1),6) min(a_bs(:,2),6)]; 


A_WEEKLY=[a_bs A_WEEKLY nwr];
B_LONG=[a_bs B_LONG];
C_SHORT=[a_bs C_SHORT];
D_BREAKS=[a_bs D_BREAKS];
N_BREAKSr=[a_bs N_BREAKSr nwr obsDate obsVol  high4 low4];



clear BBGDATA
cd('C:\101510\database');
save(sprintf('%s-Reports-for-%s.mat',sectype,upto));

disp('Report Saved')

