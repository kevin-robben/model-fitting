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
	if ~exist(params_dir,'dir') && record_params_video
		mkdir(params_dir);
	else
		delete([params_dir,'\*.fig']);
	end
%% set plot limits
	w1_plot_lim = [2020,2120];
	w3_plot_lim = [2020,2120];
%% load p
	load('Input Data\p.mat');
	p_true = p;
	p.phi.var = 0; % comment this line to enable fitting the phase error
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
		set(initial_fit_fig,'Position',[300 200 600 300]);
		initial_fit_layout = tiledlayout(initial_fit_fig,1,2,'Padding','compact','TileSpacing','compact');
	pause_stop_fit_fig = uifigure('HandleVisibility','on');
		set(pause_stop_fit_fig,'Position',[500 300 250 50]);
		pause_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Pause Fitting','Value',0,'Position',[20,10, 100, 22]);
		stop_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Stop Fitting','Value',0,'Position',[130,10, 100, 22]);
	C_SIGN_fig = figure;
		set(C_SIGN_fig,'Position',[50 50 300 500]);
		C_SIGN_layout = tiledlayout(C_SIGN_fig,2,1,'Padding','compact');
		annotation(C_SIGN_fig,'textbox',[0.01 0.95 0.05 0.03],'String','(A)','LineStyle','none','FitBoxToText','off');
		annotation(C_SIGN_fig,'textbox',[0.01 0.46 0.05 0.03],'String','(B)','LineStyle','none','FitBoxToText','off');
	update_fig = figure;
		set(update_fig,'Position',[20 50 1500 700]);
	trial_params_fig = openfig('template figure.fig');
		ax1 = trial_params_fig.Children(1);
		ax2 = trial_params_fig.Children(2);
		ax3 = trial_params_fig.Children(3);
		ax4 = trial_params_fig.Children(4);
		ax5 = trial_params_fig.Children(5);
		
