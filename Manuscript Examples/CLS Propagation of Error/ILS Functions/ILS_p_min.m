function [p_min,cov,C,SIGN,aux] = ILS_p_min(x,p,D,w,aux)
	warning('off','MATLAB:nearlySingularMatrix');
%% gather structure fieldnames for dynamic referencing later on
    fn = fieldnames(p);
%% compute weighted jacobian^2 of model, gradient of C, and an approximate hessian of C
    [JwJ,dC] = ILS_JwJ_dC(x,p,D,w,aux); % compute weighted jacobian^2 and gradient of C
    ddC = 2*JwJ; % approximate hessian of C
%% Calculate initial dp depending on whether a stall has been detected
	skip_flag = 0;
	if aux.stall == 0
        dp = -ddC\dC'; % lmdivide
    else
        p_min = ILS_rand_params(p,aux); % randomly reset parameter vector within boundaries
        skip_flag = 1; % set a flag to skip line search
        C_prev = ILS_C(x,p,D,w); % previous C
	end
%% initialize a few things before backtracking line search loop
    if ~skip_flag
        max_attempts = 30; % max attempts at backtracking
        fctr_arr = logspace(1,-8,max_attempts); % backtracking line search factors
        c = 1e-4; % slope that defines a "productive" attempt under the Armijo condition
        C_prev = ILS_C(x,p,D,w); % previous C
        [p_min,C_min] = ILS_backtrack_loop(p,dp,dC,x,D,w,aux,max_attempts,fctr_arr,c,C_prev);
    end
%% compute condition number
	JwJ_norm = JwJ ./ sqrt( diag(JwJ) * diag(JwJ)' );
	if any(isnan(JwJ_norm),'all') || any(isinf(JwJ_norm),'all') || cond(JwJ_norm) > 1e10
		aux.stall = 1;
		cond_num = 1e10+1;
	else
		s = svd(JwJ_norm);
		cond_num = (max(s)/min(s))^(1/2);
	end
%% update cost function, covariance matrix and confidence intervals
    dC = dC'; % just need to transpose for convenience
	if cond_num > 1e10 && ~skip_flag % if ill-conditioned, exit early and trigger a stall
		C = C_prev;
		cov = inf*ones(aux.num_var); % compute covariance matrix
		SIGN = aux.SIGN_prev; % SIGN = previous value - this will trigger a stall
		p_min = p;
	else % otherwise, continue as normal
		if aux.gpuComputing
			C = gather(ILS_C(x,p_min,D,w)); % new value of cost function
			cov = gather((C/(sum(~~w,'all')-aux.num_var))*inv(JwJ)); % compute covariance matrix
			SIGN = gather(norm(dC.*sqrt(diag(cov)))/C_prev); % SIGN = |grad(C)*SD(p)|/C_prev (unitless, lower limit = machine epsilon)
			DOF = gather(sum(~~w,'all')-aux.num_var);
		else
			C = ILS_C(x,p_min,D,w); % new value of cost function
			cov = (C/(sum(~~w,'all')-aux.num_var))*inv(JwJ); % compute covariance matrix
			SIGN = norm(dC.*sqrt(diag(cov)))/C_prev; % SIGN = |grad(C)*SD(p)|/C_prev (unitless, lower limit = machine epsilon)
			DOF = sum(~~w,'all')-aux.num_var;
		end
		aux.SIGN_prev = SIGN;
	end
	for i=1:aux.num_var % calculate standard deviation and 95% confidence intervals of each parameter
		p_min.(fn{aux.var_indx(i)}).SD = sqrt(cov(i,i));
		p_min.(fn{aux.var_indx(i)}).CI = sqrt(cov(i,i)) * tinv( 1-0.05/2 , DOF );
	end
end
