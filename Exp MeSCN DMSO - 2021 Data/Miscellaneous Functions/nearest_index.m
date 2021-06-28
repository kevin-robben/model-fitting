function varargout = nearest_index(axis,axis_values)
    indicies = zeros(size(axis_values));
    %% find indicies
        for i=1:numel(indicies)
            indicies(i) = find(abs(axis-axis_values(i)) == min(abs(axis-axis_values(i))),1);
        end
    %% return indicies
        for i=1:nargout
            varargout{i} = indicies(i);
        end
end