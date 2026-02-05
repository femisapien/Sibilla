function out=WriteOut(dir,type,dt)
%writes XLSX output from matlab file after running technical reports

cd(dir)
fname=strcat(strcat(strcat(type,'-Reports-for-'),dt),'.mat');
load(fname)


    oname=strcat('C:\101510\INDICES','-',dt,'.xlsx');
    xlswrite('C:\101510\INDICES.xlsx',StockNames,'weekly','A1'); 
    xlswrite('C:\101510\INDICES.xlsx',A_WEEKLY,'weekly','B1'); 
    % COLUMN NAMES: MA13W CROSS DATE
    %               MA13W CROSS SIGN
    %               MA13W CROSS DIRECTION
%     xlswrite('C:\101510\stocks2.xlsx',L_DROP,'fast_drop','A1');
%     % COLUMN NAMES: FD INDICATOR
%     %               FD DATE
%     xlswrite('C:\101510\stocks2.xlsx',S_RISE,'short_rise','A1');
%     % COLUMN NAMES: FR INDICATOR
%     %               FR DATE
%     xlswrite('C:\101510\stocks2.xlsx',D_BREAKS,'breaks','A1');
%     % COLUMN NAMES: BREAKOUT 260D
%     %               BREAKDOWN 260D
%     %               BREAKOUT 80D
%     %               BREAKDOWN 80D
%     xlswrite('C:\101510\stocks2.xlsx',E_BREAKSr,'breaksr','A1');
%     % COLUMN NAMES: BREAKOUT SPX 260D
%     %               BREAKDOWN SPX 260D
%     %               BREAKOUT SPX 80D
%     %               BREAKDOWN SPX 80D    
%     %               NARROW RANGE 7 DAYS	
%     %               WIDE RANGE 30 DAYS	
%     %               LAST DATE VOLUME > 2.5x 50DMA
%     %               VOLUME
%     %               HIGH OF LAST 4 DAYS	
%     %               LOW OF LAST 4 DAYS
%     xlswrite('C:\101510\stocks2.xlsx',G_AD,'acc_dist','A1');
%     % COLUMN NAMES: NUMBER OF ORIGINAL ACCUMULATIONS
%     %               NUMBER OF INTRADAY ACCUMULATIONS
%     %               NUMBER OF ORIGINAL DISTRIBUTIONS
%     %               NUMBER OF INTRADAY DISTRIBUTIONS
%     xlswrite('C:\101510\stocks2.xlsx',H_M2,'model_2','A1');
%     % COLUMN NAMES: Model 2i BUY
%     %               Model 2i SELL
%     %               Model 2l BUY
%     %               Model 2l SELL
%     xlswrite('C:\101510\stocks2.xlsx',I_MA_SIG,'MA_50D_SIG','A1');
%     % COLUMN NAME: RATIO SEC/INDEX SIGNAL
%     
    xlswrite(oname,A_WEEKLY,'weekly','A1');
%     xlswrite(oname,L_DROP,'fast_drop','A1');
%     xlswrite(oname,S_RISE,'short_rise','A1');
%     xlswrite(oname,D_BREAKS,'breaks','A1');
%     xlswrite(oname,E_BREAKSr,'breaksr','A1');
%     xlswrite(oname,G_AD,'acc_dist','A1');
%     xlswrite(oname,H_M2,'model_2','A1');
%     xlswrite(oname,I_MA_SIG,'MA_50D_SIG','A1');


clear oname
out=1;