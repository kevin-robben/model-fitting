%% print all parameters
function print_params(p)
    fn = fieldnames(p);
	for i=1:numel(fn)
		if p.(fn{i}).var == 1
			str = 'variable';
			trunc_CI = sprintf('%.0e',p.(fn{i}).CI);
			stop = str2num(extractAfter(trunc_CI,'e'));
			val = sprintf('%.0e',p.(fn{i}).val);
			start = str2num(extractAfter(val,'e'));
			num_sig_fig = start-stop+1;
			if stop == 0
				trunc_val = sprintf(['%.',num2str(num_sig_fig),'g'],p.(fn{i}).val);
			else
				trunc_val = sprintf(['%#.',num2str(num_sig_fig),'g'],p.(fn{i}).val);
			end
			trunc_CI = sprintf('%.0g',p.(fn{i}).CI);
			fprintf('%i\t%s\t%s\t=\t%s\t+/-\t%s\t%s\n',i,str,fn{i},trunc_val,trunc_CI,p.(fn{i}).units)
		else
			str = 'constant';
			fprintf('%i\t%s\t%s\t=\t%.6g\t%s\n',i,str,fn{i},p.(fn{i}).val,p.(fn{i}).units);
		end
	end
end