clear all;
close all;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define bandwidth range for fitting to linear absorption
	fit_bw = 19;
%% load p
	p = load_params('Input Data\p.csv');
%% make axes
	Tw = [ 0:0.1:1 , 1.2:0.2:2 , 2.5:0.5:5, 6:1:10, 15:5:30, 40:20:100];
    x = gen_x([0 4],16,2130,[2110 2190],128,Tw,'real');
%% prepare param struct for linear absorption fitting
	w3_fit_range = [p.w_01.val-fit_bw/2,p.w_01.val+fit_bw/2]; % upper 80% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	p_LA = p;
	p_LA.A01.val = p_LA.A01.val*(1.6866e-4);
	p_LA.c = p_LA.A01;
	p_LA.c.val = 0;
	p_LA.c.label = 'c';
	p_LA.A12.var = 0;
	p_LA.w_01.var = 0;
	p_LA.cal_err.var = 0;
	p_LA.Anh.var = 0;
	p_LA.kubo_anh_fctr.var = 0;
	p_LA.T_LT_inv.var = 0;
	LA_aux = ILS_initialize_aux(p_LA);
	fprintf('Parameters for naive fit to linear absorption:\n');
	print_params(p_LA)
	ex1_J = Jacobian_f(fxn,x,p_LA,LA_aux);
	ex1_JJ = ex1_J'*ex1_J;
	ex1_norm_JJ = ex1_JJ ./ sqrt( diag(ex1_JJ) * diag(ex1_JJ)' );
	ex1_VIF = diag(inv(ex1_norm_JJ));
	s = svd(ex1_norm_JJ);
	ex1_cond_num = (max(s)/min(s))^(1/2);
	fprintf('Naive Fitting Condition Number           : %e\n',ex1_cond_num)
	%% plot linear absorbance
		f = figure;set(f,'Position',[100,100,300,250]);
		ax = axes(f);
		plot(ax,x.w3(n3_min:n3_max),fxn(x,p_LA)/max(fxn(x,p_LA)));
		ylim(ax,[0,1])
		xlabel('Frequency (cm^{-1})');ylabel('Absorbance (norm.)');
		title('Linear Asorbance Spectrum for Naive Fit')
	%% plot VIF
		f1 = figure;t1 = tiledlayout(f1,1,100,'Padding','compact','TileSpacing','compact');
		set(f1,'Position',[50 50 600 200]);
		ax_1 = nexttile(t1,1,[1,30]);
		semilogy(ax_1,1:numel(ex1_VIF),ex1_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p_LA);
		for i=1:LA_aux.num_var
			ex1_param_labels{i} = p_LA.(fn{LA_aux.var_indx(i)}).label;
			ex1_ax_ticks(i) = i;
		end
		set(ax_1,'xtick',ex1_ax_ticks,'xticklabels',ex1_param_labels)
		set(ax_1,'ytick',[1e0,1e2,1e4,1e6,1e8,1e10,1e12],'yticklabels',{'1','10^2','10^4','10^6','10^8','10^{10}','10^{12}'},'TickLength',[0.03,0])
		xlim(ax_1,[0.5,LA_aux.num_var+0.5])
		ylim(ax_1,[1,1e13])
		ylabel(ax_1,'VIF')
		title(ax_1,{'Naive Fit to','Linear Absorbance'});
%% CLS method example (linear absorbance)
	w3_fit_range = [p.w_01.val-fit_bw/2,p.w_01.val+fit_bw/2]; % upper 80% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	p_CLS = p_LA;
	p_CLS.kubo1_t.var = 0;
	p_CLS.kubo2_t.var = 0;
	CLS_aux = ILS_initialize_aux(p_CLS);
	fprintf('Parameters for CLS fit to linear absorption:\n');
	print_params(p_CLS)
	ex2_J = Jacobian_f(fxn,x,p_CLS,CLS_aux);
	ex2_JJ = ex2_J'*ex2_J;
	ex2_norm_JJ = ex2_JJ ./ sqrt( diag(ex2_JJ) * diag(ex2_JJ)' );
	ex2_VIF = diag(inv(ex2_norm_JJ));
	s = svd(ex2_norm_JJ);
	ex2_cond_num = (max(s)/min(s))^(1/2);
	fprintf('CLS Method Condition Number           : %e\n',ex2_cond_num)
	%% plot linear absorbance
		f = figure;set(f,'Position',[100,100,300,250]);
		ax = axes(f);
		plot(ax,x.w3(n3_min:n3_max),fxn(x,p_CLS)/max(fxn(x,p_CLS)));
		ylim(ax,[0,1])
		xlabel('Frequency (cm^{-1})');ylabel('Absorbance (norm.)');
		title('Linear Asorbance Spectrum for CLS Fit')
	%% plot VIF
		ax_2 = nexttile(t1,31,[1,23]);
		semilogy(ax_2,1:numel(ex2_VIF),ex2_VIF,'sk')
		fn = fieldnames(p_CLS);
		for i=1:CLS_aux.num_var
			ex2_param_labels{i} = p_CLS.(fn{CLS_aux.var_indx(i)}).label;
			ex2_ax_ticks(i) = i;
		end
		set(ax_2,'xtick',ex2_ax_ticks,'xticklabels',ex2_param_labels)
		set(ax_2,'ytick',[1e0,1e2,1e4,1e6,1e8,1e10,1e12],'yticklabels',{'1','10^2','10^4','10^6','10^8','10^{10}','10^{12}'},'TickLength',[0.035,0])
		xlim(ax_2,[0.5,CLS_aux.num_var+0.5])
		ylim(ax_2,[1,1e13])
		title(ax_2,'CLS Method');
%% CLS method example (linear absorbance, propagating time constant error)
	w3_fit_range = [p.w_01.val-fit_bw/2,p.w_01.val+fit_bw/2]; % upper 80% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	p_aug = p;
	p_aug.A01.val = p_aug.A01.val*(1.6866e-4);
	p_aug.c = p_aug.A01;
	p_aug.c.val = 0;
	CLS_aug_aux = ILS_initialize_aux(p_aug);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	fprintf('Parameters for CLS fit to linear absorption:\n');
	print_params(p_aug)
	J_all =  Jacobian_f(fxn,x,p_aug,CLS_aug_aux); 
	J_tau = J_all(:,[9,11]); % indicies of p struct corresponding to [A01,c,kubo1_D2,kubo2_D2,T_hom_inv]
	J_p = J_all(:,[1,13,10,12,8]); 
	J_aug = [ J_p' , -J_p'*J_tau ]';
	dD = (1e-6)*ones(1,size(J_p,1));
	dtau = [p_aug.kubo1_t.val,p_aug.kubo2_t.val]*0.1;
	daug = [dD,dtau];
	
	cov_aug = inv(J_p'*J_p)*J_aug'*diag([dD.^2,dtau.^2])*J_aug*inv(J_p'*J_p);
	var_lin_ind = (dD(1)).^2./diag(J_p'*J_p);
	VIF_aug = diag(cov_aug)./var_lin_ind;

	aug_JJ = J_aug'*diag([dD.^2,dtau.^2])*J_aug;
	aug_norm_JJ = aug_JJ ./ sqrt( diag(aug_JJ) * diag(aug_JJ)' );
	ex2_VIF = diag(inv(aug_norm_JJ));
	s = svd(aug_norm_JJ);
	aug_cond_num = (max(s)/min(s))^(1/2);
	fprintf('CLS Method Condition Number with Uncertain tau          : %e\n',aug_cond_num)
	%% plot linear absorbance
		f = figure;set(f,'Position',[100,100,300,250]);
		ax = axes(f);
		plot(ax,x.w3(n3_min:n3_max),fxn(x,p_aug)/max(fxn(x,p_aug)));
		ylim(ax,[0,1])
		xlabel('Frequency (cm^{-1})');ylabel('Absorbance (norm.)');
		title('Linear Asorbance Spectrum for CLS Fit')
	%% plot VIF
		ax_2 = nexttile(t1,31,[1,23]);
		hold(ax_2,'on')
		semilogy(ax_2,1:numel(VIF_aug),VIF_aug,'k.','MarkerSize',12)
		xlim(ax_2,[0.5,CLS_aux.num_var+0.5])
		ylim(ax_2,[1,1e13])
		title(ax_2,'CLS Method');
% 		legend(ax_2,'Fixed \tau','Uncertain \tau');
%% model fitting example
	%% plot VIF
		fprintf('Parameters for model fitting:\n');
		print_params(p);
		ax_3 = nexttile(t1,54,[1,47]);
		ex3_cond_num = plot_VIF(ax_3,x,p);
		fprintf('Model Fitting Condition Number           : %e\n',ex3_cond_num)
		set(ax_3,'ytick',[1e0,1e2,1e4,1e6,1e8,1e10,1e12],'yticklabels',{'1','10^2','10^4','10^6','10^8','10^{10}','10^{12}'},'TickLength',[0.02,0])
		ylim(ax_3,[1,1e13])
		ylabel(ax_3,'');
		title(ax_3,'Model Fitting');
%% add labels
	annotation(f1,'textbox',[0.015 0.86 0.1 0.1],'String','(A)','LineStyle','none','FitBoxToText','off');
	annotation(f1,'textbox',[0.30 0.86 0.1 0.1],'String','(B)','LineStyle','none','FitBoxToText','off');
	annotation(f1,'textbox',[0.515 0.86 0.1 0.1],'String','(C)','LineStyle','none','FitBoxToText','off');
%% save figure
	savefig(f1,'Output Data\VIF.fig');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');	
	
	