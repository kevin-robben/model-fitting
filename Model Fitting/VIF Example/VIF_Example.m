clear all;
close all;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% linear absorption example
	load('Input Data\FID.mat');
	load('Input Data\p.mat');
	w3_fit_range = [2162.4-16,2162.4+16]; % upper 95% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	p_LA = p;
	p_LA.('c') = p_LA.A01;p_LA.c.val = 0;p_LA.c.label = 'c';
	p_LA.A12.var = 0;
	p_LA.v_01.var = 0;
	p_LA.cal_err.var = 0;
	p_LA.Anh.var = 0;
	p_LA.kubo_anh_fctr.var = 0;
	p_LA.T_LT_inv.var = 0;
	LA_aux = ILS_initialize_aux(p_LA);
	fprintf('Variables for naive fit to linear absorption:\n');
	print_variables(p_LA,LA_aux)
	ex1_J = Jacobian_f(fxn,x,p_LA,LA_aux);
	ex1_JJ = ex1_J'*ex1_J;
	ex1_norm_JJ = ex1_JJ ./ sqrt( diag(ex1_JJ) * diag(ex1_JJ)' );
	ex1_VIF = diag(inv(ex1_norm_JJ));
	s = svd(ex1_norm_JJ);
	ex1_cond_num = (max(s)/min(s))^(1/2);
	fprintf('Naive Fitting Condition Number           : %f\n',ex1_cond_num)
	%% plot linear absorbance
		f = figure;
		plot(x.w3(n3_min:n3_max),fxn(x,p_LA)/max(fxn(x,p_LA)));
		xlabel('frequency');ylabel('Absorbance (arb. unit)');
		title('Linear Asorbance Spectrum')
	%% plot VIF
		f1 = figure;t1 = tiledlayout(f1,1,100,'Padding','compact','TileSpacing','compact');
		set(f1,'Position',[50 50 600 200]);
		ax1_1 = nexttile(t1,1,[1,30]);
		semilogy(ax1_1,1:numel(ex1_VIF),ex1_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p_LA);
		for i=1:LA_aux.num_var
			ex1_param_labels{i} = p_LA.(fn{LA_aux.var_indx(i)}).label;
			ex1_ax_ticks(i) = i;
		end
		set(ax1_1,'xtick',ex1_ax_ticks,'xticklabels',ex1_param_labels)
		set(ax1_1,'ytick',[1e0,1e2,1e4,1e6,1e8],'yticklabels',{'1','10^2','10^4','10^6','10^8'},'TickLength',[0.03,0])
		xlim(ax1_1,[0.5,LA_aux.num_var+0.5])
		ylim(ax1_1,[1,1e9])
		ylabel(ax1_1,'VIF')
		title(ax1_1,{'Naive Fit to','Linear Absorbance'});
%% CLS method example (linear absorbance)
	w3_fit_range = [2162.4-9,2162.4+9]; % upper 80% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	p_CLS = p_LA;
	p_CLS.kubo1_t.var = 0;
	p_CLS.kubo2_t.var = 0;
	CLS_aux = ILS_initialize_aux(p_CLS);
	fprintf('Variables for CLS fit to linear absorption:\n');
	print_variables(p_CLS,CLS_aux)
	ex2_J = Jacobian_f(fxn,x,p_CLS,CLS_aux);
	ex2_JJ = ex2_J'*ex2_J;
	ex2_norm_JJ = ex2_JJ ./ sqrt( diag(ex2_JJ) * diag(ex2_JJ)' );
	ex2_VIF = diag(inv(ex2_norm_JJ));
	s = svd(ex2_norm_JJ);
	ex2_cond_num = (max(s)/min(s))^(1/2);
	fprintf('CLS Method Condition Number           : %f\n',ex2_cond_num)
	%% plot VIF
		ax1_2 = nexttile(t1,31,[1,23]);
		semilogy(ax1_2,1:numel(ex2_VIF),ex2_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p_CLS);
		for i=1:CLS_aux.num_var
			ex2_param_labels{i} = p_CLS.(fn{CLS_aux.var_indx(i)}).label;
			ex2_ax_ticks(i) = i;
		end
		set(ax1_2,'xtick',ex2_ax_ticks,'xticklabels',ex2_param_labels)
		set(ax1_2,'ytick',[1e0,1e2,1e4,1e6,1e8],'yticklabels',{'1','10^2','10^4','10^6','10^8'},'TickLength',[0.035,0])
		xlim(ax1_2,[0.5,CLS_aux.num_var+0.5])
		ylim(ax1_2,[1,1e9])
		title(ax1_2,'CLS Method');
%% model fitting example
	%% generate weight mask
		% weight along pump time axis
			w_t1 = reshape(ones(size(x.t1)),[x.N1,1,1]);
		% weight along waiting time axis
			w_Tw = reshape(ones(size(x.Tw)),[1,1,x.N2]);
			n_start = nearest_index(x.Tw,0.3);
			w_Tw(1:(n_start-1)) = 0;
		% weight along probe frequency axis
			w_w3 = reshape(ones(size(x.w3)),[1,x.N3,1]);
		% composite weight
			w = w_t1.*w_Tw.*w_w3;
	%% compute jacobian
		aux = ILS_initialize_aux(p);
		fprintf('Variables for model fitting:\n');
		print_variables(p,aux);
		fxn = @(x,p) M_3rd_order_kubo(x,p);
		ex3_J = Jacobian_f(fxn,x,p,aux);
		ex3_JJ = real(ex3_J'*ex3_J);
		ex3_norm_JJ = ex3_JJ ./ sqrt( diag(ex3_JJ) * diag(ex3_JJ)' );
		ex3_VIF = diag(inv(ex3_norm_JJ));
		s = svd(ex3_norm_JJ);
		ex3_cond_num = (max(s)/min(s))^(1/2);
		fprintf('Model Fitting Condition Number           : %f\n',ex3_cond_num)
	%% plot VIF
		ax1_3 = nexttile(t1,54,[1,47]);
		semilogy(ax1_3,1:numel(ex3_VIF),ex3_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p);
		for i=1:aux.num_var
			ex3_param_labels{i} = p.(fn{aux.var_indx(i)}).label;
			ex3_ax_ticks(i) = i;
		end
		set(ax1_3,'xtick',ex3_ax_ticks,'xticklabels',ex3_param_labels)
		set(ax1_3,'ytick',[1e0,1e2,1e4,1e6,1e8],'yticklabels',{'1','10^2','10^4','10^6','10^8'},'TickLength',[0.02,0])
		xlim(ax1_3,[0.5,aux.num_var+0.5])
		ylim(ax1_3,[1,1e9])
		title(ax1_3,'Model Fitting');
%% add labels
	annotation(f1,'textbox',[0.015 0.86 0.1 0.1],'String','(A)','LineStyle','none','FitBoxToText','off');
	annotation(f1,'textbox',[0.30 0.86 0.1 0.1],'String','(B)','LineStyle','none','FitBoxToText','off');
	annotation(f1,'textbox',[0.515 0.86 0.1 0.1],'String','(C)','LineStyle','none','FitBoxToText','off');
%% save figure
	savefig(f1,'Output Data\VIF.fig');
%% save to output
	save('Output Data\results.mat','ex1_VIF','ex2_VIF','ex3_VIF');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');	
	
	