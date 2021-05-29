clear all
close all
%% suppress warnings
	warning('off','all')
%% decide on recording videos
	record_fit_update_video = 0;
	record_C_SIGN_video = 0;
%% add figure folders to Output Data path
	if ~exist('Output Data\C and SIGN Figures','dir') && record_C_SIGN_video
		mkdir('Output Data\C and SIGN Figures');
	else
		delete('Output Data\C and SIGN Figures\*.fig');
	end
	if ~exist('Output Data\Fitting Update Figures','dir') && record_C_SIGN_video
		mkdir('Output Data\Fitting Update Figures');
	else
		delete('Output Data\Fitting Update Figures\*.fig');
	end
%% set plot limits
	w1_plot_lim = [2115,2185];
	w3_plot_lim = [2115,2185];
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% load p
    load('Input Data\p.mat');
%% load data
    load('Input Data\FID.mat');
%% set SIGN limit
	SIGN_lim = 1e-9;
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
%% for loop over different trials of noise and random starting points
for trial=1:20
	%% add noise
		noise = (5e-6)*(randn(size(FID))+1i*randn(size(FID)));
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
		p_init = ILS_rand_params(p,aux);
	%% show comparison between initial guess and data for TA spectrum
		ax = nexttile(initial_fit_layout,1);
			cla(ax);
			M_init = ILS_M(x,p_init);
			n_Tw = 5;n_t1 = 5;
			plot(ax,x.w3,w_w3.*real(D(n_t1,:,n_Tw)),'k-',x.w3,w_w3.*real(M_init(n_t1,:,n_Tw)),'r--');
			xlim(ax,[2110,2190]);
			xlabel(ax,'Probe Frequency (cm^{-1})');ylabel('\DeltaOD');title(ax,'TA Comparison');
			legend(ax,'TA from Data','TA from Initial Guess')
		ax = nexttile(initial_fit_layout,2);
			cla(ax);
			plot(ax,x.t1,w_t1.*real(D(:,nearest_index(x.w3,p_init.v_01.val),1)),'k-',x.t1,w_t1.*real(M_init(:,nearest_index(x.w3,p_init.v_01.val),1)),'r--');
			xlabel(ax,'\tau_1 (ps)');ylabel('\DeltaOD');title(ax,'FID Comparison');
			legend(ax,'FID from Data','FID from Initial Guess')
	%% iterative fitting:
		timerval = tic;
		for iter=1:200
		%% find p_min for this iteration
			if iter == 1
				p_prev = p_init;
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
			plot_fit_update(update_fig,p_init,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,trial,aux,timerval,w3_plot_lim);
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
		%% update video frames from this iteration
			if record_fit_update_video
				savefig(update_fig,sprintf('Output Data\\Fitting Update Figures\\trial%i iter%i.fig',trial,iter))
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
			savefig(C_SIGN_fig,sprintf('Output Data\\C and SIGN Figures\\trial%i.fig',trial))
        end
    %% determine best fit
		[M,i] = min(C_arr);
		p_best_fit(trial) = p_arr(i);
	%% save p_arr, p_best_fit, SIGN_arr and C_arr, then clear from memory
		save('Output Data\results.mat','p_arr','p_best_fit','SIGN_arr','C_arr','aux');
		clear p_arr SIGN_arr C_arr aux
	%% check for stop fitting
		if stop_fit_btn.Value == 1
			break
		end
end
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
