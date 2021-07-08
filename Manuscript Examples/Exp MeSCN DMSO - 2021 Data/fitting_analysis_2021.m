clear all
close all
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% load data
	load('Output Data\2020 results.mat');
	load('Output Data\CLS Analysis (2020 Data).mat');
	aux_2020 = aux;
	load('Input Data\2021 data (MATLAB-Ready).mat');
	load('Output Data\Undersampling.mat');
%% load p
	p = load_params('Input Data\one-kubo init guess.csv');
%% load chosen fits into p_best_fit
	load('Output Data\p_best_fit.mat');
%% set plot limits
	w1_plot_lim = [2110,2180];
	w3_plot_lim = [2110,2180];
%% initialize figures
	LA_fig = figure;
		set(LA_fig,'Position',[50 50 300 500]);
		LA_layout = tiledlayout(LA_fig,2,1,'Padding','compact','TileSpacing','compact');
		fit_LA_ax = nexttile(LA_layout,1);
			axes(fit_LA_ax)
			fit_LA_ax.Box = 'on';
		CLS_LA_ax = nexttile(LA_layout,2);
			axes(CLS_LA_ax)
			CLS_LA_ax.Box = 'on';
	LA_fig2 = figure;
		set(LA_fig2,'Position',[50 50 300 500]);
		LA_layout2 = tiledlayout(LA_fig2,2,1,'Padding','compact','TileSpacing','compact');
		fit_LA_ax2 = nexttile(LA_layout2,1);
			axes(fit_LA_ax2)
			fit_LA_ax2.Box = 'on';
		CLS_LA_ax2 = nexttile(LA_layout2,2);
			axes(CLS_LA_ax2)
			CLS_LA_ax2.Box = 'on';
	CLS_fig = figure;
		set(CLS_fig,'Position',[50 50 300 500]);
		CLS_layout = tiledlayout(CLS_fig,2,1,'Padding','compact','TileSpacing','compact');
		CLS_2020vs2021_ax = nexttile(CLS_layout,1);
			axes(CLS_2020vs2021_ax)
			CLS_2020vs2021_ax.Box = 'on';
		CLS_2021_ax = nexttile(CLS_layout,2);
			axes(CLS_2021_ax)
			CLS_2021_ax.Box = 'on';
	params_fig = figure;
		set(params_fig,'Position',[50 50 300 500]);
		params_layout = tiledlayout(params_fig,3,2,'Padding','compact','TileSpacing','compact');
		CLS_kubo1_t_ax = nexttile(params_layout,1);
			axes(CLS_kubo1_t_ax)
			CLS_kubo1_t_ax.Box = 'on';
			hold(CLS_kubo1_t_ax,'on');
		fit_kubo1_t_ax = nexttile(params_layout,2);
			axes(fit_kubo1_t_ax)
			fit_kubo1_t_ax.Box = 'on';
			hold(fit_kubo1_t_ax,'on');
		CLS_kubo1_D2_ax = nexttile(params_layout,3);
			axes(CLS_kubo1_D2_ax)
			CLS_kubo1_D2_ax.Box = 'on';
			hold(CLS_kubo1_D2_ax,'on');
		fit_kubo1_D2_ax = nexttile(params_layout,4);
			axes(fit_kubo1_D2_ax)
			fit_kubo1_D2_ax.Box = 'on';
			hold(fit_kubo1_D2_ax,'on');
		CLS_T_hom_inv_ax = nexttile(params_layout,5);
			axes(CLS_T_hom_inv_ax)
			CLS_T_hom_inv_ax.Box = 'on';
			hold(CLS_T_hom_inv_ax,'on');
		fit_T_hom_inv_ax = nexttile(params_layout,6);
			axes(fit_T_hom_inv_ax)
			fit_T_hom_inv_ax.Box = 'on';
			hold(fit_T_hom_inv_ax,'on');
