function arr = param_struct_to_arr(p,aux)
    fn = fieldnames(p);
    for i=1:aux.num_var % for each parameter...
        arr(i) = p.(fn{aux.var_indx(i)}).val;
    end
end