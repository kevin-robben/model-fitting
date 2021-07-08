clear all
close all
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% set plot limits
	w1_plot_lim = [2110,2180];
	w3_plot_lim = [2110,2180];
%% decide on recording videos
	output_dir = 'Output Data 2-Kubo';
	record_fit_update_video = 1;
	fit_update_dir = [output_dir,'\Fitting Update Figures'];
	C_SIGN_dir = [output_dir,'\C and SIGN Figures'];
%% add figure folders to Output Data path
	if ~exist(output_dir,'dir')
		mkdir(output_dir);
	end
	if ~exist(fit_update_dir,'dir')
		mkdir(fit_update_dir);
	else
		delete([fit_update_dir,'\*.fig']);
	end
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
%% load data
	load('Input Data\2020 data (MATLAB-Ready).mat');
%% load p
	p = load_params('Input Data\two-kubo init guess.csv');
%% gather structure of auxiliary information required for algorithm
	aux = ILS_initialize_aux(p);
%% iterative fitting:
	timerval = tic;
	frame = 0;
	for iter=1:200
		%% find p_min for this iteration
			if iter == 1
				p_prev = p;
			else
				p_prev = p_arr(iter-1);
			end
			[p_arr(iter),cov,C_arr(iter),SIGN_arr(iter),aux] = ILS_p_min(x,p_prev,D_FID,InvVar_masked.prod,aux);
		%% check for stall or convergence
			[aux,break_flag] = ILS_check_stall_conv(aux,C_arr,SIGN_arr,SIGN_lim,iter);
			if break_flag
				break
			end
		%% update fitting report
			plot_fit_update(update_fig,p,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D_FID,x,InvVar_masked.prod,1,aux,timerval,w3_plot_lim);
		%% update video frames from this iteration
			if record_fit_update_video
				savefig(update_fig,[fit_update_dir,sprintf('\\iter%i.fig',iter)]);
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
	if stop_fit_btn.Value == 1
		stop_fit_btn.Value = 0;
	end
%% update cost function and SIGN plot
	ax = findobj(initial_fit_fig,'Tag','TA');
		set(ax,'YMinorTick','on','YScale','log','Box','on');
		max_iter = numel(C_line.XData);
		xlim([1,max_iter]);
	ax = findobj(initial_fit_fig,'Tag','FID');lines = plot(ax,SIGN_arr,'Color',C_line.Color);
		plot(ax,ones(1,500)*SIGN_lim,'--','Color',[0.5,0.5,0.5]);
		set(ax,'YMinorTick','on','YScale','log');
		xlim([1,max_iter]);
		savefig(C_SIGN_fig,[output_dir,'\C and SIGN.fig']);
%% determine best fit
	[M,i] = min(C_arr);
	p_best_fit_2020 = p_arr(i);
%% print and save fit
	print_params(p_best_fit_2020)
	save([output_dir,'\2020 results.mat'],'p_arr','p_best_fit_2020','SIGN_arr','C_arr','aux');
	clear p_arr SIGN_arr C aux
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');