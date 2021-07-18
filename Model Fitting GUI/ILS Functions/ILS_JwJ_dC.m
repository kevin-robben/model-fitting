function [JwJ,dC] = ILS_JwJ_dC(x,p,D,w,aux)
tic
%% declare fieldnames struct
	fn = fieldnames(p);
%% define differential step
    step_fctr = (2.2*10^-16)^(1/3);
%% define minimum absolute parameter value as a safeguard against unstable finite difference calculation
	min_param_val = 1e-8; % this value is somewhat arbitrary
%% calculate residual and weight vectors
    M = reshape(ILS_M(x,p),[x.numel,1]);
    D = reshape(D,[x.numel,1]);
    w = reshape(w,[x.numel,1]);
    r = D - M; % residual row vector
%% compute Jacobian by finite difference method
    J = zeros(x.numel,aux.num_var); % initialize Jacobian
	php = repmat(p,aux.num_var);
	phm = repmat(p,aux.num_var);
	parfor i=1:aux.num_var % for each column of Jacobian...
		%% determine step size for each parameter (ph = p + h)
			h = abs(p.(fn{aux.var_indx(i)}).val)*step_fctr;
			if h < min_param_val
				h = min_param_val;
			end
			php(i).(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).val + h;
			phm(i).(fn{aux.var_indx(i)}).val = p.(fn{aux.var_indx(i)}).val - h;
		%% compute finite difference
			J(:,i) = reshape((ILS_M(x,php(i))-ILS_M(x,phm(i)))/(2*h),[x.numel,1]);
	end
%% compute gradient of C and JwJ
	dC = -2*real((r.*w)'*J);
    JwJ = real((J.*w)'*J);
toc
end
