clear all
close all
%% decide on recording videos
	record_fit_update_video = 0;
		fit_update_dir = 'Output Data\Fitting Update Figures';
	record_C_SIGN_video = 0;
		C_SIGN_dir = 'Output Data\C and SIGN Figures';
	record_CLS_video = 0;
		CLS_dir = 'Output Data\CLS Figures';
	record_params_video = 0;
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
	v1_plot_lim = [2115,2185];
	v3_plot_lim = [2115,2185];
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
	initial_fit_fig = figure;
		set(initial_fit_fig,'Position',[300 200 800 300]);
		initial_fit_layout = tiledlayout(initial_fit_fig,1,2,'Padding','compact','TileSpacing','compact');
	pause_stop_fit_fig = uifigure('HandleVisibility','on');
		set(pause_stop_fit_fig,'Position',[500 300 250 50]);
		pause_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Pause Fitting','Value',0,'Position',[20,10, 100, 22]);
		stop_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Stop Fitting','Value',0,'Position',[130,10, 100, 22]);
	C_SIGN_fig = figure;
		set(C_SIGN_fig,'Position',[50 50 400 600]);
		C_SIGN_layout = tiledlayout(C_SIGN_fig,2,1,'Padding','compact');
		annotation(C_SIGN_fig,'textbox',[0.01 0.95 0.05 0.03],'String','(A)','LineStyle','none','FitBoxToText','off');
		annotation(C_SIGN_fig,'textbox',[0.01 0.46 0.05 0.03],'String','(B)','LineStyle','none','FitBoxToText','off');
	update_fig = figure;
		set(update_fig,'Position',[300 200 1200 600]);
	CLS_fig = figure;
		set(CLS_fig,'Position',[50 50 400 300]);
		CLS_layout = tiledlayout(CLS_fig,1,1,'Padding','compact');
	LA_fig = figure;
		set(LA_fig,'Position',[50 50 400 300]);
		LA_layout = tiledlayout(LA_fig,1,1,'Padding','compact');
	trial_params_fig = figure;
		set(trial_params_fig,'Position',[50 50 1200 300]);
		trial_params_layout = tiledlayout(trial_params_fig,1,4,'Padding','compact','TileSpacing','compact');
		annotation(trial_params_fig,'textbox',[0.03 0.9 0.025 0.085],'String','(A)','LineStyle','none','FitBoxToText','off');
		annotation(trial_params_fig,'textbox',[0.26 0.9 0.025 0.085],'String','(B)','LineStyle','none','FitBoxToText','off');
		annotation(trial_params_fig,'textbox',[0.49 0.9 0.025 0.085],'String','(C)','LineStyle','none','FitBoxToText','off');
		annotation(trial_params_fig,'textbox',[0.72 0.9 0.025 0.085],'String','(D)','LineStyle','none','FitBoxToText','off');

