clear all
close all
%% set random number generator seed to 1
	rng('default');
	rng(1);
%% decide on recording videos
	record_fit_update_video = 1;
		fit_update_dir = 'Output Data\Fitting Update Figures';
	record_C_SIGN_video = 1;
		C_SIGN_dir = 'Output Data\C and SIGN Figures';
	record_CLS_video = 1;
		CLS_dir = 'Output Data\CLS Figures';
	record_params_video = 1;
		params_dir = 'Output Data\Params Figures';
%% add figure folders to Output Data path
	if ~exist(fit_update_dir,'dir') && record_C_SIGN_video
		mkdir(fit_update_dir);
	else
		delete([fit_update_dir,'\*.fig']);
	end
	if ~exist(C_SIGN_dir,'dir') && record_C_SIGN_video
		mkdir(C_SIGN_dir);
	else
		delete([C_SIGN_dir,'\*.fig']);
	end
	if ~exist(CLS_dir,'dir') && record_CLS_video
		mkdir(CLS_dir);
	else
		delete([CLS_dir,'\*.fig']);
	end
	if ~exist(CLS_dir,'dir') && record_CLS_video
		mkdir(CLS_dir);
	else
		delete([CLS_dir,'\*.fig']);
	end
	if ~exist(params_dir,'dir') && record_params_video
		mkdir(params_dir);
	else
		delete([params_dir,'\*.fig']);
	end
%% set plot limits
	w1_plot_lim = [2115,2185];
	w3_plot_lim = [2115,2185];
%% define bandwidth range for fitting to linear absorption
	fit_bw_CLS = 18;
%% load p
	load('Input Data\p.mat');
	p_true = p;
%% load data
    load('Input Data\FID.mat');
%% set SIGN limit
	SIGN_lim = 1e-9;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% initialize figures
	initial_fit_fig = openfig('Initial_fit_template.fig');
	C_SIGN_fig = openfig('C_and_SIGN_template.fig');
	update_fig = figure;set(update_fig,'Position',[20 50 1500 700]);
	CLS_fig = openfig('CLS_template.fig');
	trial_params_fig = openfig('Params_template.fig');
	pause_stop_fit_fig = uifigure('HandleVisibility','on');
		set(pause_stop_fit_fig,'Position',[500 300 250 50]);
		pause_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Pause Fitting','Value',0,'Position',[20,10, 100, 22]);
		stop_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Stop Fitting','Value',0,'Position',[130,10, 100, 22]);