%% plot parameters from fits
	%% kubo correlation time
		ax = fit_kubo1_t_ax;
		ax.XTick = 1:(numel(US_fctr)+1);
		%% 2021 data
			for k=1:size(mask,1)
				CI_intvl = p_best_fit(k).kubo1_t.CI;
				if k == 1
					l = errorbar(ax,k,p_best_fit(k).kubo1_t.val,CI_intvl,CI_intvl,'r.');
					ax.XTickLabel(k) = {num2str(sum(mask(k,:)))};
				else
					l = errorbar(ax,k+1,p_best_fit(k).kubo1_t.val,CI_intvl,CI_intvl,'r.');
					ax.XTickLabel(k+1) = {num2str(sum(mask(k,:)))};
				end
				l.MarkerSize = 12;
			end
		%% 2020 data
			ax.XTickLabel(2) = {'32'};
			CI_intvl_2020 = p_best_fit_2020.kubo1_t.CI;
			l = errorbar(ax,2,p_best_fit_2020.kubo1_t.val,CI_intvl_2020,CI_intvl_2020,'s');
			l.MarkerSize = 4;
			l.Color = [0.72,0.27,1.00];
			l.MarkerFaceColor = [0.72,0.27,1.00];
		%% final touches
			xlim(ax,[0.5,size(mask,1)+1.5])
			xlabel(ax,'Num. of T_w Points')
			ylabel(ax,p_best_fit(1).kubo1_t.units);
			title(ax,{'Kubo \tau'});
	%% kubo frequency amplitude squared
		ax = fit_kubo1_D2_ax;
		ax.XTick = 1:(numel(US_fctr)+1);
		%% 2021 data
			for k=1:size(mask,1)
				CI_intvl = p_best_fit(k).kubo1_D2.CI;
				if k == 1
					l = errorbar(ax,k,p_best_fit(k).kubo1_D2.val,CI_intvl,CI_intvl,'r.');
					ax.XTickLabel(k) = {num2str(sum(mask(k,:)))};
				else
					l = errorbar(ax,k+1,p_best_fit(k).kubo1_D2.val,CI_intvl,CI_intvl,'r.');
					ax.XTickLabel(k+1) = {num2str(sum(mask(k,:)))};
				end
				l.MarkerSize = 12;
			end
		%% 2020 data
			ax.XTickLabel(2) = {'32'};
			CI_intvl_2020 = p_best_fit_2020.kubo1_D2.CI;
			l = errorbar(ax,2,p_best_fit_2020.kubo1_D2.val,CI_intvl_2020,CI_intvl_2020,'s');
			l.MarkerSize = 4;
			l.Color = [0.72,0.27,1.00];
			l.MarkerFaceColor = [0.72,0.27,1.00];
		%% final touches
			xlim(ax,[0.5,size(mask,1)+1.5])
			xlabel(ax,'Num. of T_w Points')
			ylabel(ax,p_best_fit(1).kubo1_D2.units);
			title(ax,{'Kubo \Delta^2'});
	%% inverse homogeneous lifetime
		ax = fit_T_hom_inv_ax;
		ax.XTick = 1:(numel(US_fctr)+1);
		%% 2021 data
			for k=1:size(mask,1)
				CI_intvl = p_best_fit(k).T_hom_inv.CI;
				if k == 1
					l = errorbar(ax,k,p_best_fit(k).T_hom_inv.val,CI_intvl,CI_intvl,'r.');
					ax.XTickLabel(k) = {num2str(sum(mask(k,:)))};
				else
					l = errorbar(ax,k+1,p_best_fit(k).T_hom_inv.val,CI_intvl,CI_intvl,'r.');
					ax.XTickLabel(k+1) = {num2str(sum(mask(k,:)))};
				end
				l.MarkerSize = 12;
			end
		%% 2020 data
			ax.XTickLabel(2) = {'32'};
			CI_intvl_2020 = p_best_fit_2020.T_hom_inv.CI;
			l = errorbar(ax,2,p_best_fit_2020.T_hom_inv.val,CI_intvl_2020,CI_intvl_2020,'s');
			l.MarkerSize = 4;
			l.Color = [0.72,0.27,1.00];
			l.MarkerFaceColor = [0.72,0.27,1.00];
		%% final touches
			xlim(ax,[0.5,size(mask,1)+1.5])
			xlabel(ax,'Num. of T_w Points')
			ylabel(ax,p_best_fit(1).T_hom_inv.units);
			title(ax,{'T_{hom}^{-1}'});
