function [p_min,cov,C,SIGN,aux] = ILS_p_min(x,p,D,w,aux)
%% gather structure fieldnames for dynamic referencing later on
    fn = fieldnames(p);
%% compute weighted jacobian^2 of model, gradient of C, and an approximate hessian of C
    [JwJ,dC] = ILS_JwJ_dC(x,p,D,w,aux); % compute weighted jacobian^2 and gradient of C
    ddC = 2*JwJ; % approximate hessian of C
%% Calculate initial dp depending on whether a stall has been detected
	skip_flag = 0;
	switch aux.stall
		case 0 % stall NOT detected
            dp_init = -pinv(ddC)*(dC'); % Gauss-Newton direction
		otherwise % stall detected
			p_temp = ILS_rand_params(p,aux); % randomly reset parameter vector within boundaries
			dp_init = reshape(param_struct_to_arr(p_temp,aux) - param_struct_to_arr(p,aux),size(dC'));
			skip_flag = 1; % set a flag to skip line search
	end
%% initialize a few things before backtracking line search loop
    max_attempts = 21; % max attempts at backtracking
    fctr_arr = logspace(0,-6,max_attempts); % backtracking line search factors
    c = 1e-4; % slope that defines a "productive" attempt under the Armijo condition
    C_prev = ILS_C(x,p,D,w); % previous C
    dp = dp_init; % first attempt at dp
    p_temp = p; % initialize p_min attempt
%% backtracking line search loop:
	for n=2:max_attempts
	%% update p_min attempt, do a boundary check on each parameter and compute C_0_new
		for i=1:aux.num_var % for each parameter...
			p_temp.(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).val+dp(i); % update parameter
		end
		[in_bounds,p_in_bounds] = check_boundaries(p_temp,aux);
		C_new = ILS_C(x,p_temp,D,w); % C_0 for p_min attempt
	%% determine if p_min attempt is in bounds, productive, and satisfies the Armijo condition (usually dC*dp is negative, but can be positive on rare occasion)
		if all(in_bounds) && (C_new < C_prev) && (C_new < (C_prev + c*dC*dp)) || skip_flag % if p_min attempt is successful...
			p_min = p_temp; % save p_min
			break % exit backtracking loop
		else % p_min attempt was unsuccessful...
			dp = fctr_arr(n)*dp_init; % scale back dp in line search
			if n < max_attempts % if maximum number of line search attempts has NOT been reached...
				continue % send to next attempt of backtracking loop
			else % maximum number of attempts has been reached...
				p_min = p_temp; % save p_min
				if any(~in_bounds) % if any of the new parameters fall out of bounds, push them back in
					p_min = p_in_bounds;
					break
				end
				break % even though this p_min does not meet Armijo condition and/or parameters fell out of bounds, exit backtracking loop anyways
			end
		end
	end
%% update cost function, covariance matrix and confidence intervals
    dC = dC'; % just need to transpose for convenience
    C = ILS_C(x,p_min,D,w); % new value of cost function
	cov = (C/(sum(~~w,'all')-aux.num_var))*pinv(JwJ); % compute covariance matrix
	SIGN = norm(dC.*sqrt(diag(cov)))/C_prev; % SIGN = |grad(C)*SD(p)|/C_prev (unitless, lower limit = machine epsilon)
    for i=1:aux.num_var % calculate standard deviation and 95% confidence intervals of each parameter
        p_min.(fn{aux.var_indx(i)}).SD = sqrt(cov(i,i));
        p_min.(fn{aux.var_indx(i)}).CI = p_min.(fn{aux.var_indx(i)}).val + [-1,1]*sqrt(cov(i,i))*tinv(1-0.05/2,sum(~~w,'all')-aux.num_var);
    end
end
