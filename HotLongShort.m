function out=HotLongShort(data,int,cond,p)
%verifies a condition that is fresh in a series, that is, occurred for the first time in the last observations
%series is the object of analysis. Contains date and prices
%int sets the length of the new interval, defined in number of observations to search for
%cond is a numeric representation of the condition. possible values are:
%    1 for "equal" on int and "not equal" on the previous observations
%    2 for "not equal" on int and "equal" on the previous observations
%    3 for "less than" on int and "greater than or equal to" on the previous observations
%    4 for "less than or equal to" on int and "greater than" on the previous observations
%    5 for "greater than" on int and "less than or equal to" on the previous observations
%    6 for "greater than or equal to" on int and "less than" on the previous observations
%p is the parameter to search for

data(isnan(data(:,2)),:)=[];
series=data;

if size(series,1)<=int
     out=[0 -2];
else
old=series(1:end-int,:);
new=series(end-int+1:end,:);
if cond==1
     oldsum=sum(old(:,2)==p);if oldsum>0,o=0;else o=1;end
     new2=new(new(:,2)==p,:);if isempty(new2), new2=zeros(1,2);end;newsum=sum(new(:,2)==p);
          if newsum~=0, fl=find(new2(:,2)==p,1,'first');out=[new2(fl,1) o*fl];else out=[o*new2(:,1) o*newsum];end
elseif cond==2
    oldsum=sum(old(:,2)~=p);if oldsum>0,o=0;else o=1;end
     new2=new(new(:,2)~=p,:);if isempty(new2), new2=zeros(1,2);end;newsum=sum(new(:,2)~=p);
          if newsum~=0, fl=find(new2(:,2)~=p,1,'first');out=[new2(fl,1) o*fl];else out=[o*new2(:,1) o*newsum];end
          
%      oldsum=sum(old~=p);if oldsum>0,o=0;else o=1;end
%      new2=(new~=p);newsum=sum(new~=p);
%      if newsum~=0, fl=find(new2==1,1,'first');fl=int+1-fl;out=o*fl;else out=o*newsum;end
elseif cond==3
    oldsum=sum(old(:,2)<p);if oldsum>0,o=0;else o=1;end
     new2=new(new(:,2)<p,:);if isempty(new2), new2=zeros(1,2);end;newsum=sum(new(:,2)<p);
          if newsum~=0, fl=find(new2(:,2)<p,1,'first');out=[new2(fl,1) o*fl];else out=[o*new2(:,1) o*newsum];end
          
%      oldsum=sum(old<p);if oldsum>0,o=0;else o=1;end
%      new2=(new<p);newsum=sum(new<p);
%      if newsum~=0, fl=find(new2==1,1,'first');fl=int+1-fl;out=o*fl;else out=o*newsum;end 
elseif cond==4
    oldsum=sum(old(:,2)<=p);if oldsum>0,o=0;else o=1;end
     new2=new(new(:,2)<=p,:);if isempty(new2), new2=zeros(1,2);end;newsum=sum(new(:,2)<=p);
          if newsum~=0, fl=find(new2(:,2)<=p,1,'first');out=[new2(fl,1) o*fl];else out=[o*new2(:,1) o*newsum];end
    
%      oldsum=sum(old<=p);if oldsum>0,o=0;else o=1;end
%      new2=(new<=p);newsum=sum(new<=p);
%      if newsum~=0, fl=find(new2==1,1,'first');fl=int+1-fl;out=o*fl;else out=o*newsum;end   
elseif cond==5
    oldsum=sum(old(:,2)>p);if oldsum>0,o=0;else o=1;end
     new2=new(new(:,2)>p,:);if isempty(new2), new2=zeros(1,2);end;newsum=sum(new(:,2)>p);
          if newsum~=0, fl=find(new2(:,2)>p,1,'first');out=[new2(fl,1) o*fl];else out=[o*new2(:,1) o*newsum];end
    
%      oldsum=sum(old>p);if oldsum>0,o=0;else o=1;end
%      new2=(new>p);newsum=sum(new>p);
%      if newsum~=0, fl=find(new2==1,1,'first');fl=int+1-fl;out=o*fl;else out=o*newsum;end 
elseif cond==6
    oldsum=sum(old(:,2)>=p);if oldsum>0,o=0;else o=1;end
     new2=new(new(:,2)>=p,:);if isempty(new2), new2=zeros(1,2);end;newsum=sum(new(:,2)>=p);
          if newsum~=0, fl=find(new2(:,2)>=p,1,'first');out=[new2(fl,1) o*fl];else out=[o*new2(:,1) o*newsum];end
    
%      oldsum=sum(old>=p);if oldsum>0,o=0;else o=1;end
%      new2=(new>=p);newsum=sum(new>=p);
%      if newsum~=0, fl=find(new2==1,1,'first');fl=int+1-fl;out=o*fl;else out=o*newsum;end    
end
end
