clear all;
close all;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define bandwidth range for fitting to linear absorption
	fit_bw_CLS = 19;
%% initialize figure
	CLS_fig = figure;set(CLS_fig,'Position',[100,100,600,350],'Color',[1,1,1]);
		CLS_t = tiledlayout(CLS_fig,4,2,'TileSpacing','compact','Padding','compact');
	CLS_fig2 = figure;set(CLS_fig2,'Position',[100,450,600,350],'Color',[1,1,1]);
		CLS_t2 = tiledlayout(CLS_fig2,4,2,'TileSpacing','compact','Padding','compact');
	LA_fig = figure;set(LA_fig,'Position',[700,100,600,350],'Color',[1,1,1]);
		LA_t = tiledlayout(LA_fig,4,2,'TileSpacing','compact','Padding','compact');
	std_ratio_fig = figure;set(std_ratio_fig,'Position',[700,450,300,200],'Color',[1,1,1]);
	comp_fig = openfig('composite figure.fig');
%% load p
	p = load_params('Input Data\p.csv');
%% make axes
	Tw = [ 0:0.1:1 , 1.2:0.2:2 , 2.5:0.5:5, 6:1:10, 15:5:30, 40:20:100];
    x = gen_x([0 4],16,2130,[2110 2190],128,Tw,'real');
%% prepare param struct for linear absorption fitting
	p.A01.val = p.A01.val*(1.6866e-4);
	p.('c') = p.A01;
	p.c.val = 0;
	p.c.label = 'c';
