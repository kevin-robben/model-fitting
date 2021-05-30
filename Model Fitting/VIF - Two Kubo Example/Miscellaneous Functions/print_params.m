%% print all parameters
function print_params(p)
    fn = fieldnames(p);
	for i=1:numel(fn)
		if p.(fn{i}).var == 1
			str = 'variable';
			CI = sprintf('(%.5g,%.5g)',p.(fn{i}).CI(1),p.(fn{i}).CI(2));
		else
			str = 'constant';
			CI = '';
		end
		fprintf('%i\t%s\t%s\t=\t%.5g\t%s\t%s\n',i,str,fn{i},p.(fn{i}).val,CI,p.(fn{i}).units);
	end
end