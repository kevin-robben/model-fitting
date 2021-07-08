function p = load_params(varargin)
	if nargin == 0
		[file,path] = uigetfile('*.csv','Select a File');
	else
		file = varargin{1};
		path = [];
	end
	if file ~= 0
		try
			tbl = readtable([path,file],'ReadRowNames',true,'PreserveVariableNames',true);
		catch
			return
		end
		if isempty('tbl')
			fprintf('ERROR: Loading parameters failed. Table is empty.');
		elseif size(tbl,2) ~= 9
			fprintf('ERROR: Loading parameters failed. Table must have 10 columns.');
		elseif ~all(strcmp(tbl.Properties.VariableNames,{'Field Name','Type','Value','Lower Bound','Upper Bound','Units','Plot Label','Std. Dev.','95% C.I.'}))
			fprintf('ERROR: Loading parameters failed. First 10 columns of .csv file must be: Row | Field Name | Type | Value | Lower Bound | Upper Bound | Units | Plot Label | Std. Dev. | 95%% C.I.');
		elseif size(tbl,1) < 1
			fprintf('ERROR: Loading parameters failed. Table has no parameters.');
		else
			for i=1:size(tbl,1)
				if ~isvarname(char(tbl{i,1}))
					fprintf('ERROR: Parameter ''%s'' (Row %i) was skipped while loading due to invalid Field Name.',string(tbl{i,1}),i);
					continue
				end
				switch char(tbl{i,2})
					case 'variable'
						var = 1;
					case 'constant'
						var = 0;
					otherwise
						fprintf('ERROR: Parameter ''%s'' (Row %i) is neither ''variable'' nor ''constant''. Defaulting to constant.',string(tbl{i,1}),i);
						var = 0;
				end
				if isnan(tbl{i,3})
					fprintf('ERROR: Parameter ''%s'' (Row %i) was skipped while loading due to NaN value.',string(tbl{i,1}),i);
					continue
				end
				if isinf(tbl{i,3})
					fprintf('ERROR: Parameter ''%s'' (Row %i) was skipped while loading due to inf value.',string(tbl{i,1}),i);
					continue
				end
				if isnan(tbl{i,4}) || isnan(tbl{i,5})
					fprintf('ERROR: Parameter ''%s'' (Row %i) was skipped while loading due to NaN bound(s).',string(tbl{i,1}),i);
					continue
				end
				if isinf(tbl{i,4}) || isinf(tbl{i,5})
					fprintf('ERROR: Parameter ''%s'' (Row %i) was skipped while loading due to inf bound(s).',string(tbl{i,1}),i);
					continue
				end
				p.(char(tbl{i,1})) = struct('var',var,'val',tbl{i,3},'bounds1',tbl{i,4},'bounds2',tbl{i,5},'units',tbl{i,6},'label',tbl{i,7},'SD',tbl{i,8},'CI',tbl{i,9});
			end
			if ~exist('p','var')
				fprintf('ERROR: No valid parameter found while loading.');
			end
		end
	end
end