%% for loop over different trials of noise and random starting points
for trial=1:100
	%% add noise
		noise = (2e-6)*randn(size(FID));
		D = FID + noise;
	%% generate weight mask
		% weight along pump time axis
			w_t1 = reshape(ones(size(x.t1)),[x.N1,1,1]);
		% weight along waiting time axis
			w_Tw = reshape(ones(size(x.Tw)),[1,1,x.N2]);
		% weight along probe frequency axis
			w_w3 = reshape(ones(size(x.w3)),[1,x.N3,1]);
		% composite weight
			w = w_t1.*w_Tw.*w_w3;
	%% gather structure of auxiliary fitting information required for algorithm
		aux = ILS_initialize_aux(p);
	%% define initial (guess) model parameters as a random vector in boundary space
		p = ILS_rand_params(p,aux);
	%% show comparison between initial guess and data for TA spectrum
		ax = findobj(initial_fit_fig,'Tag','TA');
			M_init = ILS_M(x,p);
			plot(ax,x.w3,w_w3.*real(D(1,:,1)),'k-',x.w3,w_w3.*real(M_init(1,:,1)),'r--');
			xlim(ax,w3_plot_lim);
			legend(ax,'TA from Data','TA from Initial Guess')
		ax = findobj(initial_fit_fig,'Tag','FID');
			plot(ax,x.t1,w_t1.*real(D(:,nearest_index(x.w3,p.w_01.val),1)),'k-',x.t1,w_t1.*real(M_init(:,nearest_index(x.w3,p.w_01.val),1)),'r--');
			legend(ax,'FID from Data','FID from Initial Guess')
	%% iterative fitting:
		timerval = tic;
		for iter=1:200
		%% find p_min for this iteration
			if iter == 1
				p_prev = p;
			else
				p_prev = p_arr(iter-1);
			end
			[p_arr(iter),cov,C_arr(iter),SIGN_arr(iter),aux] = ILS_p_min(x,p_prev,D,w,aux);
		%% check for stall or convergence
			[aux,break_flag] = ILS_check_stall_conv(aux,C_arr,SIGN_arr,SIGN_lim,iter);
		%% update fitting report
			plot_fit_update(update_fig,p,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,w,trial,aux,timerval,w3_plot_lim);
			%% add reticles to fitting report to symbolize true values
				%% frequency reticle
					ax = findobj(update_fig,'Tag','freq_ax');
					rx = p_true.w_01;
					ry = p_true.Anh;
					drx = (rx.bounds2-rx.bounds1)/8;
					dry = (ry.bounds2-ry.bounds1)/8;
					line(ax,[rx.val,rx.val],[ry.val-dry,ry.val+dry],'Color','k','LineStyle','--');
					line(ax,[rx.val-drx,rx.val+drx],[ry.val,ry.val],'Color','k','LineStyle','--');
				%% lifetime reticle
					ax = findobj(update_fig,'Tag','hom_ax');
					rx = p_true.T_hom_inv;
					ry = p_true.T_LT_inv;
					drx = (rx.bounds2-rx.bounds1)/8;
					dry = (ry.bounds2-ry.bounds1)/8;
					line(ax,[rx.val,rx.val],[ry.val-dry,ry.val+dry],'Color','k','LineStyle','--');
					line(ax,[rx.val-drx,rx.val+drx],[ry.val,ry.val],'Color','k','LineStyle','--');
				%% amplitude reticle
					ax = findobj(update_fig,'Tag','amp_ax');
					rx = p_true.A01;
					ry = p_true.A12;
					line(ax,[rx.val,rx.val],[0.8*ry.val,1.3*ry.val],'Color','k','LineStyle','--');
					line(ax,[0.8*rx.val,1.3*rx.val],[ry.val,ry.val],'Color','k','LineStyle','--');
				%% Kubo reticles
					ax = findobj(update_fig,'Tag','kubo_ax');
					rx = p_true.kubo1_t;
					ry = p_true.kubo1_D2;
					drx = (rx.bounds2-rx.bounds1)/8;
					dry = (ry.bounds2-ry.bounds1)/8;
					line(ax,[rx.val,rx.val],[ry.val-dry,ry.val+dry],'Color','k','LineStyle','--');
					line(ax,[0.5*rx.val,2*rx.val],[ry.val,ry.val],'Color','k','LineStyle','--');
					rx = p_true.kubo2_t;
					ry = p_true.kubo2_D2;
					drx = (rx.bounds2-rx.bounds1)/8;
					dry = (ry.bounds2-ry.bounds1)/8;
					line(ax,[rx.val,rx.val],[ry.val-dry,ry.val+dry],'Color','k','LineStyle','--');
					line(ax,[0.5*rx.val,2*rx.val],[ry.val,ry.val],'Color','k','LineStyle','--');
		%% update video frames from this iteration
			if record_fit_update_video
				savefig(update_fig,[fit_update_dir,sprintf('\\trial%i iter%i.fig',trial,iter)]);
			end
		%% check for pause fitting
			if pause_fit_btn.Value == 1
				while pause_fit_btn.Value == 1
					pause(1)
				end
			end
		%% check for stop fitting
			if stop_fit_btn.Value || break_flag
				break
			end
		end
	%% determine best fit
		[M,i] = min(SIGN_arr);
		p_best_fit = p_arr(i);
	%% organize parameters (and CIs) from model fitting such that smaller kubo time constant is always first
        model_fit_val = [ p_best_fit.kubo1_D2.val, p_best_fit.kubo2_D2.val, p_best_fit.kubo1_t.val, p_best_fit.kubo2_t.val, p_best_fit.T_hom_inv.val];
		model_fit_CI = [ p_best_fit.kubo1_D2.CI, p_best_fit.kubo2_D2.CI, p_best_fit.kubo1_t.CI, p_best_fit.kubo2_t.CI, p_best_fit.T_hom_inv.CI];
		if p_best_fit.kubo1_t.val > p_best_fit.kubo2_t.val % make sure first kubo time constant is smaller than second
            model_fit_val(1:4) = [model_fit_val(2),model_fit_val(1),model_fit_val(4),model_fit_val(3)];
            model_fit_CI(1:4) = [model_fit_CI(2),model_fit_CI(1),model_fit_CI(4),model_fit_CI(3)];
		end
	%% measure CLS of experimental data
        [D_2DIR,x_apo] = FID_to_2Dspec(D,x,4);
		for i=1:x.N2
            [CL_w3, w1_axis, CLS] = trace_CL(x_apo.w1,[p_true.w_01.val-3,p_true.w_01.val+3],x_apo.w3,[p_true.w_01.val-6,p_true.w_01.val+6],D_2DIR(:,:,i),'Asymmetric Lorentzian');
            CLS_arr(i) = CLS;
		end
	%% fit CLS to obtain kubo time constants
        n_start = nearest_index(x.Tw,0);
		n_end = nearest_index(x.Tw,10);
		init_values = [0.075,0.1046,0.4,1.7].*(1+0.1*randn(1,4));
		CLS_fit = fit_exp_decay(x.Tw(n_start:n_end),CLS_arr(n_start:n_end),init_values);
		CLS_fit_CI = confint(CLS_fit);
		CLS_fit_CI = (CLS_fit_CI(2,:)-CLS_fit_CI(1,:))/2;
        CLS_fit_val = [CLS_fit.A1,CLS_fit.A2,CLS_fit.tau1,CLS_fit.tau2];
		if CLS_fit.tau1 > CLS_fit.tau2 % make sure first kubo time constant is smaller than second
            CLS_fit_val(1:4) = [CLS_fit_val(2),CLS_fit_val(1),CLS_fit_val(4),CLS_fit_val(3)];
            CLS_fit_CI(1:4) = [CLS_fit_CI(2),CLS_fit_CI(1),CLS_fit_CI(4),CLS_fit_CI(3)];
		end
	%% plot CLS
		ax = findobj(CLS_fig,'Tag','A');
			plot(ax,x.Tw,CLS_arr,'k.',x.Tw,feval(CLS_fit,x.Tw),'r-');warning('off','MATLAB:Axes:NegativeDataInLogAxis')
			set(ax,'YMinorTick','on','YScale','log','Box','on','TickLength',[0.02,0]);
			title(ax,sprintf('CLS From Trial %i',trial))
			legend(ax,'CLS','CLS fit');
            ylim(ax,[1e-4,1]);xlim(ax,[0,10]);
		if record_CLS_video
			savefig(CLS_fig,[CLS_dir,sprintf('\\trial%i.fig',trial)]);
		end
	%% fit linear absorption spectrum to obtain kubo amplitude constants 
        load('Input Data\Probe abs.mat');
		w3_fit_range = [p_true.w_01.val-fit_bw_CLS/2,p_true.w_01.val+fit_bw_CLS/2]; % upper 80% of linear absorption
        [n3_min,n3_max] = nearest_index(x.w3,w3_fit_range);
		probe_abs = probe_abs/max(probe_abs);
        fit_type = fittype(@(A,c,kubo1_D2,kubo2_D2,T_hom_inv,w3) Lin_Abs(x,p_true,A,c,[CLS_fit_val(3),CLS_fit_val(4)],[kubo1_D2,kubo2_D2],T_hom_inv,[n3_min,n3_max],w3),'independent','w3');
		fit_options = fitoptions(fit_type);
		init_values = [1.6e-08,1e-3,33.64,6.76,0.2857].*(1+0.1*randn(1,5));
		fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-20,'TolFun',1e-20,'StartPoint',init_values);
        [LA_fit,gof,output] = fit(x.w3(n3_min:n3_max)',probe_abs(n3_min:n3_max)',fit_type,fit_options);
	%% analyze and organize parameters from CLS fitting
        CLS_fit_val(1) = LA_fit.kubo1_D2; % kubo component #1 squared-amplitude is element 1 of CLS_fit_val
        CLS_fit_val(2) = LA_fit.kubo2_D2; % kubo component #2 squared-amplitude is element 2 of CLS_fit_val
        CLS_fit_val(5) = LA_fit.T_hom_inv;  % inverse homogeneous dephasing is element 5 of CLS_fit_val
        temp_CI = confint(LA_fit);
        CLS_fit_CI(1) = (temp_CI(2,3)-temp_CI(1,3))/2; % kubo(1) squared-amplitude is element 3 of LA_fit
        CLS_fit_CI(2) = (temp_CI(2,4)-temp_CI(1,4))/2; % kubo(2) squared-amplitude is element 4 of LA_fit
        CLS_fit_CI(5) = (temp_CI(2,5)-temp_CI(1,5))/2; % inverse homogeneous dephasing is element 5 of LA_fit
        CLS_fit_val_arr(trial,:) = CLS_fit_val;
        CLS_fit_CI_arr(trial,:) = CLS_fit_CI;
        model_fit_val_arr(trial,:) = model_fit_val;
        model_fit_CI_arr(trial,:) = model_fit_CI;
    %% update cost function and SIGN plot
        ax = findobj(C_SIGN_fig,'Tag','A');
            C_line = plot(ax,C_arr);
			set(ax,'YMinorTick','on','YScale','log','Box','on');
			if trial == 1
				max_iter = numel(C_line.XData);
			else
				if numel(C_line.XData) > max_iter
					max_iter = numel(C_line.XData);
				end
			end
			xlim(ax,[1,max_iter]);
		ax = findobj(C_SIGN_fig,'Tag','B');
            lines = plot(ax,SIGN_arr,'Color',C_line.Color);
			if trial == 1
				plot(ax,ones(1,500)*SIGN_lim,'--','Color',[0.5,0.5,0.5]);
			end
			set(ax,'YMinorTick','on','YScale','log');
            xlim(ax,[1,max_iter]);
		if record_C_SIGN_video
			savefig(C_SIGN_fig,[C_SIGN_dir,sprintf('\\trial%i.fig',trial)]);
		end
	%% update plot of parameters obtained from all trials relative to true parameters
        true_vals = [p_true.kubo1_D2.val,p_true.kubo2_D2.val,p_true.kubo1_t.val,p_true.kubo2_t.val,p_true.T_hom_inv.val];
		x_ticks = 1:numel(CLS_fit_val);
		x_tick_labels = {'\Delta^2_1','\Delta^2_2','\tau_1','\tau_2','T_{hom}^{-1}'};
		ax = findobj(trial_params_fig,'Tag','A');
			plot(ax,x_ticks-0.1,CLS_fit_val./true_vals,'b.'); plot(ax,x_ticks+0.1,model_fit_val./true_vals,'r.');
			ylim(ax,[0.5 1.5]);
			xlim(ax,[x_ticks(1)-0.5,x_ticks(numel(x_ticks))+0.5]); xticks(ax,x_ticks); xticklabels(ax,x_tick_labels);
			title(ax,sprintf('Parameters\nFrom %i Trials',trial))
	%% update plot of parameters obtained from last trial relative to true parameters
		ax = findobj(trial_params_fig,'Tag','B');
			cla(ax)
			line(ax,[0,10],[1,1],'Color','k','LineStyle','--');
            errorbar(ax,x_ticks-0.1,CLS_fit_val./true_vals,CLS_fit_CI./true_vals,'b.'); errorbar(ax,x_ticks+0.1,model_fit_val./true_vals,model_fit_CI./true_vals,'r.');
			xlim(ax,[x_ticks(1)-0.5,x_ticks(numel(x_ticks))+0.5]); xticks(ax,x_ticks); xticklabels(ax,x_tick_labels);
            ylim(ax,[0.95 1.05]);
			title(ax,{'Parameters From','An Individual Trial'})
	%% update plot of average parameters (w/ 95% C.I.) obtained from all trials relative to true parameters
		if trial>2
			ax = findobj(trial_params_fig,'Tag','C');
			cla(ax)
			line(ax,[0,10],[1,1],'Color','k','LineStyle','--');
			errorbar(ax,x_ticks-0.1,mean(CLS_fit_val_arr,1)./true_vals,(std(CLS_fit_val_arr,0,1)./true_vals)*tinv(1-0.05/2,trial-1)/sqrt(trial),'b.');
			errorbar(ax,x_ticks+0.1,mean(model_fit_val_arr,1)./true_vals,(std(model_fit_val_arr,0,1)./true_vals)*tinv(1-0.05/2,trial-1)/sqrt(trial),'r.');
			xlim(ax,[x_ticks(1)-0.5,x_ticks(numel(x_ticks))+0.5]); xticks(ax,x_ticks); xticklabels(ax,x_tick_labels);
			ylim(ax,[1-0.005*sqrt(100/trial),1+0.005*sqrt(100/trial)]);
			title(ax,['Average Parameters',newline,sprintf('Over %i Trials',trial)]);
		end
		if record_params_video
			savefig(trial_params_fig,[params_dir,sprintf('\\trial%i.fig',trial)]);
		end
	%% save figure and data
		savefig(C_SIGN_fig,'Output Data\C and SIGN.fig');
		savefig(trial_params_fig,'Output Data\Trial Params.fig');
		save('Output Data\100 trial results.mat','CLS_fit_val_arr','model_fit_val_arr','CLS_fit_CI_arr','model_fit_CI_arr');
	%% save p_arr, p_best_fit, SIGN_arr and C_arr, then clear from memory
		save('Output Data\results.mat','p_arr','p_best_fit','SIGN_arr','C_arr','aux');
		clear p_arr SIGN_arr C_arr aux
	%% clear variables
		clear C_arr SIGN_arr p_arr model_fit_val model_fit_CI CLS_fit_val CLS_fit_CI CLS_fit LA_fit
	%% check for stop fitting
		if stop_fit_btn.Value == 1
			break
		end
end
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
