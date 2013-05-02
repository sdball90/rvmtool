%% PLOTR
% *PLOTR* Creates figures to give a graphical representation of the
%  relationships in the database
%
%% HISTORY
%  28 February 2013  Dennis Magee    Original Code
%   3 April    2013  Dennis Magee    Don't plot single hits, plot specific searches
%  14 April    2013  Dennis Magee    Added simple node plots for each column
%
%% PLOTR( ROWNUM, COLUMN_NAMES, SORT, NUM_RESULTS, SPECIFIC )
% * INPUTS
%
% *COLUMN_NAMES* - Array containing the names of the columns
%
% *SORT* - 1 for accending results 0 for decending results
%
% *NUM_RESULTS* - Integer value for max number of results to plot
%
% *SPECIFIC* - 1 for specific search, 0 for general
%
%% METHOD
% * Open Database
% * Get results from database
% * Cut labels to 40 characters
% * Plot the results
% * Close Databese
%
function plotr( rownum, column_names, sort, num_results, specific )
%%%
% Open Database
colnum = length(column_names);
dbid = sqliteopen('test.db');

if specific==0
    for i = 2:colnum
        %%%
        % Get the column
        column = char(column_names(i));
        %%%
        % Grab data to plot for the column
        if ( sort == 0 )
            cmd = sprintf('select column_value,"%s",rownum from "%s" order by "%s"',...
                column,column,column);
        else
            cmd = sprintf('select column_value,"%s",rownum from "%s" order by "%s" desc',...
                column,column,column);
        end
        result = sqlitecmd(dbid,cmd);
        %%%
        % Nothing to plot if result is empty
        if isempty(result)
            continue;
        end
        %%%
        % Set the labels and cut the text to 40 characters each
        labels = result(:,1);
        for j = 1:length(labels)
            if iscellstr(labels(j))
                str = char(labels(j));
                if length(str) > 40
                    labels(j) = cellstr(str(1:40));
                end
            else
                labels(j) = cellstr(mat2str(cell2mat(labels(j))));
            end
        end
        %%%
        % Set the values and change to number array
        values = cell2mat(result(:,2));
        rows = result(:,3);
        ticks = length(find(values~=1));
        if ticks==0
            continue;
        end
        %%%
        % Remove single hits from graphs
        graph_values = zeros(1,ticks);
        graph_labels = cell(1,ticks);
        graph_rows = cell(1,ticks);
        k=1;
        for j=1:length(values)
            if values(j)~=1
                graph_values(k) = values(j);
                graph_labels(k) = labels(j);
                graph_rows(k) = rows(j);
                k = k+1;
            end
        end
        
%% Simple Node Plot
% A simple way to plot the findings in a nodal map

        %%
        % Big circle
        t = linspace(0,2*pi,ticks+2);
        big_x = (rownum)*cos(t);
        big_y = (rownum)*sin(t);
        big_xy = [big_x' big_y'];
        %%
        % Cordinates and connection matrix for nodes
        xy = zeros(rownum,2);
        A = zeros(rownum,rownum);
        figure;
        hold on;
        %%
        % Loop over non-zero relationships
        for j=1:ticks
            num_nodes=1;
            %%%
            % Matrix of rows value was found
            node = str2num(char(graph_rows(j))); %#ok<ST2NM>
            %%
            % Center of the smaller circle
            center = big_xy(j,:);
            if center(1)>=0
                if center(2)>=0
                    t = linspace(pi/4,2*pi+pi/4,length(node)+1);
                else
                    t = linspace(-pi/4,2*pi-pi/4,length(node)+1);
                end
            else
                if center(2)>=0
                    t = linspace(3*pi/4,2*pi+3*pi/4,length(node)+1);
                else
                    t = linspace(-3*pi/4,2*pi-3*pi/4,length(node)+1);
                end
            end
            radius = pi*rownum/(ticks+5);
            x = radius*cos(t)+center(1);
            y = radius*sin(t)+center(2);
            %%
            % Populate connection matrix
            for k=1:length(node)
                for l=k+1:length(node)
                    A(node(k),node(l))=1;
                end
                if ~xy(node(k),1) && ~xy(node(k),2)
                    xy(node(k),1:2) = [x(num_nodes) y(num_nodes)];
                    num_nodes = num_nodes+1;
                end
            end
            %%
            % Labels for big groups
            if num_nodes>1
                if center(1)>=0
                    %%%
                    % 1st quad
                    if center(2)>=0
                        text(max(x),max(y),char(graph_labels(j)),...
                            'FontWeight','bold',...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom');
                    %%%
                    % 4th quad
                    else
                        text(max(x),min(y),char(graph_labels(j)),...
                            'FontWeight','bold',...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','top');
                    end
                else
                    %%%
                    % 2nd quad
                    if center(2)>=0
                        text(min(x),max(y),char(graph_labels(j)),...
                            'FontWeight','bold',...
                            'HorizontalAlignment','right',...
                            'VerticalAlignment','bottom');
                    %%%
                    % 3rd quad
                    else
                        text(min(x),min(y),char(graph_labels(j)),...
                            'FontWeight','bold',...
                            'HorizontalAlignment','right',...
                            'VerticalAlignment','top');
                    end
                end
            end
        end
        %%
        % Set axis and plot nodes
        ax = rownum*(1+pi/ticks);
        axis([-ax ax -ax ax]);
        for j=1:rownum
            if xy(j,1) || xy(j,2)
                text(xy(j,1),xy(j,2),mat2str(j),'EdgeColor','black');
            end
        end
        gplot(A,xy,'-');
        title(column);
        clear A;
        
        %%
        % Create the figure and plot the values
        if (ticks > num_results && num_results > 0)
            if sort==0
                bar_graph(graph_values(end-num_results+1:end),...
                    graph_labels(end-num_results+1:end),num_results,column);
            else
                bar_graph(graph_values(1:num_results),...
                    graph_labels(1:num_results),num_results,column);
            end
        else
            bar_graph(graph_values,graph_labels,ticks,column);
        end
    end
else
    cmd = sprintf('select counts,search_value from Specific_Search');
    result = sqlitecmd(dbid,cmd);
    if ~isempty(result)
        bar_graph(cell2mat(result(1)),result(2),1,column_names);
    end
end
sqliteclose(dbid);
%% bar_graph
% Simple function to create the bar graphs for display
function bar_graph(values,labels,ticks,plot_title)
figure;
barh(values);
set(gca,'YTick',1:ticks,'YTickLabel',labels,...
    'XLim',[min(values)-1 max(values)+1]);
title(plot_title);
xlabel('Number of rows value was found');
ylabel('Values searched');