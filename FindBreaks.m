function out=FindBreaks(high,x,f,dir)
%high is the extreme price intraday high or low
%x is the number of days to look back
%f is the factor for standard deviations
%dir is the direction, 1 for up, 1 for down


if dir==1
%find moving extreme
M=mmax(high,x);
%check if current is extreme
c1=double(high==M);
p1=find(c1==1);%get positions
c1=c1.*high;
b=zeros(size(c1,1),1);
for i=1:size(p1,1)
     c1temp=c1(1:p1(i));
     pivot=c1(p1(i));
     t2=double(c1temp~=0);
     c1temp=pivot-c1temp;
     c1temp=t2.*c1temp;
     c1temp=c1temp(find(c1temp>0));
     avg=mean(c1temp);
     sig=std(c1temp);
     lim=avg-f*sig;
     if lim<0
     b(p1(i))=-2;%std too high, no base
     else c2=sum(double(c1temp<=lim));
          if isempty(c2)==1
             b(p1(i))=-1;%no matching point  
          else b(p1(i))=c2;
          end
     end
     clear c1temp t2 pivot avg sig lim c2
end
clear i
elseif dir==-1
     %find moving extreme
M=mmin(high,x);
%check if current is extreme
c1=double(high==M);
p1=find(c1==1);%get positions
c1=c1.*high;
b=zeros(size(c1,1),1);
for i=1:size(p1,1)
     c1temp=c1(1:p1(i));
     pivot=c1(p1(i));
     t2=double(c1temp~=0);
     c1temp=c1temp-pivot;
     c1temp=t2.*c1temp;
     c1temp=c1temp(find(c1temp>0));
     avg=mean(c1temp);
     sig=std(c1temp);
     lim=avg-f*sig;
     if lim<0
     b(p1(i))=-2;
     else c2=sum(double(c1temp<=lim));
          if isempty(c2)==1
             b(p1(i))=-1;  
          else b(p1(i))=c2;
          end
     end
     clear c1temp t2 pivot avg sig lim c2
end
clear i
else
     error('invalid DIR parameter')
end
out=b;

             

