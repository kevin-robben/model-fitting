clear all
close all
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% set random number generator seed to 1
	rng('default');
	rng(1);
%% decide on recording videos
	record_fit_update_video = 1;
	record_C_SIGN_video = 1;
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
%% load p
    p = load_params('Input Data\p.csv');
	p_true = p;
%% make axes
	Tw = [ 0:0.1:1 , 1.2:0.2:2 , 2.5:0.5:5, 6:1:10, 15:5:30, 40:20:100];
    x = gen_x([0 4],16,2130,[2110 2190],128,Tw,'real');
%% simulate true (noiseless) FID
	FID = ILS_M(x,p);
%% set SIGN limit
	SIGN_lim = 1e-9;
%% initialize figures
	initial_fit_fig = openfig('Templates\Initial_fit_template.fig');
	C_SIGN_fig = openfig('Templates\C_and_SIGN_template.fig');
	update_fig = figure;set(update_fig,'Position',[20 50 1500 700]);
	pause_stop_fit_fig = uifigure('HandleVisibility','on');
		set(pause_stop_fit_fig,'Position',[500 300 250 50]);
		pause_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Pause Fitting','Value',0,'Position',[20,10, 100, 22]);
		stop_fit_btn = uibutton(pause_stop_fit_fig,'state','Text','Stop Fitting','Value',0,'Position',[130,10, 100, 22]);
%% for loop over different trials of noise and random starting points
for trial=1:20
	%% add noise
		noise = (1e-5)*randn(size(FID));
		D_FID = FID + noise;
	%% generate weight mask
		% weight along pump time axis
			InvVar_masked.pump = reshape(ones(size(x.t1)),[x.N1,1,1]);
		% weight along waiting time axis
			InvVar_masked.Tw = reshape(ones(size(x.Tw)),[1,1,x.N2]);
		% weight along probe frequency axis
			InvVar_masked.probe = reshape(ones(size(x.w3)),[1,x.N3,1]);
		% composite weight
			InvVar_masked.prod = (InvVar_masked.pump).*(InvVar_masked.Tw).*(InvVar_masked.probe);
	%% gather structure of auxiliary fitting information required for algorithm
		aux = ILS_initialize_aux(p);
	%% define initial (guess) model parameters as a random vector in boundary space
		p_init = ILS_rand_params(p,aux);
	%% show comparison between initial guess and data for TA spectrum
		ax = findobj(initial_fit_fig,'Tag','TA');
			M_init = ILS_M(x,p_init);
			n_Tw = 1;n_t1 = 1;
			plot(ax,x.w3,real(D_FID(n_t1,:,n_Tw)),'k-',x.w3,real(M_init(n_t1,:,n_Tw)),'r--');
			xlim(ax,w1_plot_lim);
			legend(ax,'TA from Data','TA from Initial Guess')
		ax = findobj(initial_fit_fig,'Tag','FID');
			plot(ax,x.t1,real(D_FID(:,nearest_index(x.w3,p_init.w_01.val),1)),'k-',x.t1,real(M_init(:,nearest_index(x.w3,p_init.w_01.val),1)),'r--');
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
			[p_arr(iter),cov,C_arr(iter),SIGN_arr(iter),aux] = ILS_p_min(x,p_prev,D_FID,InvVar_masked.prod,aux);
		%% check for stall or convergence
			[aux,break_flag] = ILS_check_stall_conv(aux,C_arr,SIGN_arr,SIGN_lim,iter);
		%% update fitting report
			plot_fit_update(update_fig,p_init,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D_FID,x,InvVar_masked.prod,trial,aux,timerval,w3_plot_lim);
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
			if stop_fit_btn.Value || break_flag
				break
			end
		end
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
			savefig(C_SIGN_fig,sprintf('Output Data\\C and SIGN Figures\\trial%i.fig',trial))
        end
    %% determine best fit
		[M,i] = min(C_arr);
		p_best_fit = p_arr(i);
	%% save p_arr, p_best_fit, SIGN_arr and C_arr, then clear from memory
		save('Output Data\results.mat','p_arr','SIGN_arr','C_arr','aux');
		save_params(p_best_fit,'Output Data\p best fit.csv');
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
