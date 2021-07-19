function [in_bounds,p_in_bounds] = check_boundaries(p,aux)
    %% check each variable for whether it is within its boundaries
        in_bounds = zeros(aux.num_var+1,1);
		fn = fieldnames(p);
        p_in_bounds = p;
        for i=1:aux.num_var % for each parameter...
            if gather(p.(fn{aux.var_indx(i)}).val) < p.(fn{aux.var_indx(i)}).bounds1
                in_bounds(i) = 0;
                p_in_bounds.(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).bounds1;
			elseif gather(p.(fn{aux.var_indx(i)}).val) > p.(fn{aux.var_indx(i)}).bounds2
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
	%% convert p_in_bounds values to gpuArray if needed
		switch class(p.(fn{1}).val)
			case 'gpuArray'
				for i=1:length(fn)
					p_in_bounds.(fn{i}).val = gpuArray(p_in_bounds.(fn{i}).val);
				end
		end
end