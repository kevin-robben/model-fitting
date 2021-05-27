function [aux,break_flag] = ILS_check_stall_conv(aux,C_arr,SIGN_arr,SIGN_lim,iter)
	break_flag = 0; % initialize break flag
	if iter > 4 % only check after 4 iterations
		last3_C = C_arr(iter-2:iter); % gather last 3 C
		last3_SIGN = SIGN_arr(iter-2:iter); % gather last 3 SIGN
		if (last3_SIGN(1)<SIGN_lim) && (C_arr(iter)<1.1*min(C_arr)) % check for convergence
			break_flag = 1;
		else % check for stall
			rel_C_dev = (last3_C-mean(last3_C))/mean(last3_C);
			rel_SIGN_dev = (last3_SIGN-mean(last3_SIGN))/mean(last3_SIGN);
			if all( abs(rel_C_dev) < 1e-2 ) && all( abs(rel_SIGN_dev) < 1e-2 ) % stall detected
				aux.stall = aux.stall + 1;
				aux.stall_iter(length(aux.stall_iter)+1) = iter;
			else % stall NOT detected
				aux.stall = 0;
			end
		end
	end
end