%% reset p_fit to results from 45 points mask
	p_fit = p_best_fit(1);
	p_fit.w_01.val = p_fit.w_01.val-0.6;
%% compar CLS between model and experimental data
	%% measure CLS of experimental data
		[D_spec_apo,x_apo] = FID_to_2Dspec(D_FID,x,4);
		for i=1:x.N2
			[CL_w3, w1_axis, CLS] = trace_CL(x_apo.w1,[2153.7-2.5,2153.7+2.5],x_apo.w3,[2153.5-6,2153.5+6],D_spec_apo(:,:,i),'Asymmetric Lorentzian');
			CLS_arr_01(i) = CLS;
			CL_w3_arr_01(i,:) = CL_w3;
			[CL_w3, w1_axis, CLS] = trace_CL(x_apo.w1,[2153.7-2.5,2153.7+2.5],x_apo.w3,[2128-6,2128+6],-D_spec_apo(:,:,i),'Asymmetric Lorentzian');
			CLS_arr_12(i) = CLS;
			CL_w3_arr_12(i,:) = CL_w3;
		end
	%% fit experimental CLS decay to one-component exponential decay
		CLS_fit_01 = fit_exp_decay(x.Tw(3:36),CLS_arr_01(3:36),[0.4,0.3]);
		CLS_fit_12 = fit_exp_decay(x.Tw(3:36),CLS_arr_12(3:36),[0.4,0.3]);
		save('Output Data\CLS of exp data.mat','w1_axis','CLS_arr_01','CLS_arr_12','CL_w3_arr_01','CL_w3_arr_12','CLS_fit_01','CLS_fit_12');
	%% measure CLS of model fitted data
		M_FID = ILS_M(x,p_fit);
		[M_spec_apo,x_apo] = FID_to_2Dspec(M_FID,x,4);
		clear w1_axis CL_w3
		for i=1:x.N2
				[CL_w3, w1_axis, CLS] = trace_CL(x_apo.w1,[2153.7-2.5,2153.7+2.5],x_apo.w3,[2154.5-6,2154.5+6],M_spec_apo(:,:,i),'Asymmetric Lorentzian');
				M_CLS_arr_01(i) = CLS;
				M_CL_w3_arr_01(i,:) = CL_w3;
				[CL_w3, w1_axis, CLS] = trace_CL(x_apo.w1,[2153.7-2.5,2153.7+2.5],x_apo.w3,[2129-6,2129+6],-M_spec_apo(:,:,i),'Asymmetric Lorentzian');
				M_CLS_arr_12(i) = CLS;
				M_CL_w3_arr_12(i,:) = CL_w3;
		end
		M_CLS_fit_01 = fit_exp_decay(x.Tw,M_CLS_arr_01,[0.4,0.3]);
		M_CLS_fit_12 = fit_exp_decay(x.Tw,M_CLS_arr_12,[0.4,0.3]);
		save('Output Data\CLS of model fit.mat','w1_axis','M_CLS_arr_01','M_CLS_arr_12','M_CL_w3_arr_01','M_CL_w3_arr_12','M_CLS_fit_01','M_CLS_fit_12');
	%% compare CLS on plots
		l = semilogy(CLS_2020vs2021_ax,Tw_arr_2020,CLS_arr_01_2020,'ms',Tw_arr_2020,feval(CLS_fit_01_2020,Tw_arr_2020),'m-',x_apo.Tw,CLS_arr_01,'ko',x_apo.Tw,feval(CLS_fit_01,x_apo.Tw),'k-');
		xlim(CLS_2020vs2021_ax,[0,10]);ylim(CLS_2020vs2021_ax,[0.02,0.5]);
		l(1).MarkerFaceColor = 'm';l(1).MarkerSize = 4;
		l(3).MarkerFaceColor = 'k';l(3).MarkerSize = 4;
		CLS_2020vs2021_ax.YLim(2) = 0.6;
		ylabel(CLS_2020vs2021_ax,'CLS');xlabel(CLS_2020vs2021_ax,'T_{w} (ps)')
		set(CLS_2020vs2021_ax,'YMinorTick','on','YScale','log','YTick',[0.05 0.1 0.2 0.3 0.4 0.5]);
		legend(CLS_2020vs2021_ax,'2020 Data (0-1)','Fit','2021 Data (0-1)','Fit');
		
		l = semilogy(CLS_2021_ax,x_apo.Tw,CLS_arr_01,'ko',x_apo.Tw,feval(CLS_fit_01,x_apo.Tw),'k-',x_apo.Tw,CLS_arr_12,'b^',x_apo.Tw,feval(CLS_fit_12,x_apo.Tw),'b-');
		xlim(CLS_2021_ax,[0,10]);ylim(CLS_2021_ax,[0.02,0.5]);
		l(1).MarkerFaceColor = 'k';l(1).MarkerSize = 4;
		l(3).MarkerFaceColor = 'b';l(3).MarkerSize = 4;
		CLS_2021_ax.YLim(2) = 0.6;
		ylabel(CLS_2021_ax,'CLS');xlabel(CLS_2021_ax,'T_{w} (ps)')
		set(CLS_2021_ax,'YMinorTick','on','YScale','log','YTick',[0.05 0.1 0.2 0.3 0.4 0.5]);
		legend(CLS_2021_ax,'2021 Data (0-1)','Fit','2021 Data (1-2)','Fit');
		
		annotation(CLS_fig,'textbox',[0.01 0.953 0.1 0.04],'String','(A)','LineStyle','none','FitBoxToText','off');
		annotation(CLS_fig,'textbox',[0.01 0.473 0.1 0.04],'String','(B)','LineStyle','none','FitBoxToText','off');

		savefig(CLS_fig,'Output Data\CLS Log Axis.fig')
		
