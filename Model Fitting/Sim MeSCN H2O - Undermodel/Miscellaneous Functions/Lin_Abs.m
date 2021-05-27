function lin_spec = Lin_Abs(x,p,A,c,kubo_t_arr,kubo_D2_arr,T_hom_inv,n3_fit_range,v3)
	%% substitute Kubo parameters
		if numel(kubo_t_arr) == 0
			p.kubo1_t.val = 1;
			p.kubo2_t.val = 1;
			p.kubo3_t.val = 1;
			p.kubo1_D2.val = 0;
			p.kubo2_D2.val = 0;
			p.kubo3_D2.val = 0;
		elseif numel(kubo_t_arr) == 1
			p.kubo1_t.val = kubo_t_arr(1);
			p.kubo2_t.val = 1;
			p.kubo3_t.val = 1;
			p.kubo1_D2.val = kubo_D2_arr(1);
			p.kubo2_D2.val = 0;
			p.kubo3_D2.val = 0;
		elseif numel(kubo_t_arr) == 2
			p.kubo1_t.val = kubo_t_arr(1);
			p.kubo2_t.val = kubo_t_arr(2);
			p.kubo3_t.val = 1;
			p.kubo1_D2.val = kubo_D2_arr(1);
			p.kubo2_D2.val = kubo_D2_arr(2);
			p.kubo3_D2.val = 0;
		elseif numel(kubo_t_arr) == 3
			p.kubo1_t.val = kubo_t_arr(1);
			p.kubo2_t.val = kubo_t_arr(2);
			p.kubo3_t.val = kubo_t_arr(3);
			p.kubo1_D2.val = kubo_D2_arr(1);
			p.kubo2_D2.val = kubo_D2_arr(2);
			p.kubo3_D2.val = kubo_D2_arr(3);
		end
	%% substitute homogeneous dephasing and amplitude
		p.T_hom_inv.val = T_hom_inv;
		p.A01.val = A;
	%% compute linear absorption with offset
		temp = M_1st_order_kubo(x,p)'+c;
	%% trim linear absorption (this is really just to make MATLAB happy when using this as a fitting function)
		lin_spec = zeros(size(v3));
		if numel(v3) >= numel(n3_fit_range(1):n3_fit_range(2))
			lin_spec = temp(n3_fit_range(1):n3_fit_range(2));
		end
end