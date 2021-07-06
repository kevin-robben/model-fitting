clear all;
close all;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define bandwidth range for fitting to linear absorption
	fit_bw_naive = 41;
	fit_bw_CLS = 24.5;
%% linear absorption example
	load('Input Data\FID.mat');
	load('Input Data\p.mat');
	w3_fit_range = [p.w_01.val-fit_bw_naive/2,p.w_01.val+fit_bw_naive/2]; % upper 95% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	p_LA = p;
	p_LA.('c') = p_LA.A01;p_LA.c.val = 0;p_LA.c.label = 'c';
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
	fprintf('Naive Fitting Condition Number           : %f\n',ex1_cond_num)
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
		set(ax_1,'ytick',[1e0,1e2,1e4,1e6,1e8,1e10],'yticklabels',{'1','10^2','10^4','10^6','10^8','10^{10}'},'TickLength',[0.03,0])
		xlim(ax_1,[0.5,LA_aux.num_var+0.5])
		ylim(ax_1,[1,1e11])
		ylabel(ax_1,'VIF')
		title(ax_1,{'Naive Fit to','Linear Absorbance'});
%% CLS method example (linear absorbance)
	w3_fit_range = [p.w_01.val-fit_bw_CLS/2,p.w_01.val+fit_bw_CLS/2]; % upper 80% of linear absorption
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
	fprintf('CLS Method Condition Number           : %f\n',ex2_cond_num)
	%% plot linear absorbance
		f = figure;set(f,'Position',[100,100,300,250]);
		ax = axes(f);
		plot(ax,x.w3(n3_min:n3_max),fxn(x,p_CLS)/max(fxn(x,p_CLS)));
		ylim(ax,[0,1])
		xlabel('Frequency (cm^{-1})');ylabel('Absorbance (norm.)');
		title('Linear Asorbance Spectrum for CLS Fit')
	%% plot VIF
		ax_2 = nexttile(t1,31,[1,23]);
		semilogy(ax_2,1:numel(ex2_VIF),ex2_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p_CLS);
		for i=1:CLS_aux.num_var
			ex2_param_labels{i} = p_CLS.(fn{CLS_aux.var_indx(i)}).label;
			ex2_ax_ticks(i) = i;
		end
		set(ax_2,'xtick',ex2_ax_ticks,'xticklabels',ex2_param_labels)
		set(ax_2,'ytick',[1e0,1e2,1e4,1e6,1e8,1e10],'yticklabels',{'1','10^2','10^4','10^6','10^8','10^{10}'},'TickLength',[0.035,0])
		xlim(ax_2,[0.5,CLS_aux.num_var+0.5])
		ylim(ax_2,[1,1e11])
		title(ax_2,'CLS Method');
%% model fitting example
	%% plot VIF
		fprintf('Parameters for model fitting:\n');
		print_params(p);
		ax_3 = nexttile(t1,54,[1,47]);
		ex3_cond_num = plot_VIF(ax_3,x,p);
		fprintf('Model Fitting Condition Number           : %f\n',ex3_cond_num)
		set(ax_3,'ytick',[1e0,1e2,1e4,1e6,1e8,1e10],'yticklabels',{'1','10^2','10^4','10^6','10^8','10^{10}'},'TickLength',[0.02,0])
		ylim(ax_3,[1,1e11])
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
	
	