%% compare first order response between model and experimental data
	load('Input Data\Probe Abs.mat');
	load('Input Data\Bruker Abs.mat');
	bruker_w3 = bruker_w3+0.3; % shift by 0.3 cm-1 to match probe
	probe_abs = probe_abs/max(probe_abs);
	model_abs = match_abs(probe_w3,probe_abs,x.w3,M_1st_order_kubo(x,p_fit)); %normalize
	bruker_abs = match_abs(probe_w3,probe_abs,bruker_w3,bruker_abs); %normalize and offset to match model
	h = plot(fit_LA_ax,probe_w3,probe_abs,'k-',probe_w3,bruker_abs,'b-.',x.w3,model_abs,'r--');
	set(h,'LineWidth',2);
	legend(fit_LA_ax,'Probe','FTIR',['Model Fitting',newline,' 2D IR']);
	set(fit_LA_ax,'YTick',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',{'0','0.2','0.4','0.6','0.8','1'})
	xlim(fit_LA_ax,[2130,2180]);ylim(fit_LA_ax,[0,1.1])
	xlabel(fit_LA_ax,'Frequency (cm^{-1})');ylabel(fit_LA_ax,'Absorbance (norm.)');
%% compare first order response between model and experimental data (scaled for comparing FWHM)
	bruker_abs = bruker_abs - ones(size(bruker_abs))*bruker_abs(nearest_index(probe_w3,2130));
	bruker_abs = bruker_abs/max(bruker_abs); %normalize and offset to match model
	h = plot(fit_LA_ax2,probe_w3,probe_abs,'k-',probe_w3,bruker_abs,'b-.',x.w3,model_abs,'r--');
	set(h,'LineWidth',2);
	legend(fit_LA_ax2,'Probe','FTIR',['Model Fitting',newline,' 2D IR']);
	set(fit_LA_ax2,'YTick',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',{'0','0.2','0.4','0.6','0.8','1'})
	xlim(fit_LA_ax2,[2130,2180]);ylim(fit_LA_ax2,[0,1.1])
	xlabel(fit_LA_ax2,'Frequency (cm^{-1})');ylabel(fit_LA_ax2,'Absorbance (norm.)');
%% fit frequency components from experimental CLS decay to upper 90% of linear absorption spectrum
	n3_w_min = nearest_index(x.w3,2141.6);% 2146.1, 2144.4, 2141.6
	n3_w_max = nearest_index(x.w3,2165.2); % 2161.0, 2162.5, 2165.2
	fit_type = fittype(@(A,c,kubo_D2,T_hom_inv,w3) Lin_Abs(x,p_fit,A,c,[CLS_fit_01.tau1],[kubo_D2],T_hom_inv,[n3_w_min,n3_w_max],w3),'independent','w3');
	fit_options = fitoptions(fit_type);
	fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt');
	fit_options = fitoptions(fit_options,'TolX',1e-20);
	fit_options = fitoptions(fit_options,'TolFun',1e-20);
	fit_options = fitoptions(fit_options,'StartPoint',[2.8e3,-0.005,15,0.3]);
	[f_90,gof,output] = fit(probe_w3(n3_w_min:n3_w_max)',probe_abs(n3_w_min:n3_w_max)',fit_type,fit_options);
	f_90_abs = Lin_Abs(x,p_fit,f_90.A,f_90.c,[CLS_fit_01.tau1],[f_90.kubo_D2],f_90.T_hom_inv,[1,x.N3],x.w3)';
	f_90_w3 = x.w3(1:x.N3);
%% fit frequency components from experimental CLS decay to upper 80% of linear absorption spectrum
	n3_w_min = nearest_index(x.w3,2144.4);
	n3_w_max = nearest_index(x.w3,2162.5);
	fit_type = fittype(@(A,c,kubo_D2,T_hom_inv,w3) Lin_Abs(x,p_fit,A,c,[CLS_fit_01.tau1],[kubo_D2],T_hom_inv,[n3_w_min,n3_w_max],w3),'independent','w3');
	fit_options = fitoptions(fit_type);
	fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt');
	fit_options = fitoptions(fit_options,'TolX',1e-20);
	fit_options = fitoptions(fit_options,'TolFun',1e-20);
	fit_options = fitoptions(fit_options,'StartPoint',[2.8e3,-0.005,10,0.4]);
	[f_80,gof,output] = fit(probe_w3(n3_w_min:n3_w_max)',probe_abs(n3_w_min:n3_w_max)',fit_type,fit_options);
	f_80_abs = Lin_Abs(x,p_fit,f_80.A,f_80.c,[CLS_fit_01.tau1],[f_80.kubo_D2],f_80.T_hom_inv,[1,x.N3],x.w3)';
	f_80_w3 = x.w3(1:x.N3);
%% fit frequency components from experimental CLS decay to upper 70% of linear absorption spectrum
	n3_w_min = nearest_index(x.w3,2146.1);
	n3_w_max = nearest_index(x.w3,2161.0);
	fit_type = fittype(@(A,c,kubo_D2,T_hom_inv,w3) Lin_Abs(x,p_fit,A,c,[CLS_fit_01.tau1],[kubo_D2],T_hom_inv,[n3_w_min,n3_w_max],w3),'independent','w3');
	fit_options = fitoptions(fit_type);
	fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt');
	fit_options = fitoptions(fit_options,'TolX',1e-20);
	fit_options = fitoptions(fit_options,'TolFun',1e-20);
	fit_options = fitoptions(fit_options,'StartPoint',[2.8e3,-0.005,5,0.5]);
	[f_70,gof,output] = fit(probe_w3(n3_w_min:n3_w_max)',probe_abs(n3_w_min:n3_w_max)',fit_type,fit_options);
	f_70_abs = Lin_Abs(x,p_fit,f_70.A,f_70.c,[CLS_fit_01.tau1],[f_70.kubo_D2],f_70.T_hom_inv,[1,x.N3],x.w3)';
	f_70_w3 = x.w3(1:x.N3);
%% plot linear absorption fits
	h = plot(CLS_LA_ax,probe_w3,probe_abs,'k-',f_90_w3,f_90_abs,'--',f_80_w3,f_80_abs,'--',f_70_w3,f_70_abs,'--');
	h(1).Color = [0,0,0];h(2).Color = [0,0,1];h(3).Color = [0.3922,0.8314,0.0745];h(4).Color = [1.00,0.41,0.16];
	set(h,'LineWidth',2);
	legend(CLS_LA_ax,'Probe','CLS (90%)','CLS (80%)','CLS (70%)');
	set(CLS_LA_ax,'YTick',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',{'0','0.2','0.4','0.6','0.8','1'})
	xlim(CLS_LA_ax,[2130,2180]);ylim(CLS_LA_ax,[-0.05,1.02]);
	xlabel(CLS_LA_ax,'Frequency (cm^{-1})');ylabel(CLS_LA_ax,'Absorbance (norm.)');
	annotation(LA_fig,'textbox',[0.0115 0.94 0.079 0.0467],'String',{'(A)'},'LineStyle','none','FontSize',12,'FitBoxToText','off');
	annotation(LA_fig,'textbox',[0.0115 0.47 0.079 0.0467],'String',{'(B)'},'LineStyle','none','FontSize',12,'FitBoxToText','off');
	savefig(LA_fig,'Output Data\Linear Absorbance.fig')
	save('Output Data\Linear Absorbance Comparisons.mat','f_90','f_80','f_70');
%% plot linear absorption fits (scaled for comparing FWHM)
	f_90_abs = Lin_Abs(x,p_fit,f_90.A,0,[CLS_fit_01.tau1],[f_90.kubo_D2],f_90.T_hom_inv,[1,x.N3],x.w3)';
	f_90_abs = f_90_abs/max(f_90_abs);
	f_80_abs = Lin_Abs(x,p_fit,f_80.A,0,[CLS_fit_01.tau1],[f_80.kubo_D2],f_80.T_hom_inv,[1,x.N3],x.w3)';
	f_80_abs = f_80_abs/max(f_80_abs);
	f_70_abs = Lin_Abs(x,p_fit,f_70.A,0,[CLS_fit_01.tau1],[f_70.kubo_D2],f_70.T_hom_inv,[1,x.N3],x.w3)';
	f_70_abs = f_70_abs/max(f_70_abs);
	
	h = plot(CLS_LA_ax2,probe_w3,probe_abs,'k-',f_90_w3,f_90_abs,'--',f_80_w3,f_80_abs,'--',f_70_w3,f_70_abs,'--');
	h(1).Color = [0,0,0];h(2).Color = [0,0,1];h(3).Color = [0.3922,0.8314,0.0745];h(4).Color = [1.00,0.41,0.16];
	set(h,'LineWidth',2);
	legend(CLS_LA_ax2,'Probe','CLS (90%)','CLS (80%)','CLS (70%)');
	set(CLS_LA_ax2,'YTick',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',{'0','0.2','0.4','0.6','0.8','1'})
	xlim(CLS_LA_ax2,[2130,2180]);ylim(CLS_LA_ax2,[-0.05,1.02]);
	xlabel(CLS_LA_ax2,'Frequency (cm^{-1})');ylabel(CLS_LA_ax2,'Absorbance (norm.)');
	annotation(LA_fig2,'textbox',[0.0115 0.94 0.079 0.0467],'String',{'(A)'},'LineStyle','none','FontSize',12,'FitBoxToText','off');
	annotation(LA_fig2,'textbox',[0.0115 0.47 0.079 0.0467],'String',{'(B)'},'LineStyle','none','FontSize',12,'FitBoxToText','off');
	savefig(LA_fig2,'Output Data\Linear Absorbance (scaled for FWHM).fig')
	save('Output Data\Linear Absorbance Comparisons (FWHM).mat','f_90','f_80','f_70');
%% add kubo time constant for 2021 data
	CLS_01_fit_CI = confint(CLS_fit_01);
	CI_intvl = ( CLS_01_fit_CI(2,2) - CLS_01_fit_CI(1,2) );
	l = errorbar(CLS_kubo1_t_ax,1,CLS_fit_01.tau1,CI_intvl/2,CI_intvl/2,'bo');
	l.MarkerFaceColor = 'b';
	l.MarkerSize = 3;
%% add kubo time constant for 2020 data
	load('Output Data\CLS Analysis (2020 Data).mat');
	CLS_01_fit_CI_2020 = confint(CLS_fit_01_2020);
	CI_intvl_2020 = ( CLS_01_fit_CI_2020(2,2) - CLS_01_fit_CI_2020(1,2) );
	l = errorbar(CLS_kubo1_t_ax,2,CLS_fit_01_2020.tau1,CI_intvl_2020/2,CI_intvl_2020/2,'ms');
	l.MarkerSize = 4;
	l.MarkerFaceColor = [1.00,0.07,0.65];
	legend(CLS_kubo1_t_ax,'2021 Data','2020 Data');
%% add kubo D^2 and inv_T_hom for f1
	%% Append upper 70% data
		f_70_CI = confint(f_70);
		f_70_D2_CI = ( f_70_CI(2,3) - f_70_CI(1,3) );
		l = errorbar(CLS_kubo1_D2_ax,1,f_70.kubo_D2,f_70_D2_CI/2,f_70_D2_CI/2,'bo');
		l.MarkerFaceColor = 'b';
		l.MarkerSize = 3;
		f_70_inv_T_hom_CI = ( f_70_CI(2,4) - f_70_CI(1,4) );
		l = errorbar(CLS_T_hom_inv_ax,1,f_70.T_hom_inv,f_70_inv_T_hom_CI/2,f_70_inv_T_hom_CI/2,'bo');
		l.MarkerFaceColor = 'b';
		l.MarkerSize = 3;
	%% Append upper 80% data
		f_80_CI = confint(f_80);
		f_80_D2_CI = ( f_80_CI(2,3) - f_80_CI(1,3) );
		l = errorbar(CLS_kubo1_D2_ax,2,f_80.kubo_D2,f_80_D2_CI/2,f_80_D2_CI/2,'bo');
		l.MarkerFaceColor = 'b';
		l.MarkerSize = 3;
		f_80_inv_T_hom_CI = ( f_80_CI(2,4) - f_80_CI(1,4) );
		l = errorbar(CLS_T_hom_inv_ax,2,f_80.T_hom_inv,f_80_inv_T_hom_CI/2,f_80_inv_T_hom_CI/2,'bo');
		l.MarkerFaceColor = 'b';
		l.MarkerSize = 3;
	%% Append upper 90% data
		f_90_CI = confint(f_90);
		f_90_D2_CI = ( f_90_CI(2,3) - f_90_CI(1,3) );
		l = errorbar(CLS_kubo1_D2_ax,3,f_90.kubo_D2,f_90_D2_CI/2,f_90_D2_CI/2,'bo');
		l.MarkerFaceColor = 'b';
		l.MarkerSize = 3;
		f_90_inv_T_hom_CI = ( f_90_CI(2,4) - f_90_CI(1,4) );
		l = errorbar(CLS_T_hom_inv_ax,3,f_90.T_hom_inv,f_90_inv_T_hom_CI/2,f_90_inv_T_hom_CI/2,'bo');
		l.MarkerFaceColor = 'b';
		l.MarkerSize = 3;
	%% place model fitting results and CLS results on same axes scale
		%% kubo time constant graphs
			CLS_kubo1_t_ax.YLim(2) = 6.1;
			CLS_kubo1_t_ax.YLim(1) = min(CLS_kubo1_t_ax.YLim(1),fit_kubo1_t_ax.YLim(1));
			fit_kubo1_t_ax.YLim(1) = min(CLS_kubo1_t_ax.YLim(1),fit_kubo1_t_ax.YLim(1));
			CLS_kubo1_t_ax.YLim(2) = max(CLS_kubo1_t_ax.YLim(2),fit_kubo1_t_ax.YLim(2));
			fit_kubo1_t_ax.YLim(2) = max(CLS_kubo1_t_ax.YLim(2),fit_kubo1_t_ax.YLim(2));
		%% kubo amplitude graphs
			CLS_kubo1_D2_ax.YLim(2) = 45;
			CLS_kubo1_D2_ax.YLim(1) = min(CLS_kubo1_D2_ax.YLim(1),fit_kubo1_D2_ax.YLim(1));
			fit_kubo1_D2_ax.YLim(1) = min(CLS_kubo1_D2_ax.YLim(1),fit_kubo1_D2_ax.YLim(1));
			CLS_kubo1_D2_ax.YLim(2) = max(CLS_kubo1_D2_ax.YLim(2),fit_kubo1_D2_ax.YLim(2));
			fit_kubo1_D2_ax.YLim(2) = max(CLS_kubo1_D2_ax.YLim(2),fit_kubo1_D2_ax.YLim(2));
		%% homogeneous dephasing graphs
			CLS_T_hom_inv_ax.YLim(2) = 2.2;
			CLS_T_hom_inv_ax.YLim(1) = min(CLS_T_hom_inv_ax.YLim(1),fit_T_hom_inv_ax.YLim(1));
			fit_T_hom_inv_ax.YLim(1) = min(CLS_T_hom_inv_ax.YLim(1),fit_T_hom_inv_ax.YLim(1));
			CLS_T_hom_inv_ax.YLim(2) = max(CLS_T_hom_inv_ax.YLim(2),fit_T_hom_inv_ax.YLim(2));
			fit_T_hom_inv_ax.YLim(2) = max(CLS_T_hom_inv_ax.YLim(2),fit_T_hom_inv_ax.YLim(2));
	%% adjust x-axis limits
		xlim(CLS_kubo1_t_ax,[0,3]);
		xlim(CLS_kubo1_D2_ax,[0.5,3.5]);
		xlim(CLS_T_hom_inv_ax,[0.5,3.5]);
	%% adjust x-axis tick marks and tick labels
		set(CLS_kubo1_t_ax,'XTick',[1,2],'XTickLabel',{'45','32'})
		set(CLS_kubo1_D2_ax,'XTick',[1 2 3],'XTickLabel',{'70%','80%','90%'})
		set(CLS_T_hom_inv_ax,'XTick',[1 2 3],'XTickLabel',{'70%','80%','90%'})
	%% add titles, x-label and y-label for CLS data plots
		xlabel(CLS_kubo1_t_ax,'Num. T_w Points')
		xlabel(CLS_kubo1_D2_ax,'Fitting Range')
		xlabel(CLS_T_hom_inv_ax,'Fitting Range')
		ylabel(CLS_kubo1_t_ax,p_best_fit(1).kubo1_t.units);
		ylabel(CLS_kubo1_D2_ax,p_best_fit(1).kubo1_D2.units);
		ylabel(CLS_T_hom_inv_ax,p_best_fit(1).T_hom_inv.units);
		title(CLS_kubo1_t_ax,{'Kubo \tau'});
		title(CLS_kubo1_D2_ax,{'Kubo \Delta^2'});
		title(CLS_T_hom_inv_ax,{'T_{hom}^{-1}'});
	%% add annotation
		annotation(params_fig,'textbox',[0.01 0.95 0.10 0.045],'String',{'(A)'},'LineStyle','none');
		annotation(params_fig,'textbox',[0.01 0.61 0.10 0.045],'String',{'(B)'},'LineStyle','none');
		annotation(params_fig,'textbox',[0.01 0.29 0.10 0.045],'String',{'(C)'},'LineStyle','none');
		annotation(params_fig,'textbox',[0.49 0.95 0.10 0.045],'String',{'(D)'},'LineStyle','none');
		annotation(params_fig,'textbox',[0.49 0.61 0.10 0.045],'String',{'(E)'},'LineStyle','none');
		annotation(params_fig,'textbox',[0.49 0.29 0.10 0.045],'String',{'(F)'},'LineStyle','none');
	%% save figure
		savefig(params_fig,'Output Data\Params.fig');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');		
