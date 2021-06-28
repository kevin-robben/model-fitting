function [in_bounds,p_in_bounds] = check_boundaries(p,aux)
    %% check each variable for whether it is within its boundaries
        fn = fieldnames(p);
        p_in_bounds = p;
        for i=1:aux.num_var % for each parameter...
            if p.(fn{aux.var_indx(i)}).val < p.(fn{aux.var_indx(i)}).bounds1
                in_bounds(i) = 0;
                p_in_bounds.(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).bounds1;
			elseif p.(fn{aux.var_indx(i)}).val > p.(fn{aux.var_indx(i)}).bounds2
                in_bounds(i) = 0;
                p_in_bounds.(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).bounds2;
			else
                in_bounds(i) = 1;
            end
        end
    %% and finally, add another boundary check to ensure (T_hom)^-1 > (1/2)*(T_LT)^-1 (could add reorientational term here)
        if p.T_hom_inv.val > (1/2)*p.T_LT_inv.val
			in_bounds(aux.num_var+1) = 1;
        else
            in_bounds(aux.num_var+1) = 0;
            p_in_bounds.T_hom_inv.val = (1/2)*p.T_LT_inv.val;
        end
end