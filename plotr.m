function plotr( column_names )
% PLOTR Creates figures to give a graphical representation of the
% relationships in the database
%
% INPUTS
colnum = length(column_names);
dbid = sqliteopen('test.db');
for i = 2:colnum
    cmd = sprintf('select column_value,"%s" from "%s" order by column_value',...
        char(column_names(i)),char(column_names(i)));
    result = sqlitecmd(dbid,cmd);
    if ~isempty(result)
        labels = result(:,1);
        for j = 1:length(labels)
            if iscellstr(labels(j))
                str = char(labels(j));
                if length(str) > 30
                    labels(j) = cellstr(str(1:30));
                end
            end
        end
        values = cell2mat(result(:,2));
        ticks = length(values);
        figure;
        barh(values);
        set(gca,'YTick',1:ticks,'YTickLabel',labels,...
            'XLim',[min(values) max(values)+1]);
        title(char(column_names(i)));
    end
end
sqliteclose(dbid);