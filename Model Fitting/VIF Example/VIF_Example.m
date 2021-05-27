clear all;
close all;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% linear absorption example
	load('Input Data\FID.mat');
	load('Input Data\p.mat');
	v3_fit_range = [2162.4-16,2162.4+16]; % upper 95% of linear absorption
	[n3_min,n3_max] = nearest_index(x.v3,v3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.v3);
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
	
	ex1_J_cent = ex1_J - mean(ex1_J,1).*[1,1,1,1,1,1,0];
	ex1_JJ_cent = ex1_J_cent'*ex1_J_cent;
	ex1_norm_JJ_cent = ex1_JJ_cent ./ sqrt( diag(ex1_JJ_cent) * diag(ex1_JJ_cent)' );
	ex1_VIF_cent = diag(inv(ex1_norm_JJ_cent));
	s_cent = svd(ex1_norm_JJ_cent);
	ex1_cond_num_cent = (max(s_cent)/min(s_cent))^(1/2);
	fprintf('Naive Fitting Condition Number           : %f\n',ex1_cond_num)
	fprintf('Naive Fitting Condition Number (centered): %f\n\n',ex1_cond_num_cent)
	%% plot linear absorbance
		f = figure;
		plot(x.v3(n3_min:n3_max),fxn(x,p_LA)/max(fxn(x,p_LA)));
		xlabel('frequency');ylabel('Absorbance (arb. unit)');
		title('Linear Asorbance Spectrum')
	%% plot VIF
		f1 = figure;t1 = tiledlayout(f1,1,100,'Padding','compact','TileSpacing','compact');
		set(f1,'Position',[50 50 800 250]);
		ax1_1 = nexttile(t1,1,[1,30]);
		semilogy(ax1_1,1:numel(ex1_VIF),ex1_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p_LA);
		for i=1:LA_aux.num_var
			ex1_param_labels{i} = p_LA.(fn{LA_aux.var_indx(i)}).label;
			ex1_ax_ticks(i) = i;
		end
		hold(ax1_1,'on');
		plot(ax1_1,(0:LA_aux.num_var+1),10*ones(size(0:LA_aux.num_var+1)),'k--')
		set(ax1_1,'xtick',ex1_ax_ticks,'xticklabels',ex1_param_labels)
		xlim(ax1_1,[0,LA_aux.num_var+1])
		ylim(ax1_1,[1,1e9])
		ylabel('Variance Inflation Factor (VIF)')
		title('Naive Fit to Linear Absorbance');
	%% plot centered VIF
		semilogy(ax1_1,1:numel(ex1_VIF_cent),ex1_VIF_cent,'r.','MarkerSize',12)
%% CLS method example (linear absorbance)
	v3_fit_range = [2162.4-9,2162.4+9]; % upper 80% of linear absorption
	[n3_min,n3_max] = nearest_index(x.v3,v3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.v3);
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
	
	ex2_J_cent = ex2_J - mean(ex2_J,1).*[1,1,1,1,0];
	ex2_JJ_cent = ex2_J_cent'*ex2_J_cent;
	ex2_norm_JJ_cent = ex2_JJ_cent ./ sqrt( diag(ex2_JJ_cent) * diag(ex2_JJ_cent)' );
	ex2_VIF_cent = diag(inv(ex2_norm_JJ_cent));
	s_cent = svd(ex2_norm_JJ_cent);
	ex2_cond_num_cent = (max(s_cent)/min(s_cent))^(1/2);
	fprintf('CLS Method Condition Number           : %f\n',ex2_cond_num)
	fprintf('CLS Method Condition Number (centered): %f\n\n',ex2_cond_num_cent)
	%% plot VIF
		ax1_2 = nexttile(t1,31,[1,25]);
		semilogy(ax1_2,1:numel(ex2_VIF),ex2_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p_CLS);
		for i=1:CLS_aux.num_var
			ex2_param_labels{i} = p_CLS.(fn{CLS_aux.var_indx(i)}).label;
			ex2_ax_ticks(i) = i;
		end
		hold(ax1_2,'on');
		plot(ax1_2,(0:CLS_aux.num_var+1),10*ones(size(0:CLS_aux.num_var+1)),'k--')
		set(ax1_2,'xtick',ex2_ax_ticks,'xticklabels',ex2_param_labels)
		xlim(ax1_2,[0,CLS_aux.num_var+1])
		ylim(ax1_2,[1,1e9])
		ylabel('Variance Inflation Factor (VIF)')
		title('CLS Method');
	%% plot centered VIF
		semilogy(ax1_2,1:numel(ex2_VIF_cent),ex2_VIF_cent,'r.','MarkerSize',12)
%% model fitting example
	%% generate weight mask
		% weight along pump time axis
			w_t1 = reshape(ones(size(x.t1)),[x.N1,1,1]);
		% weight along waiting time axis
			w_Tw = reshape(ones(size(x.Tw)),[1,1,x.N2]);
			n_start = nearest_index(x.Tw,0.3);
			w_Tw(1:(n_start-1)) = 0;
		% weight along probe frequency axis
			w_v3 = reshape(ones(size(x.v3)),[1,x.N3,1]);
		% composite weight
			w = w_t1.*w_Tw.*w_v3;
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

		ex3_J_cent = ex3_J - mean(ex3_J,1);
		ex3_JJ_cent = real(ex3_J_cent'*ex3_J_cent);
		ex3_norm_JJ_cent = ex3_JJ_cent ./ sqrt( diag(ex3_JJ_cent) * diag(ex3_JJ_cent)' );
		ex3_VIF_cent = diag(inv(ex3_norm_JJ_cent));
		s_cent = svd(ex3_norm_JJ_cent);
		ex3_cond_num_cent = (max(s_cent)/min(s_cent))^(1/2);
		fprintf('Model Fitting Condition Number           : %f\n',ex3_cond_num)
		fprintf('Model Fitting Condition Number (centered): %f\n',ex3_cond_num_cent)
		
	%% plot VIF
		ax1_3 = nexttile(t1,56,[1,45]);
		semilogy(ax1_3,1:numel(ex3_VIF),ex3_VIF,'k.','MarkerSize',12)
		fn = fieldnames(p);
		for i=1:aux.num_var
			ex3_param_labels{i} = p.(fn{aux.var_indx(i)}).label;
			ex3_ax_ticks(i) = i;
		end
		hold(ax1_3,'on');
		plot(ax1_3,(0:aux.num_var+1),10*ones(size(0:aux.num_var+1)),'k--')
		set(ax1_3,'xtick',ex3_ax_ticks,'xticklabels',ex3_param_labels)
		xlim(ax1_3,[0,aux.num_var+1])
		ylim(ax1_3,[1,1e9])
		ylabel(ax1_3,'Variance Inflation Factor (VIF)')
		title(ax1_3,'Model Fitting');
	%% plot centered VIF
		semilogy(ax1_3,1:numel(ex3_VIF_cent),ex3_VIF_cent,'r.','MarkerSize',12)
%% add labels
	annotation(f1,'textbox',[0.015 0.86 0.041 0.12],'String','(A)','LineStyle','none','FitBoxToText','off');
	annotation(f1,'textbox',[0.30 0.86 0.041 0.12],'String','(B)','LineStyle','none','FitBoxToText','off');
	annotation(f1,'textbox',[0.53 0.86 0.041 0.12],'String','(C)','LineStyle','none','FitBoxToText','off');
%% save figure
	savefig(f1,'Output Data\VIF.fig');
%% save figure
	fig = openfig('Output Data\VIF.fig');
	delete(fig.Children.Children(1).Children(1))
	delete(fig.Children.Children(2).Children(1))
	delete(fig.Children.Children(3).Children(1))
%% save figure
	savefig(fig,'Output Data\VIF uncentered only.fig');
%% save to output
	save('Output Data\results.mat','ex1_VIF','ex2_VIF','ex3_VIF');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');	
	
	