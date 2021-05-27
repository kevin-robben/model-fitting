function aux = ILS_initialize_aux(p)
	fn = fieldnames(p);
    aux.('num_var') = 0;
    for i=1:numel(fn)
        if p.(fn{i}).var == 1
            aux.num_var = aux.num_var + 1;
            var_indx(aux.num_var) = i;
        end
    end
    aux.('var_indx') = var_indx;
	aux.('stall') = 0;
	aux.('stall_iter') = [];
end