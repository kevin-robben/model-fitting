function save_params(varargin)
	if nargin == 1
		p = varargin{1};
		[file,path] = uiputfile('*.csv','Save As','p.csv');
	elseif nargin == 2
		p = varargin{1};
		file = varargin{2};
		path = [];
	end
	fn = fieldnames(p);
	num_param = length(fn);
	Data = [];
	for i=1:num_param
		switch p.(fn{i}).var
			case 0
				type = 'constant';
			case 1
				type = 'variable';
		end
		Data = [Data; {fn{i} type p.(fn{i}).val p.(fn{i}).bounds1 p.(fn{i}).bounds2 p.(fn{i}).units p.(fn{i}).label p.(fn{i}).SD p.(fn{i}).CI}]; 
	end
	tbl = cell2table(Data,'VariableNames',{'Field Name','Type','Value','Lower Bound','Upper Bound','Units','Plot Label','Std. Dev.','95% C.I.'},'RowNames',string(1:length(fn)));
	if file ~= 0
		writetable(tbl,[path,file],'WriteRowNames',true,'WriteVariableNames',true);
	end
end