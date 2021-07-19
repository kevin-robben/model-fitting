function J = Jacobian_f(f,x,p,aux)
%% computes Jacobian of the function f(x,p)
%% declare fieldnames struct
	fn = fieldnames(p);
%% define differential step
    step_fctr = (2.2*10^-16)^(1/3);
%% define minimum absolute parameter value as a safeguard against unstable finite difference calculation
	min_param_val = 1e-8; % this value is somewhat arbitrary
%% compute Jacobian by finite difference method
	N = numel(f(x,p));
	if aux.gpuComputing
		J = gpuArray(complex(zeros(N,aux.num_var))); % initialize Jacobian
	else
		J = complex(zeros(N,aux.num_var)); % initialize Jacobian
	end
	php = repmat(p,aux.num_var);
	phm = repmat(p,aux.num_var);
	for i=1:aux.num_var % for each column of Jacobian...
		%% determine step size for each parameter (ph = p + h)
			h = abs(p.(fn{aux.var_indx(i)}).val)*step_fctr;
			if h < min_param_val
				h = min_param_val;
			end
			php(i).(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).val + h;
			phm(i).(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).val - h;
		%% compute finite difference
			J(:,i) = reshape((f(x,php(i))-f(x,phm(i)))/(2*h),[N,1]);
	end
	if aux.gpuComputing
		J = gather(J);
	end
end
