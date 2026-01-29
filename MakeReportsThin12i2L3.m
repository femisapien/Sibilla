function [A_WEEKLY,B_LONG,C_SHORT,D_BREAKS,E_GAPS,F_RSIS,G_AD,H_M3,I_RET,J_TSS,K_M3c,L_M2ic,N_BREAKSr]=MakeReportsThin12i2L3(ifile,sectype,upto,dtype)
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

disp('Model 2 Report Running')
if size(BBGDATA,2)>1500
[m2i, m2l, rsi_wm, m2i_spec]=M2Report(BBGDATA);
F_RSIS=rsi_wm;
L_M2ic=m2i_spec;
else F_RSIS=0;L_M2ic=0;
end
disp('Model 2 Report Done')

disp('Weekly Report Running')
[repauxcell, repauxmatrix, A_WEEKLY, signsBS]=WeeklyReport(BBGDATA);
disp('Weekly Report Done')
A_WEEKLY=A_WEEKLY(:,[7 11]);A_WEEKLY=cell2mat(A_WEEKLY);

disp('Range Report Running')
[range,E_GAPS]=RangeReport(BBGDATA);
range=range(:,[3 6 9]);range=cell2mat(range);
disp('Range Report Done')


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


disp('Model 3 Report Running')
if size(BBGDATA,2)>1500
    range1=5;range2=30;
    tol1=1;tol2=1;
    cp=20;
    mp1=3;mp2=20;
    f=0.75;
    mp=13;
    dp=5;
    bp=3;bl=8;
    sigma=2;
    dcc=7;
    w1=1;w2=1.5;w3=1;w4=1;w5=1.5;
    [m3o, m3c]=Model3ReportN(BBGDATA,range1,range2,tol1,tol2,cp,mp1,mp2,f,mp,dp,bp,bl,sigma,dcc,w1,w2,w3,w4,w5);
    H_M3=m3o;
    K_M3c=m3c;
else 
    range1=5;range2=30;
    tol1=1;tol2=1;
    cp=20;
    mp1=3;mp2=20;
    f=0.75;
    mp=13;
    dp=5;
    bp=3;bl=8;
    sigma=2;
    dcc=7;
    w1=1.375;
    w3=1.375;
    w4=1.375;
    w5=1.875;
    m3o=Model3Report2N(BBGDATA,range1,range2,tol1,tol2,cp,mp1,mp2,f,mp,dp,bp,bl,sigma,dcc,w1,w3,w4,w5);
    H_M3=m3o;
    K_M3c=0;
end
disp('Model 3 Report Done')
 

for i=1:size(BBGDATA,2),nwr(i,:)=NWR_new(BBGDATA{1,i}(:,4),BBGDATA{1,i}(:,5),7,30);end, clear i
for i=1:size(BBGDATA,2),[obsDate(i,1), obsVol(i,1)]=abnormalVolume(BBGDATA{1,i}(:,1),BBGDATA{1,i}(:,3));end, clear i
for i=1:size(BBGDATA,2),high4(i,:)=findDayOfHighestInWindow(BBGDATA{1,i}(:,4),4);end, clear i
for i=1:size(BBGDATA,2),low4(i,:)=findDayOfLowestInWindow(BBGDATA{1,i}(:,5),4);end, clear i



a_bs=[breakpoints(:,1)+signsBS(:,1)+pLS(:,1)./2   breakpoints(:,2)+signsBS(:,2)+pLS(:,2)./2];
a_bs=[min(a_bs(:,1),6) min(a_bs(:,2),6)]; 

if size(BBGDATA,2)>1500
bs_block=[a_bs m2i m2l m3o];
else bs_block=[a_bs m3o];
end

if weekday(today)~=6&&size(BBGDATA,2)>1500
A_WEEKLY=[bs_block A_WEEKLY nwr F_RSIS];
else 
A_WEEKLY=[bs_block A_WEEKLY nwr];
end

B_LONG=[bs_block B_LONG];
C_SHORT=[bs_block C_SHORT];
D_BREAKS=[bs_block range D_BREAKS];
N_BREAKSr=[bs_block range N_BREAKSr nwr obsDate obsVol  high4 low4];

if size(BBGDATA,2)>500
G_AD=[bs_block G_AD];
else G_AD=0;
end

disp('Return Report Running')
[out1,I_RET]=RetReport(BBGDATA,2013,upto);


if size(BBGDATA,2)>1500
    J_TSS=TSSReport(A_WEEKLY,B_LONG,C_SHORT,D_BREAKS,G_AD,I_RET,upto);
else
    J_TSS=0;
end
disp('Return Report Done')

clear BBGDATA
cd('C:\101510\database');
save(sprintf('%s-Reports-for-%s.mat',sectype,upto));

disp('Report Saved')

