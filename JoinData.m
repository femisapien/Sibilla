function out=JoinData(fixbase,incbase,inctype)
%concatenates data from a historical database with new entries.
%can be used to add new lines, new columns and new variables, but just one
%type of operation per run.
%
%INPUTS:
     % fixbase: database object. New entries will be added to this. CELL {1,sf2} object.
     % incbase: the object to be added to dbase. Also a CELL {1,si2} object.
     % inctype: tells what the function has to do. 
          % 1 TO ADD NEW ROWS TO SAME SET OF VARIABLES
          % 2 TO ADD NEW COLUMNS TO SAME SET OF VARIABLES
          % 3 TO ADD NEW VARIABLES TO OLD DATABASE (WITH THE SAME NUMBER OF ROWS AND COLUMNS)
%*** OPTIONS 1 AND 2 CAN ONLY BE EXECUTED IF THE NUMBER OF VARIALBES IS THE
%    SAME BOTH FOR FIXBASE AND INCBASE.


sf1=size(fixbase,1); sf2=size(fixbase,2);
si1=size(incbase,1); si2=size(incbase,2);


if inctype==1||inctype==2,if sf2~=si2, error('Different number of varialbes. Check'),end,end



if inctype==1%add rows
     for i=1:sf2
          temp=fixbase{1,i};
          temptemp=temp(end,:);
          tinc=incbase{1,i};
          if size(temptemp,2)~=size(tinc,2)
               tinc=zeros(size(tinc,1),size(temptemp,2));
          end
          out{1,i}=[temp ; tinc];
          clear temp* tinc
     end,clear i

elseif inctype==2%add columns
     for i=1:sf2
          temp=fixbase{1,i};
          tinc=incbase{1,i};
          out{1,i}=[temp tinc];
          clear temp tinc
     end,clear i
elseif inctype==3%just increase the matrix
     out=[fixbase incbase];
end