%% for loop over different trials of noise and random starting points
for trial=1:100
	%% add noise
		noise = (1e-4)/10*randn(size(FID));
		p_temp = p_true;
		p_temp.phi.val = 6*randn;
		FID = M_3rd_order_kubo(x,p_temp);
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
		ax = nexttile(initial_fit_layout,1);
			cla(ax);
			M_init = ILS_M(x,p);
			n_Tw = 1;n_t1 = 1;
			plot(ax,x.w3,w_w3.*real(D(n_t1,:,n_Tw)),'k-',x.w3,w_w3.*real(M_init(n_t1,:,n_Tw)),'r--');
			xlim(ax,w3_plot_lim);
			xlabel(ax,'Probe Frequency (cm^{-1})');ylabel('\DeltaOD');title(ax,'TA Comparison');
			legend(ax,'TA from Data','TA from Initial Guess')
		ax = nexttile(initial_fit_layout,2);
			cla(ax);
			plot(ax,x.t1,w_t1.*real(D(:,nearest_index(x.w3,p.w_01.val),1)),'k-',x.t1,w_t1.*real(M_init(:,nearest_index(x.w3,p.w_01.val),1)),'r--');
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
		%% update fitting report
			plot_fit_update(update_fig,p,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,w,trial,aux,timerval,w3_plot_lim);
			%% add reticles to fitting report to symbolize true values
				%% frequency reticle
					ax = update_fig.Children.Children(3);
					rx = p_true.w_01;
					ry = p_true.Anh;
					drx = (rx.bounds2-rx.bounds1)/8;
					dry = (ry.bounds2-ry.bounds1)/8;
					line(ax,[rx.val,rx.val],[ry.val-dry,ry.val+dry],'Color','k','LineStyle','--');
					line(ax,[rx.val-drx,rx.val+drx],[ry.val,ry.val],'Color','k','LineStyle','--');
				%% lifetime reticle
					ax = update_fig.Children.Children(4);
					rx = p_true.T_hom_inv;
					ry = p_true.T_LT_inv;
					drx = (rx.bounds2-rx.bounds1)/8;
					dry = (ry.bounds2-ry.bounds1)/8;
					line(ax,[rx.val,rx.val],[ry.val-dry,ry.val+dry],'Color','k','LineStyle','--');
					line(ax,[rx.val-drx,rx.val+drx],[ry.val,ry.val],'Color','k','LineStyle','--');
				%% amplitude reticle
					ax = update_fig.Children.Children(2);
					rx = p_true.A01;
					ry = p_true.A12;
					line(ax,[rx.val,rx.val],[0.8*ry.val,1.3*ry.val],'Color','k','LineStyle','--');
					line(ax,[0.8*rx.val,1.3*rx.val],[ry.val,ry.val],'Color','k','LineStyle','--');
				%% Kubo reticles
					ax = update_fig.Children.Children(5);
					rx = p_true.kubo1_t;
					ry = p_true.kubo1_D2;
					dry = (ry.bounds2-ry.bounds1)/8;
					line(ax,[rx.val,rx.val],[ry.val-dry,ry.val+dry],'Color','k','LineStyle','--');
					line(ax,[0.5*rx.val,2*rx.val],[ry.val,ry.val],'Color','k','LineStyle','--');
					rx = p_true.kubo2_t;
					ry = p_true.kubo2_D2;
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
        model_fit_val = [ p_best_fit.kubo1_D2.val, p_best_fit.kubo2_D2.val, p_best_fit.kubo1_t.val, p_best_fit.T_hom_inv.val];
		model_fit_CI = [ p_best_fit.kubo1_D2.CI, p_best_fit.kubo2_D2.CI, p_best_fit.kubo1_t.CI, p_best_fit.T_hom_inv.CI];
        model_fit_val_arr(trial,:) = model_fit_val;
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
        true_vals = [p_true.kubo1_D2.val,p_true.kubo2_D2.val,p_true.kubo1_t.val,p_true.T_hom_inv.val];
		ax = ax3;
			hold(ax,'on');
            line(ax,[0,5],[1,1],'Color','k','LineStyle','--');
            plot(ax,(1:4)+0.1,model_fit_val./true_vals,'r.');
            xlim(ax,[0.5,4.5]);ylim([0 2]);
            xticks(ax,[1 2 3 4])
            xticklabels(ax,{'\Delta^2_1','\Delta^2_2','\tau_1','T_{hom}^{-1}'})
            set(ax,'Box','on','TickLength',[0.02,0]);
            ylabel(ax,'Fit / True');title(ax,sprintf('Parameters\nFrom %i Trials',trial))
	%% update plot of parameters obtained from last trial relative to true parameters
		ax = ax2;
			cla(ax);
			hold(ax,'on');
			line(ax,[0,5],[1,1],'Color','k','LineStyle','--');
            errorbar(ax,(1:4)+0.1,model_fit_val./true_vals,model_fit_CI./true_vals,'r.');
            xlim(ax,[0.5,4.5]);ylim(ax,[0.5 1.5]);
			xticks(ax,[1 2 3 4])
            xticklabels(ax,{'\Delta^2_1','\Delta^2_2','\tau_1','T_{hom}^{-1}'})
			set(ax,'Box','on','TickLength',[0.02,0]);
            ylabel(ax,'Fit / True');title(ax,{'Parameters From','An Individual Trial'})
	%% update plot of average parameters (w/ 95% C.I.) obtained from all trials relative to true parameters
		if trial>2
			ax = ax1;
			cla(ax);
			hold(ax,'on');
			line(ax,[0,5],[1,1],'Color','k','LineStyle','--');
			errorbar(ax,(1:4)+0.1,mean(model_fit_val_arr,1)./true_vals,(std(model_fit_val_arr,0,1)./true_vals)*tinv(1-0.05/2,trial-1)/sqrt(trial),'r.');
			xlim(ax,[0.5,4.5]);ylim(ax,[1-0.01*sqrt(100/trial),1+0.01*sqrt(100/trial)]);
			xticks(ax,[1 2 3 4])
			xticklabels(ax,{'\Delta^2_1','\Delta^2_2','\tau_1','T_{hom}^{-1}'})
			set(ax,'Box','on','TickLength',[0.02,0]);
			ylabel(ax,'\langleFit\rangle / True ');title(ax,['Average Parameters',newline,sprintf('Over %i Trials',trial)]);
		end
	%% add pump-probe and 2D IR
		[spec,x_apo] = FID_to_2Dspec(D,x,4);
		plot_2Dspec(ax4,x_apo,w1_plot_lim,w3_plot_lim,spec(:,:,1),'2D IR Spectrum at T_W = 0')
		ax4.DataAspectRatioMode = 'auto';
		M = ILS_M(x,p_best_fit);
		plot(ax5,x.w3,D(1,:,1),'k-',x.w3,M(1,:,1),'r-')
		title(ax5,'Transient Absorption at T_W = 0');
		xlabel(ax5,'Probe (cm^{-1})');ylabel(ax5,'\DeltaOD');
		xlim(ax5,w1_plot_lim);
	%% record parameter video
		if record_params_video
			savefig(trial_params_fig,[params_dir,sprintf('\\trial%i.fig',trial)]);
		end
	%% save figure and data
		savefig(C_SIGN_fig,'Output Data\C and SIGN.fig');
		savefig(trial_params_fig,'Output Data\Trial Params.fig');
		save('Output Data\100 trial results.mat','model_fit_val_arr');
	%% save p_arr, p_best_fit, SIGN_arr and C_arr, then clear from memory
		save('Output Data\results.mat','p_arr','p_best_fit','SIGN_arr','C_arr','aux');
		clear p_arr SIGN_arr C_arr aux
	%% clear variables
		clear C_arr SIGN_arr p_arr model_fit_val model_fit_CI
	%% check for stop fitting
		if stop_fit_btn.Value == 1
			break
		end
	fprintf('true phase error: %.6g\n',p_temp.phi.val);
	fprintf('fitted phase error: %.6g\n\n',p_best_fit.phi.val);
end
%% clear frames from memory
	clear F_C_SIGN_fig F_update_fig F_trial_params_fig;
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');