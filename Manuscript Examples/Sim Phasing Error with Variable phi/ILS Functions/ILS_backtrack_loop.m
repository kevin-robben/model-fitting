function [p_min,C_min] = ILS_backtrack_loop(p,dp_init,dC,x,D,w,aux,max_attempts,fctr_arr,c,C_prev)
%% get fieldnames
    fn = fieldnames(p);
%% initialize p_temp and dp
    p_temp = p;
    dp = dp_init;
%% lmdivide backtracking line search loop:
	for n=2:max_attempts
	%% update p_min attempt, do a boundary check on each parameter and compute C_0_new
		for i=1:aux.num_var % for each parameter...
			p_temp.(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).val+dp(i); % update parameter
		end
		[in_bounds,p_in_bounds] = check_boundaries(p_temp,aux);
		C_new = ILS_C(x,p_temp,D,w); % C_0 for p_min attempt
	%% determine if p_min attempt is in bounds, productive, and satisfies the Armijo condition (usually dC*dp is negative, but can be positive on rare occasion)
        if all(in_bounds) && (C_new < C_prev) && (C_new < (C_prev + c*dC*dp)) % if p_min attempt is successful...
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
	C_min = C_new;
end