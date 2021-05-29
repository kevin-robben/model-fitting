function p = ILS_rand_params(p,aux)
	fn = fieldnames(p);
	for i=1:aux.num_var
		p.(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).bounds1 + rand*(p.(fn{aux.var_indx(i)}).bounds2 - p.(fn{aux.var_indx(i)}).bounds1);
	end
end