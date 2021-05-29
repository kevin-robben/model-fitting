%% print parameters
function print_variables(p,aux)
    fn = fieldnames(p);
	for i=1:aux.num_var
		fprintf('%s\t=\t%.5g (%.5g,%.5g) %s\n',fn{aux.var_indx(i)},p.(fn{aux.var_indx(i)}).val,p.(fn{aux.var_indx(i)}).CI(1),p.(fn{aux.var_indx(i)}).CI(2),p.(fn{aux.var_indx(i)}).units);
	end
end