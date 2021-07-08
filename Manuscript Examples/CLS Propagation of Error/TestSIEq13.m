clear all;
close all;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define bandwidth range for fitting to linear absorption
	fit_bw_CLS = 19;
%% load p
	p = load_params('Input Data\p.csv');
%% make axes
	Tw = [ 0:0.1:1 , 1.2:0.2:2 , 2.5:0.5:5, 6:1:10, 15:5:30, 40:20:100];
    x = gen_x([0 4],16,2130,[2110 2190],128,Tw,'real');
%% prepare param struct for linear absorption fitting
	p_struct = p;
	clear p;
	p_struct.A01.val = p_struct.A01.val*(1.6866e-4);
	p_struct.('c') = p_struct.A01;
	p_struct.c.val = 0;
	p_struct.c.label = 'c';
	
	w3_fit_range = [p_struct.w_01.val-fit_bw_CLS/2,p_struct.w_01.val+fit_bw_CLS/2]; % upper 80% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	
	aux = ILS_initialize_aux(p_struct); 
	J_all =  Jacobian_f(fxn,x,p_struct,aux); 
	J_tau = J_all(:,[9,11]); % indicies of p struct corresponding to [A01,c,kubo1_D2,kubo2_D2,T_hom_inv]
	J_p = J_all(:,[1,13,10,12,8]); 
	J_aug = [ J_p' , -J_p'*J_tau ];
	D = fxn(x,p_struct)+0.02; % true linear absorption spectrum
	dD = (1e-6)*randn(size(D)); % noise in linear absorption spectrum
	tau = [p_struct.kubo1_t.val;p_struct.kubo2_t.val ]; % true tau constants
	dtau = (1e-2)*tau.*randn(size(tau)); % noise of tau constants (%10 relative noise)
	daug = [dD;dtau]; % augmented noise vector
	dp = inv(J_p'*J_p)*J_aug*daug; % <-- evaluate SI Eq. 13 here to predict the differential change in p

	true_vals = [p_struct.A01.val,0.02,p_struct.kubo1_D2.val,p_struct.kubo2_D2.val,p_struct.T_hom_inv.val];
	

	%% define a different fit type for each fitting parameter
		tau_exp = tau + dtau;
		noisy_LA = D + dD;
		init_guess = true_vals.*(1+0.1*randn(size(true_vals)));
		fit_type = fittype(@(A01,c,D2_1,D2_2,T_hom_inv,w3) Lin_Abs(x,p_struct,A01,c,tau_exp,[D2_1,D2_2],T_hom_inv,[n3_min,n3_max],w3),'independent','w3');
		fit_options = fitoptions(fit_type);
		fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-20,'TolFun',1e-20,'StartPoint',init_guess);
		[LA_fit,gof,output] = fit(x.w3(n3_min:n3_max)',noisy_LA,fit_type,fit_options);
		dp_fit = (coeffvalues(LA_fit)-true_vals)';

		rel_dp_predicted = dp'./true_vals
		rel_dp_actual_fit = dp_fit'./true_vals
		
		