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

% Calculate the number of columns from the array of column names
[~,colnum] = size(column_names);

% Start finding relationships
for i = 2:colnum

	% Get all data elements from one column
	cmd = sprintf('select "%s" from t',char(column_names(i)));
	data = sqlitecmd(dbid,cmd);

	% Start searching for relationships between the row elements
	for j = 1:rownum

		% Check if value in data cell is a string
		if iscellstr(data(j))

			% Skip row if string is empty
			if isempty(char(data(j)))
				continue;
			end

			% Split the string if it contains multiple data elements
			string = regexp(char(data(j)),',','split');
			% Calulate the number of strings to look for
			[~,length] = size(string);
			for k = 1:length
				% Remove whitespace from beginning and end of the string
				look = strtrim(string(k));
				% Fix single quotes in the string
				look = strrep(look,'''','''''');
				% Find all rows containing the string and save the table ids
				cmd = sprintf('select tblid from t where "%s" like ''%%%s%%''', ...
					char(column_names(1,i)), char(look))
				result = sqlitecmd(dbid,cmd)
			end

		% If value in cell is not a string, it is a number
		else
			% Find all rows containing the value and save the table ids
			cmd = sprintf('select tblid from t where "%s" = %d', ...
				char(column_names(1,i)), cell2mat(data(j)))
			result = sqlitecmd(dbid,cmd)
		end
	end
end

% Close database
sqliteclose(dbid);
