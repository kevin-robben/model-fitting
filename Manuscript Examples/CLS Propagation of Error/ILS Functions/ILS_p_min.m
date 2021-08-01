function [p_min,cov,C,SIGN,aux] = ILS_p_min(x,p,D,w,aux)
	warning('off','MATLAB:nearlySingularMatrix');
%% gather structure fieldnames for dynamic referencing later on
    fn = fieldnames(p);
%% compute weighted jacobian^2 of model, gradient of C, and an approximate hessian of C
    [JwJ,dC] = ILS_JwJ_dC(x,p,D,w,aux); % compute weighted jacobian^2 and gradient of C
    ddC = 2*JwJ; % approximate hessian of C
%% check for inf's, nan's, or ill-conditioning
	JwJ_norm = JwJ ./ sqrt( diag(JwJ) * diag(JwJ)' );
	if any(isnan(JwJ_norm),'all') || any(isinf(JwJ_norm),'all') || cond(JwJ_norm) > 1e10 % if nan or inf present, or ill-conditioned
		aux.is_nan_or_inf = 1;
	else
		aux.is_nan_or_inf = 0;
	end
%% check for stall, nan/inf/ill-conditioning, otherwise compute dp
	skip_flag = 0;
	if aux.stall == 1 % if stall was previously detected in ILS_check_stall_conv
		p_min = ILS_rand_params(p,aux); % randomly reset parameter vector within boundaries
        C_prev = ILS_C(x,p,D,w); % previous C
		aux.stall = 0; % reset stall flag
		aux.is_nan_or_inf = 0; % reset is_nan_or_inf flag
		skip_flag = 1; % set a flag to skip line search
	elseif aux.is_nan_or_inf == 1 % if nan, inf, and/or ill-conditioning present
		p_min = p;
		cov = nan*ones(aux.num_var); % compute covariance matrix as nan
		C = nan; % compute the cost function as nan
		SIGN = nan; % compute the SIGN as nan
		for i=1:aux.num_var % calculate standard deviation and 95% confidence intervals of each parameter as nan
			p_min.(fn{aux.var_indx(i)}).SD = nan;
			p_min.(fn{aux.var_indx(i)}).CI = nan;
		end
		return % exit early
	else % everything is good, compute dp
		dp = -ddC\dC'; % compute dp using lmdivide
	end
%% backtracking line search
	if skip_flag == 0
		max_attempts = 30; % max attempts at backtracking
		fctr_arr = logspace(1,-8,max_attempts); % backtracking line search factors
		c = 1e-4; % slope that defines a "productive" attempt under the Armijo condition
		C_prev = ILS_C(x,p,D,w); % previous C
		[p_min,C_min] = ILS_backtrack_loop(p,dp,dC,x,D,w,aux,max_attempts,fctr_arr,c,C_prev);
	end
%% update cost function, covariance matrix and confidence intervals
    DOF = gather(sum(~~w,'all')-aux.num_var); % degrees of freedom
	dC = dC'; % just need to transpose for convenience
	C = gather(ILS_C(x,p_min,D,w)); % new value of cost function
	cov = gather((C/(sum(~~w,'all')-aux.num_var))*inv(JwJ)); % compute covariance matrix
	SIGN = gather(norm(dC.*sqrt(diag(cov)))/C_prev); % SIGN = |grad(C)*SD(p)|/C_prev (unitless, lower limit = machine epsilon)
	aux.SIGN_prev = gather(SIGN);
	for i=1:aux.num_var % calculate standard deviation and 95% confidence intervals of each parameter
		p_min.(fn{aux.var_indx(i)}).SD = sqrt(cov(i,i));
		p_min.(fn{aux.var_indx(i)}).CI = sqrt(cov(i,i)) * tinv( 1-0.05/2 , DOF );
	end
end