%% initialize axes and true values
	true_vals = [p.A01.val,0.02,p.kubo1_D2.val,p.kubo2_D2.val,p.T_hom_inv.val,p.kubo1_t.val,p.kubo2_t.val];
	x_ticks = 1:7;
	x_tick_labels = {'A_{01}','c','\Delta^2_1','\Delta^2_2','T_{hom}^{-1}','\tau_1','\tau_2'};
	w3_fit_range = [p.w_01.val-fit_bw_CLS/2,p.w_01.val+fit_bw_CLS/2]; % upper 80% of linear absorption
	[n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
	fxn = @(x,p) Lin_Abs(x,p,p.A01.val,p.c.val,[p.kubo1_t.val,p.kubo2_t.val],[p.kubo1_D2.val,p.kubo2_D2.val],p.T_hom_inv.val,[n3_min,n3_max],x.w3);
	true_lin_abs = fxn(x,p)+0.02;
	noise = (1e-2)*randn(numel(true_lin_abs),100);
	y_lim = [-2e-2,2e-2];
	init_val = true_vals.*( ones([100,7])+0.1*randn([100,7]) );
	tau_rand = [p.kubo1_t.val,p.kubo2_t.val].*(1+(1e-1)*randn(100,2));
	
%% run empirical variance trial set for CLS method with fixed tau
	ax1 = nexttile(CLS_t2,1,[3,1]);
	ax2 = nexttile(CLS_t2,2,[4,1]);
	ax3 = nexttile(CLS_t2,7,[1,1]);
	check = zeros(100,5);
	plot(ax2,[0,8],[1,1],'k--');
	LA_fit_val = zeros(100,7);
	for i=1:100
	%% 
		noisy_LA = true_lin_abs + noise(:,i);
		tau1 = p.kubo1_t.val;
		tau2 = p.kubo2_t.val;
		LA_fit_val(i,6) = tau1;
		LA_fit_val(i,7) = tau2;
	%% define a different fit type for each fitting parameter
		fit_type = fittype(@(A01,c,D2_1,D2_2,T_hom_inv,w3) Lin_Abs(x,p,A01,c,[tau1,tau2],[D2_1,D2_2],T_hom_inv,[n3_min,n3_max],w3),'independent','w3');
		fit_options = fitoptions(fit_type);
		fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-20,'TolFun',1e-20,'StartPoint',init_val(i,1:5));
		[LA_fit,gof,output] = fit(x.w3(n3_min:n3_max)',noisy_LA,fit_type,fit_options);
		plot(ax1,x.w3(n3_min:n3_max),noisy_LA,'k-',x.w3(n3_min:n3_max),feval(LA_fit,x.w3(n3_min:n3_max)),'b-');
		xlabel(ax1,'\omega (cm^{-1})');ylabel(ax1,'OD');xlim(ax1,[x.w3(n3_min),x.w3(n3_max)]);ylim(ax1,[0,1.05]);
		ci = confint(LA_fit,0.5);
		check(i,1:5) = true_vals(1:5) > ci(1,:) & true_vals(1:5) < ci(2,:);
		title(ax1,'Fit to 100 Trial');
		ax1.Box = 'on';
		legend(ax1,'Data','Fit')
		LA_fit_val(i,1:5) = coeffvalues(LA_fit);
		hold(ax2,'on')
		plot(ax2,x_ticks,LA_fit_val(i,:)./true_vals(:)','b.','MarkerSize',12);
		xlim(ax2,[x_ticks(1)-0.5,x_ticks(numel(x_ticks))+0.5]); xticks(ax2,x_ticks); xticklabels(ax2,x_tick_labels);
		title(ax2,sprintf('Parameters From %i Trials',i))
		ylabel(ax2,'Fit / True');
		plot(ax3,x.w3(n3_min:n3_max),noisy_LA-feval(LA_fit,x.w3(n3_min:n3_max)),'k-',x.w3(n3_min:n3_max),zeros(size(x.w3(n3_min:n3_max))),'b-')
		ax3.Box = 'on';
		ylabel(ax3,'\DeltaOD');title(ax3,'Residual');
		xlim(ax3,[x.w3(n3_min),x.w3(n3_max)]);ylim(ax3,y_lim);
	end
	CLS_const_tau_std = std(LA_fit_val,0,1)./true_vals;
	ax = findobj('Tag','C');
	copyobj(CLS_t2.Children(3).Children,ax)
	str = sprintf('%i%% %i%% %i%% %i%% %i%%   -   -',(sum(check,1)));
	annotation(comp_fig,'textbox',[0.7,0.73,0.3,0.0348],'String',str,'linestyle','none','FontSize',9)

%% run empirical variance trial set for CLS method with uncertain tau
	ax1 = nexttile(CLS_t,1,[3,1]);
	ax2 = nexttile(CLS_t,2,[4,1]);
	ax3 = nexttile(CLS_t,7,[1,1]);
	plot(ax2,[0,8],[1,1],'k--');
	LA_fit_val = zeros(100,7);
	check = zeros(100,5);
	for i=1:100
	%% 
		noisy_LA = true_lin_abs + noise(:,i);
		tau1 = tau_rand(i,1);
		tau2 = tau_rand(i,2);
		LA_fit_val(i,6) = tau1;
		LA_fit_val(i,7) = tau2;
	%% define a different fit type for each fitting parameter
		fit_type = fittype(@(A01,c,D2_1,D2_2,T_hom_inv,w3) Lin_Abs(x,p,A01,c,[tau1,tau2],[D2_1,D2_2],T_hom_inv,[n3_min,n3_max],w3),'independent','w3');
		fit_options = fitoptions(fit_type);
		fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-20,'TolFun',1e-20,'StartPoint',init_val(i,1:5));
		[LA_fit,gof,output] = fit(x.w3(n3_min:n3_max)',noisy_LA,fit_type,fit_options);
		plot(ax1,x.w3(n3_min:n3_max),noisy_LA,'k-',x.w3(n3_min:n3_max),feval(LA_fit,x.w3(n3_min:n3_max)),'b-');
		xlabel(ax1,'\omega (cm^{-1})');ylabel(ax1,'OD');xlim(ax1,[x.w3(n3_min),x.w3(n3_max)]);ylim(ax1,[0,1.05]);
		ci = confint(LA_fit,0.5);
		check(i,:) = true_vals(1:5) > ci(1,:) & true_vals(1:5) < ci(2,:);
		title(ax1,'Fit to 100 Trial');
		ax1.Box = 'on';
		legend(ax1,'Data','Fit')
		LA_fit_val(i,1:5) = coeffvalues(LA_fit);
		hold(ax2,'on')
		plot(ax2,x_ticks,LA_fit_val(i,:)./true_vals(:)','b.','MarkerSize',12);
		xlim(ax2,[x_ticks(1)-0.5,x_ticks(numel(x_ticks))+0.5]); xticks(ax2,x_ticks); xticklabels(ax2,x_tick_labels);
		title(ax2,sprintf('Parameters From %i Trials',i))
		ylabel(ax2,'Fit / True');
		plot(ax3,x.w3(n3_min:n3_max),noisy_LA-feval(LA_fit,x.w3(n3_min:n3_max)),'k-',x.w3(n3_min:n3_max),zeros(size(x.w3(n3_min:n3_max))),'b-')
		ax3.Box = 'on';
		ylabel(ax3,'\DeltaOD');title(ax3,'Residual');
		xlim(ax3,[x.w3(n3_min),x.w3(n3_max)]);ylim(ax3,y_lim);
	end
	CLS_var_tau_std = std(LA_fit_val,0,1)./true_vals;
	ax = findobj('Tag','F');
	copyobj(CLS_t.Children(3).Children,ax)
	str = sprintf('%i%% %i%% %i%% %i%% %i%% - -',(sum(check,1)));
	annotation(comp_fig,'textbox',[0.7,0.51,0.3,0.0348],'String',str,'linestyle','none','FontSize',9)

%% run empirical variance trial set for linear absorption
	ax1 = nexttile(LA_t,1,[3,1]);
	ax2 = nexttile(LA_t,2,[4,1]);
	ax3 = nexttile(LA_t,7,[1,1]);
	check = zeros(100,7);
	plot(ax2,[0,8],[1,1],'k--');
	map = [1,2,3,4,5,6,7];
	LA_fit_val = zeros(100,7);
	for i=1:100
	%% 
		noisy_LA = true_lin_abs + noise(:,i);
	%% define a different fit type for each fitting parameter
		fit_type = fittype(@(A01,c,D2_1,D2_2,hom_inv_T,tau1,tau2,w3) Lin_Abs(x,p,A01,c,[tau1,tau2],[D2_1,D2_2],hom_inv_T,[n3_min,n3_max],w3),'independent','w3');
		fit_options = fitoptions(fit_type);
		fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-20,'TolFun',1e-20,'StartPoint',init_val(i,:));
		[LA_fit,gof,output] = fit(x.w3(n3_min:n3_max)',noisy_LA,fit_type,fit_options);
		plot(ax1,x.w3(n3_min:n3_max),noisy_LA,'k-',x.w3(n3_min:n3_max),feval(LA_fit,x.w3(n3_min:n3_max)),'b-');
		xlabel(ax1,'\omega (cm^{-1})');ylabel(ax1,'OD');xlim(ax1,[x.w3(n3_min),x.w3(n3_max)]);ylim(ax1,[0,1.05]);
		ci = confint(LA_fit,0.5);
		check(i,:) = true_vals > ci(1,:) & true_vals < ci(2,:);
		title(ax1,'Fit to 100 Trial');
		ax1.Box = 'on';
		legend(ax1,'Data','Fit')
		LA_fit_val(i,:) = coeffvalues(LA_fit);
		hold(ax2,'on')
		plot(ax2,x_ticks(:),LA_fit_val(i,:)./true_vals(:)','b.','MarkerSize',12);
		xlim(ax2,[x_ticks(1)-0.5,x_ticks(numel(x_ticks))+0.5]); xticks(ax2,x_ticks); xticklabels(ax2,x_tick_labels);
		title(ax2,sprintf('Parameters From %i Trials',i))
		ylabel(ax2,'Fit / True');
		plot(ax3,x.w3(n3_min:n3_max),noisy_LA-feval(LA_fit,x.w3(n3_min:n3_max)),'k-',x.w3(n3_min:n3_max),zeros(size(x.w3(n3_min:n3_max))),'b-')
		ax3.Box = 'on';
		ylabel(ax3,'\DeltaOD');title(ax3,'Residual');
		xlim(ax3,[x.w3(n3_min),x.w3(n3_max)]);ylim(ax3,y_lim);
	end
	LA_std = std(LA_fit_val,0,1)./true_vals;
	std_const_ratio = CLS_const_tau_std./LA_std;
	std_var_ratio = CLS_var_tau_std./LA_std;
	ax = findobj('Tag','I');
	copyobj(LA_t.Children(3).Children,ax)
	str = sprintf('%i%% %i%% %i%% %i%% %i%%',(sum(check,1)));
	annotation(comp_fig,'textbox',[0.685,0.29,0.32,0.0348],'String',str,'linestyle','none','FontSize',8)

%% plot CLS to LA std ratio
	ax = axes(std_ratio_fig);
	pnts = plot(ax,x_ticks,std_const_ratio,'ks',x_ticks,std_var_ratio,'ko',0:8,ones(1,9),'k--');
	set(pnts(2),'MarkerFaceColor','k');
	set(pnts(1),'MarkerSize',10);
	ax.YScale = 'log';
	ylim(ax,[1e-2,1e3])
	xlim(ax,[x_ticks(1)-0.5,x_ticks(numel(x_ticks))+0.5]); xticks(ax,x_ticks); xticklabels(ax,x_tick_labels);
	ylabel(ax,{'CLS Method / Naive Fit','Error Ratio'});
	legend(ax,'Abs. Certain CLS \tau','Uncertain CLS \tau')
	
	ax2 = findobj('Tag','L');
	copyobj(ax.Children,ax2)
	
	savefig(comp_fig,'composite figure.fig')
	