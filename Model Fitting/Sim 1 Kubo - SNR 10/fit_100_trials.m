clear all
close all
%% decide on recording videos
	record_fit_update_video = 0;
		fit_update_dir = 'Output Data\Fitting Update Figures';
	record_C_SIGN_video = 0;
		C_SIGN_dir = 'Output Data\C and SIGN Figures';
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
	if ~exist(params_dir,'dir') && record_params_video
		mkdir(params_dir);
    else
        delete([params_dir,'\*.fig']);
	end
%% set plot limits
	w1_plot_lim = [2115,2185];
	w3_plot_lim = [2115,2185];
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
		set(initial_fit_fig,'Position',[300 200 600 250]);
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
		set(update_fig,'Position',[300 200 1200 600]);
	template_fig = openfig('template figure.fig');
		ax1 = template_fig.Children(1);
		ax2 = template_fig.Children(2);
		ax3 = template_fig.Children(3);
		ax4 = template_fig.Children(4);
		ax5 = template_fig.Children(5);

%% for loop over different trials of noise and random starting points
for trial=1:100
	%% add noise
		noise = (1.138e-4)*randn(size(FID));
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
			n_Tw = 5;n_t1 = 5;
			plot(ax,x.w3,w_w3.*real(D(n_t1,:,n_Tw)),'k-',x.w3,w_w3.*real(M_init(n_t1,:,n_Tw)),'r--');
			xlim(ax,[2110,2190]);
			xlabel(ax,'Probe Frequency (cm^{-1})');ylabel('\DeltaOD');title(ax,'TA Comparison');
			legend(ax,'TA from Data','TA from Initial Guess')
		ax = nexttile(initial_fit_layout,2);
			cla(ax);
			plot(ax,x.t1,w_t1.*real(D(:,nearest_index(x.w3,p.v_01.val),1)),'k-',x.t1,w_t1.*real(M_init(:,nearest_index(x.w3,p.v_01.val),1)),'r--');
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
			plot_fit_update(update_fig,p,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,trial,aux,timerval,w3_plot_lim);
			%% add reticles to fitting report to symbolize true values
				%% homogeneous reticle
					ax = update_fig.Children.Children(4);
					line(ax,[0.4,0.4],[0.2-0.02,0.2+0.02],'Color','k','LineStyle','--');
					line(ax,[0.4-0.05,0.4+0.05],[0.2,0.2],'Color','k','LineStyle','--');
				%% frequency reticle
					ax = update_fig.Children.Children(5);
					line(ax,[2160,2160],[25-1,25+1],'Color','k','LineStyle','--');
					line(ax,[2160-1,2160+1],[25,25],'Color','k','LineStyle','--');
				%% Kubo reticles
					ax = update_fig.Children.Children(3);
					line(ax,[3.5,3.5],[15-5,15+5],'Color','k','LineStyle','--');
					line(ax,[3.5-0.5,3.5+0.5],[15,15],'Color','k','LineStyle','--');
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
        model_fit_val = [ p_best_fit.kubo1_D2.val, p_best_fit.kubo1_t.val, p_best_fit.T_hom_inv.val];
		model_fit_CI = [ p_best_fit.kubo1_D2.CI', p_best_fit.kubo1_t.CI', p_best_fit.T_hom_inv.CI'];
		model_fit_CI = (model_fit_CI(2,:)-model_fit_CI(1,:))/2;
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
        true_vals = [p_true.kubo1_D2.val,p_true.kubo1_t.val,p_true.T_hom_inv.val];
		ax = ax3;
			hold(ax,'on');
            line(ax,[0,4],[1,1],'Color','k','LineStyle','--');
            plot(ax,(1:3),model_fit_val./true_vals,'r.');
            xlim(ax,[0.5,3.5]);ylim(ax,[0.8 1.2]);
			xticks(ax,[1 2 3])
            xticklabels(ax,{'\Delta^2_1','\tau_1','T_{hom}^{-1}'})
            set(ax,'Box','on');
            ylabel(ax,'Fit / True');title(ax,sprintf('Parameters From\n%i Trials',trial))
	%% update plot of parameters obtained from last trial relative to true parameters
		true_vals = [p_true.kubo1_D2.val,p_true.kubo1_t.val,p_true.T_hom_inv.val];
		ax = ax2;
			cla(ax);
			hold(ax,'on');
			line(ax,[0,4],[1,1],'Color','k','LineStyle','--');
            errorbar(ax,(1:3),model_fit_val./true_vals,model_fit_CI./true_vals,'r.');
            xlim(ax,[0.5,3.5]);ylim(ax,[0.8 1.2]);
			xticks(ax,[1 2 3])
            xticklabels(ax,{'\Delta^2_1','\tau_1','T_{hom}^{-1}'})
			set(ax,'Box','on');
            ylabel(ax,'Fit / True');title(ax,{'Parameters An','Individual Trial'})
	%% update plot of average parameters (w/ 95% C.I.) obtained from all trials relative to true parameters
		if trial>2
			ax = ax1;
			cla(ax);
			hold(ax,'on');
			line(ax,[0,4],[1,1],'Color','k','LineStyle','--');
			errorbar(ax,(1:3),mean(model_fit_val_arr,1)./true_vals,(std(model_fit_val_arr,0,1)./true_vals)*tinv(1-0.05/2,trial-1)/sqrt(trial),'r.');
			xlim(ax,[0.5,3.5]);ylim(ax,[0.9 1.1]);
			xticks(ax,[1 2 3])
            xticklabels(ax,{'\Delta^2_1','\tau_1','T_{hom}^{-1}'})
			set(ax,'Box','on');
			ylabel(ax,'\langleFit\rangle / True ');title(ax,['Average Parameters',newline,sprintf('Over %i Trials',trial)]);
		end
	%% add pump-probe and 2D IR
		if trial == 1
			%% 2D IR
				[spec,x_apo] = FID_to_2Dspec(D,x,4);
				plot_2Dspec(ax4,x_apo,[2130,2180],[2115,2185],spec(:,:,1),'2D IR Spectrum at T_W = 0')
				ax4.DataAspectRatioMode = 'auto';
			%% pump-probe
				M = ILS_M(x,p_best_fit);
				plot(ax5,x.w3,D(1,:,1),'k-',x.w3,M(1,:,1),'r-')
				title(ax5,'Transient Absorption at T_W = 0');
				xlabel(ax5,'Probe (cm^{-1})');ylabel(ax5,'\DeltaOD');
		end
	%% record video
		if record_params_video
			savefig(template_fig,[params_dir,sprintf('\\trial%i.fig',trial)]);
		end
	%% save figure and data
		savefig(C_SIGN_fig,'Output Data\C and SIGN.fig');
		savefig(template_fig,'Output Data\Template Figure.fig');
	%% save p_arr, p_best_fit, SIGN_arr and C_arr, then clear from memory
		save('Output Data\results.mat','p_arr','p_best_fit','SIGN_arr','C_arr','aux');
		clear p_arr SIGN_arr C_arr aux
	%% clear variables
		clear C_arr SIGN_arr p_arr model_fit_val model_fit_CI
	%% check for stop fitting
		if stop_fit_btn.Value == 1
			break
		end
end
%% clear frames from memory
	clear F_C_SIGN_fig F_update_fig F_trial_params_fig;
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
