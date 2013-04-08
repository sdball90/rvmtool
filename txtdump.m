function [ status ] = txtdump( column_names, specific )
% TXTDUMP Creates a text file containing a summary of what is in the database
%
% HISTORY
%  5 April    2013  Dennis Magee    Original Code
%
% INPUTS
%   COLUMN_NAMES - Array containing the names of the columns
%   SPECIFIC - 1 for specific search, 0 for general
%
% METHOD
%   Open file to insert text
%   Open database
%   Go through tables in database and print data to text file
%   Close database
%   Close file
%

status = 0;
border = '++++++++++++++++++++++++++++++++++++++++';
border = strcat(border,border,border,border);
% Open text file and database data
fid = fopen('textdump.txt','wt');
if (fid == -1)
    status = 1;
    return;
end
dbid = sqliteopen('test.db');

% If a general search was done
if (specific == 0)
    fprintf(fid,'General Search Results:');
    colnum = length(column_names);
    
    for i = 2:colnum
        column = char(column_names(i));
        fprintf(fid,'\n%s\n%s',border,border);
        fprintf(fid,'\nColumn searched on: "%s"',column);
        
        % Build SQL command and get data
        cmd = sprintf('select column_value,rownum from "%s"',column);
        result = sqlitecmd(dbid,cmd);
        if isempty(result)
            continue;
        end
        values = result(:,1);
        rows = result(:,2);
        clear result;
        
        % Loop through all values in table
        nvalues = length(values);
        for j = 1:nvalues
            if iscellstr(values(j))
                value = char(values(j));
            else
                value = sprintf('%d',cell2mat(values(j)));
            end
            fprintf(fid,'\n\tValue searched for: "%s"\n',value);
            fprintf(fid,'\tRows value was found: %s\n',char(rows(j)));
        end
    end
    
% If a specific search was done
else
    % Build SQL command and get data
    cmd = sprintf('select search_value,rownum from Specific_Search');
    result = sqlitecmd(dbid,cmd);
    
    % Print results to file
    fprintf(fid,'Specific Search Results:\n');
    fprintf(fid,'Column searched on: "%s"\n',column_names);
    fprintf(fid,'\tValue searched for: "%s"\n',char(result(1)));
    fprintf(fid,'\tRows value was found: %s\n',char(result(2)));
end

% Close database and text file
sqliteclose(dbid);
fclose(fid);
