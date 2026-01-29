function out=TSSReport(A_WEEKLY,B_LONG,C_SHORT,D_BREAKS,G_AD,I_RET,e)
load database\lists\SL102513
TSS= [I_RET(:,2:3) ... %Returns                                       01-02
      (double(I_RET(:,2)>0))... %ADV                                     03
      (double(I_RET(:,2)<0))... %DEC                                     04
      A_WEEKLY(:,1:8) ...% scores                                     05-12
      B_LONG(:,12) ... %rsi                                              13
      double(B_LONG(:,9)==1) ... %hot long                               14
      B_LONG(:,10) ... %fast drop                                        15             
      double(C_SHORT(:,9)==1) ... %hot short                             16
      C_SHORT(:,10) ... %fast rise                                       17
      D_BREAKS(:,10:11) ... %volume and volatility                    18-19  
      double(D_BREAKS(:,12)==(datenum(e)-693960)) ... %breakout 260      20
      double(D_BREAKS(:,13)==(datenum(e)-693960)) ... %breakdown 260     21
      double(D_BREAKS(:,14)==(datenum(e)-693960)) ... %breakout 80       22
      double(D_BREAKS(:,15)==(datenum(e)-693960)) ... %breakdown 80      23
      double(D_BREAKS(:,16)==(datenum(e)-693960)) ... %breakdown 80      24
      double(D_BREAKS(:,17)==(datenum(e)-693960)) ... %breakdown 80      25
      G_AD(:,[9 11])]; %original acculumations and distributions      26-27   
  
  TSSU1=repmat(US,1,size(TSS,2)).*TSS;%US listed
  TSSN1=repmat(NUS,1,size(TSS,2)).*TSS;%NON US listed
  
  TSSU=[nanmean(TSSU1(:,1:2)) nansum(TSSU1(:,3:4))./sum(double(~isnan(TSSU1(:,3)))) ...
      nanmean(TSSU1(:,5:13)) nansum(TSSU1(:,14:17)) nanmean(TSSU1(:,18:19)) nansum(TSSU1(:,20:25)) nanmean(TSSU1(:,26:27))];
 
  TSSN=[nanmean(TSSN1(:,1:2)) nansum(TSSN1(:,3:4))./sum(double(~isnan(TSSN1(:,3)))) ...
      nanmean(TSSN1(:,5:13)) nansum(TSSN1(:,14:17)) nanmean(TSSN1(:,18:19)) nansum(TSSN1(:,20:25)) nanmean(TSSN1(:,26:27))];
  
  
  TSSU=TSSU';
  TSSN=TSSN';
  out=[TSSU TSSN];
  
  
  
  