%% for loop over different trials of noise and random starting points
for trial=1:100
	%% add noise
		noise = (5e-6)*(randn(size(FID))+1i*randn(size(FID)));
		D = FID + noise;
	%% generate weight mask
		% weight along pump time axis
			w_t1 = reshape(ones(size(x.t1)),[x.N1,1,1]);
		% weight along waiting time axis
			w_Tw = reshape(ones(size(x.Tw)),[1,1,x.N2]);
		% weight along probe frequency axis
			w_v3 = reshape(ones(size(x.v3)),[1,x.N3,1]);
		% composite weight
			w = w_t1.*w_Tw.*w_v3;
	%% gather structure of auxiliary fitting information required for algorithm
		aux = ILS_initialize_aux(p);
	%% define initial (guess) model parameters as a random vector in boundary space
		p = ILS_rand_params(p,aux);
	%% show comparison between initial guess and data for TA spectrum
		ax = nexttile(initial_fit_layout,1);
			cla(ax);
			M_init = ILS_M(x,p);
			n_Tw = 5;n_t1 = 5;
			plot(ax,x.v3,w_v3.*real(D(n_t1,:,n_Tw)),'k-',x.v3,w_v3.*real(M_init(n_t1,:,n_Tw)),'r--');
			xlim(ax,[2110,2190]);
			xlabel(ax,'Probe Frequency (cm^{-1})');ylabel('\DeltaOD');title(ax,'TA Comparison');
			legend(ax,'TA from Data','TA from Initial Guess')
		ax = nexttile(initial_fit_layout,2);
			cla(ax);
			plot(ax,x.t1,w_t1.*real(D(:,nearest_index(x.v3,p.v_01.val),1)),'k-',x.t1,w_t1.*real(M_init(:,nearest_index(x.v3,p.v_01.val),1)),'r--');
			xlabel(ax,'\tau_1 (ps)');ylabel('\DeltaOD');title(ax,'FID Comparison');
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
			if break_flag
				break
			end
		%% update fitting report
			plot_fit_update(update_fig,p,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,trial,aux,timerval,v3_plot_lim);
			%% add reticles to fitting report to symbolize true values
				%% homogeneous reticle
					ax = update_fig.Children.Children(4);
					line(ax,[0.2857,0.2857],[0.02857-0.005,0.02857+0.005],'Color','k','LineStyle','--');
					line(ax,[0.2857-0.05,0.2857+0.05],[0.02857,0.02857],'Color','k','LineStyle','--');
				%% frequency reticle
					ax = update_fig.Children.Children(5);
					line(ax,[2162.4,2162.4],[27-1,27+1],'Color','k','LineStyle','--');
					line(ax,[2162.4-1,2162.4+1],[27,27],'Color','k','LineStyle','--');
				%% Kubo reticles
					ax = update_fig.Children.Children(3);
					line(ax,[0.4,0.4],[33.64-5,33.64+5],'Color','k','LineStyle','--');
					line(ax,[0.4-0.4,0.4+0.4],[33.64,33.64],'Color','k','LineStyle','--');
					line(ax,[1.7-0.4,1.7+0.4],[6.76,6.76],'Color','k','LineStyle','--');
					line(ax,[1.7,1.7],[6.76-5,6.76+5],'Color','k','LineStyle','--');
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
			if stop_fit_btn.Value == 1
				break
			end
		end
	%% determine best fit
		[M,i] = min(SIGN_arr);
		p_best_fit = p_arr(i);
	%% organize parameters (and CIs) from model fitting such that smaller kubo time constant is always first
        model_fit_val = [ p_best_fit.kubo1_D2.val, p_best_fit.kubo2_D2.val, p_best_fit.kubo1_t.val, p_best_fit.kubo2_t.val, p_best_fit.T_hom_inv.val];
		model_fit_CI = [ p_best_fit.kubo1_D2.CI', p_best_fit.kubo2_D2.CI', p_best_fit.kubo1_t.CI', p_best_fit.kubo2_t.CI', p_best_fit.T_hom_inv.CI'];
		model_fit_CI = (model_fit_CI(2,:)-model_fit_CI(1,:))/2;
		if p_best_fit.kubo1_t.val > p_best_fit.kubo2_t.val % make sure first kubo time constant is smaller than second
            model_fit_val(1:4) = [model_fit_val(2),model_fit_val(1),model_fit_val(4),model_fit_val(3)];
            model_fit_CI(1:4) = [model_fit_CI(2),model_fit_CI(1),model_fit_CI(4),model_fit_CI(3)];
		end
	%% measure CLS of experimental data
        [D_2DIR,x_apo] = FID_to_2Dspec(D,x,4);
		for i=1:x.N2
            [CL_v3, v1_axis, CLS] = trace_CL(x_apo.v1,[2162.4-3,2162.4+3],x_apo.v3,[2162.4-6,2162.4+6],D_2DIR(:,:,i),'Asymmetric Lorentzian');
            CLS_arr(i) = CLS;
		end
	%% fit CLS to obtain kubo time constants
        n_start = nearest_index(x.Tw,0);
		n_end = nearest_index(x.Tw,10);
		CLS_fit = fit_exp_decay(x.Tw(n_start:n_end),CLS_arr(n_start:n_end),[0.3,0.3,0.4,2]);
		CLS_fit_CI = confint(CLS_fit);
		CLS_fit_CI = (CLS_fit_CI(2,:)-CLS_fit_CI(1,:))/2;
        CLS_fit_val = [CLS_fit.A1,CLS_fit.A2,CLS_fit.tau1,CLS_fit.tau2];
		if CLS_fit.tau1 > CLS_fit.tau2 % make sure first kubo time constant is smaller than second
            CLS_fit_val(1:4) = [CLS_fit_val(2),CLS_fit_val(1),CLS_fit_val(4),CLS_fit_val(3)];
            CLS_fit_CI(1:4) = [CLS_fit_CI(2),CLS_fit_CI(1),CLS_fit_CI(4),CLS_fit_CI(3)];
		end
	%% plot CLS
		ax = nexttile(CLS_layout,1);
			cla(ax)
			hold(ax,'on');
			plot(ax,x.Tw,CLS_arr,'k.',x.Tw,feval(CLS_fit,x.Tw),'r-');warning('off','MATLAB:Axes:NegativeDataInLogAxis')
			set(ax,'YMinorTick','on','YScale','log','Box','on');
			xlim(ax,[0,10]);xlabel(ax,'T_w (ps)');ylabel(ax,'CLS');title(ax,sprintf('CLS From Trial %i',trial))
			legend(ax,'CLS','CLS fit');
            ax.YLim(1) = 1e-4;
		if record_CLS_video
			savefig(CLS_fig,[CLS_dir,sprintf('\\trial%i.fig',trial)]);
		end
	%% fit linear absorption spectrum to obtain kubo amplitude constants 
        load('Input Data\Probe abs.mat');
		v3_fit_range = [2162.4-9,2162.4+9]; % upper 80% of linear absorption
        [n3_min,n3_max] = nearest_index(x.v3,v3_fit_range);
		probe_abs = probe_abs/max(probe_abs);
        fit_type = fittype(@(A,c,kubo1_D2,kubo2_D2,T_hom_inv,v3) Lin_Abs(x,p_true,A,c,[CLS_fit_val(3),CLS_fit_val(4)],[kubo1_D2,kubo2_D2],T_hom_inv,[n3_min,n3_max],v3),'independent','v3');
		fit_options = fitoptions(fit_type);
		fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-20,'TolFun',1e-20,'StartPoint',[1e-4,0,33,7,0.3]);
        [LA_fit,gof,output] = fit(x.v3(n3_min:n3_max)',probe_abs(n3_min:n3_max)',fit_type,fit_options);
	%% analyze and organize parameters from CLS fitting
        CLS_fit_val(1) = LA_fit.kubo1_D2;
        CLS_fit_val(2) = LA_fit.kubo2_D2;
        CLS_fit_val(5) = LA_fit.T_hom_inv;
        temp_CI = confint(LA_fit);
        CLS_fit_CI(1) = (temp_CI(2,1)-temp_CI(1,1))/2;
        CLS_fit_CI(2) = (temp_CI(2,2)-temp_CI(1,2))/2;
        CLS_fit_CI(5) = (temp_CI(2,3)-temp_CI(1,3))/2;
        CLS_fit_val_arr(trial,:) = CLS_fit_val;
        CLS_fit_CI_arr(trial,:) = CLS_fit_CI;
        model_fit_val_arr(trial,:) = model_fit_val;
        model_fit_CI_arr(trial,:) = model_fit_CI;
    %% update cost function and SIGN plot
        ax = nexttile(C_SIGN_layout,1);
            hold(ax,'on');
            C_line = plot(ax,C_arr);
			set(ax,'YMinorTick','on','YScale','log','Box','on');
            ylabel(ax,'C');xlabel(ax,'Iteration');title(ax,'Cost Function');
			if trial == 1
				max_iter = numel(C_line.XData);
			else
				if numel(C_line.XData) > max_iter
					max_iter = numel(C_line.XData);
				end
			end
			xlim([1,max_iter]);
		ax = nexttile(C_SIGN_layout,2);
			ax.Box = 'on';
            hold(ax,'on');
            lines = plot(ax,SIGN_arr,'Color',C_line.Color);
			if trial == 1
				plot(ax,ones(1,500)*SIGN_lim,'--','Color',[0.5,0.5,0.5]);
			end
			set(ax,'YMinorTick','on','YScale','log');
            xlabel(ax,'Iteration');ylabel(ax,'$$\widetilde{|\nabla{C}|}$$','Interpreter','LaTeX');title(ax,'Scale Invariant Gradient Norm (SIGN)');
			xlim([1,max_iter]);
		if record_C_SIGN_video
			savefig(C_SIGN_fig,[C_SIGN_dir,sprintf('\\trial%i.fig',trial)]);
		end
	%% update plot of parameters obtained from all trials relative to true parameters
        true_vals = [p_true.kubo1_D2.val,p_true.kubo2_D2.val,p_true.kubo1_t.val,p_true.kubo2_t.val,p_true.T_hom_inv.val];
		ax = nexttile(trial_params_layout,1);
			hold(ax,'on');
            line(ax,[0,6],[1,1],'Color','k','LineStyle','--');
            plot(ax,(1:5)-0.1,CLS_fit_val./true_vals,'b.');
            plot(ax,(1:5)+0.1,model_fit_val./true_vals,'r.');
            xlim(ax,[0,6]);ylim([0 2]);
            xticks(ax,[1 2 3 4 5])
            xticklabels(ax,{'\Delta^2_1','\Delta^2_2','\tau_1','\tau_2','T_{hom}^{-1}'})
            set(ax,'Box','on');
            ylabel(ax,'Fit / True');title(ax,sprintf('Parameters From %i Trials',trial))
	%% update plot of parameters obtained from last trial relative to true parameters
		true_vals = [p_true.kubo1_D2.val,p_true.kubo2_D2.val,p_true.kubo1_t.val,p_true.kubo2_t.val,p_true.T_hom_inv.val];
		ax = nexttile(trial_params_layout,2);
			cla(ax);
			hold(ax,'on');
			line(ax,[0,6],[1,1],'Color','k','LineStyle','--');
            errorbar(ax,(1:5)-0.1,CLS_fit_val./true_vals,CLS_fit_CI./true_vals,'b.');
            errorbar(ax,(1:5)+0.1,model_fit_val./true_vals,model_fit_CI./true_vals,'r.');
            xlim(ax,[0,6]);ylim(ax,[0.9 1.1]);
			xticks(ax,[1 2 3 4 5])
            xticklabels(ax,{'\Delta^2_1','\Delta^2_2','\tau_1','\tau_2','T_{hom}^{-1}'})
			set(ax,'Box','on');
            ylabel(ax,'Fit / True (w/ est. 95% C.I.)');title(ax,[sprintf('Parameters From Trial %i',trial),newline,'(w/ est. 95% C.I.)'])
	%% update plot of average parameters (w/ S.D.) obtained from all trials relative to true parameters
		if trial>2
			ax = nexttile(trial_params_layout,3);
			cla(ax);
			hold(ax,'on');
			line(ax,[0,6],[1,1],'Color','k','LineStyle','--');
			errorbar(ax,(1:5)-0.1,mean(CLS_fit_val_arr,1)./true_vals,(std(CLS_fit_val_arr,0,1)./true_vals),'b.');
			errorbar(ax,(1:5)+0.1,mean(model_fit_val_arr,1)./true_vals,(std(model_fit_val_arr,0,1)./true_vals),'r.');
			xlim(ax,[0,6]);ylim(ax,[0.9 1.1]);
			xticks(ax,[1 2 3 4 5])
			xticklabels(ax,{'\Delta^2_1','\Delta^2_2','\tau_1','\tau_2','T_{hom}^{-1}'})
			set(ax,'Box','on');
			ylabel(ax,'\langleFit\rangle / True');title(ax,['Average Parameters',newline,sprintf('Over %i Trials (w/ S.D.)',trial)]);
		end
	%% update plot of average parameters (w/ 95% C.I.) obtained from all trials relative to true parameters
		if trial>2
			ax = nexttile(trial_params_layout,4);
			cla(ax);
			hold(ax,'on');
			line(ax,[0,6],[1,1],'Color','k','LineStyle','--');
			errorbar(ax,(1:5)-0.1,mean(CLS_fit_val_arr,1)./true_vals,(std(CLS_fit_val_arr,0,1)./true_vals)*tinv(1-0.05/2,trial-1)/sqrt(trial),'b.');
			errorbar(ax,(1:5)+0.1,mean(model_fit_val_arr,1)./true_vals,(std(model_fit_val_arr,0,1)./true_vals)*tinv(1-0.05/2,trial-1)/sqrt(trial),'r.');
			xlim(ax,[0,6]);ylim(ax,[0.95 1.05]);
			xticks(ax,[1 2 3 4 5])
			xticklabels(ax,{'\Delta^2_1','\Delta^2_2','\tau_1','\tau_2','T_{hom}^{-1}'})
			set(ax,'Box','on');
			ylabel(ax,'\langleFit\rangle / True ');title(ax,['Average Parameters',newline,sprintf('Over %i Trials (w/ 95%% C.I.)',trial)]);
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
%% clear frames from memory
	clear F_C_SIGN_fig F_CLS_fig F_update_fig F_trial_params_fig;
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
