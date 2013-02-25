function status = rfind(rownum,column_names)
%------------------------------------------------------------------------------
% RFIND looks for relationships between elements in a database
%
% HISTORY:
% 20 December 2012  Dennis Magee   Original Code
% 
% STATUS = RFIND(ROWNUM,COLUMN_NAME)
%
% INPUT:
%	ROWNUM is an integer value of the number of rows in the database
%
%	COLUMN_NAMES is a cell array containing the names of the columns
%
% OUTPUT:
%	STATUS is an integer value specifying a possible error
%		1 if there is an error, 0 if no error
%
% METHOD:
%------------------------------------------------------------------------------
status = 0;

% Open the database test.db
dbid = sqliteopen('test.db');

% Datastructure to hold the results proper
data_counts = {};

% Calculate the number of columns from the array of column names
[~,colnum] = size(column_names);

% Start finding relationships
for i = 1:rownum
    % data structures used to hold each rows relational counts
    row_counts = {};
    string_counts = {};
    
    % Get rows based on tblid = i
    cmd = sprintf('select * from t where tblid = %d', i);
    row = sqlitecmd(dbid,cmd);
    key = {};
    value = {};
    for j = 2:colnum
        
        if iscellstr(row(j))
            
            % Skip row if string is empty
            if isempty(char(row(j)))
                continue;
            end
            
            % split the string on delimeters
            if(strcmp(char(row(j)),';'))
                string = regexp(char(row(j)),';','split');
            else
                string = regexp(char(row(j)),',','split');    
            end
            
            % calculate the string of strings
            [~,length] = size(string);
            result_pairs = {};
			for k = 1:length
				% Remove whitespace from beginning and end of the string
				look = strtrim(string(k));
				% Fix single quotes in the string
				look = strrep(look,'''','''''');
                for l = 2:colnum
                    % Find all rows containing the string and save the table ids
                    cmd = sprintf('select count(tblid) from t where "%s" like ''%%%s%%''', ...
                        char(column_names(1,l)), char(look));   
                    result = sqlitecmd(dbid,cmd);
                    result_pairs{end+1} = {char(column_names(1,l)), result};
                end
                string_counts{end+1}= {string(k), result_pairs};
			end

		% If value in cell is not a string, it is a number
        else
            result_pairs = {};
            for l = 2:colnum
                % Find all rows containing the value and save the table ids
                cmd = sprintf('select count(tblid) from t where "%s" = %d', ...
                    char(column_names(1,l)), cell2mat(row(j)));
                result = sqlitecmd(dbid,cmd);
                result_pairs{end+1} = {char(column_names(1,l)), result};
            end
            string_counts{end+1} = {row(j), result_pairs};
        end
    end 
    data_counts{end+1} = {i,string_counts};
end

status = data_counts;
% Close database
sqliteclose(dbid);
