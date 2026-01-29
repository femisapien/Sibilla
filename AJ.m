function out=AJ(sectype,sold,eold,snew,enew,fix)
cd('C:\101510\database');
load(sprintf('%s-START%s-END%s.mat',sectype,sold,eold))
disp('database loaded')

oldb=BBGDATA;

clear BBGDATA e tickers

load(sprintf('%s-START%s-END%s.mat',sectype,snew,enew))
disp('incremental data loaded')

dnew=BBGDATA;

clear BBGDATA fieldlist

BBGDATA=JoinData(oldb,dnew,1);%include rows

s=sold;
e=enew;

if fix==1
BBGDATA=BlpHolidayFix(BBGDATA,0,5,5);
end

% movefile(sprintf('C:/Users/Lorenzo/Documents/MATLAB/database/%s-START%s-END%s.mat',sectype,sold,eold),'C:/Users/Lorenzo/Documents/MATLAB/database/old parts');
% movefile(sprintf('C:/Users/Lorenzo/Documents/MATLAB/database/%s-START%s-END%s.mat',sectype,snew,enew),'C:/Users/Lorenzo/Documents/MATLAB/database/old parts');


clear oldb dnew  enew snew sold eold

for i=1:size(BBGDATA,2)
    master=BBGDATA{1,1}(:,1);
    masterd=master(end,1);
    temp=BBGDATA{1,i};
    tempd=temp(end,1);
    tempd2=temp(end-1,1);
    if tempd-masterd<=-70|tempd2-masterd<=-70%either last value or second to last (in case of jumps) are to distant from today
        BBGDATA{1,i}=[master ones(size(master,1),5)];
        disp(i)
    end
    clear temp*
end
clear master* i

%disp('Picked Stocks. Deleted excedent stocks.')
save(sprintf('%s-START%s-END%s.mat',sectype,s,e));
%movefile(sprintf('C:/Users/Lorenzo/Documents/MATLAB/database/R%s-START%s-END%s.mat',sectype,s,e),'C:/Users/Lorenzo/Documents/MATLAB/database/old parts');
%disp('old files archived')

clear
disp('Done!')
out=1

