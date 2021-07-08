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
	output_dir = 'Output Data 1-Kubo';
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
	p = load_params('Input Data\one-kubo init guess.csv');
%% gather structure of auxiliary information required for algorithm
	aux = ILS_initialize_aux(p);
%% show comparison between initial guess and data for TA spectrum
	ax = nexttile(initial_fit_layout,1);
		cla(ax);
		M_init = ILS_M(x,p);
		plot(ax,x.w3,real(D_FID(1,:,1)),'k-',x.w3,real(M_init(1,:,1)),'r--');
		xlim(ax,w3_plot_lim);
		legend(ax,'TA from Data','TA from Initial Guess')
	ax = nexttile(initial_fit_layout,2);
		cla(ax);
		plot(ax,x.t1,real(D_FID(:,nearest_index(x.w3,p.w_01.val),1)),'k-',x.t1,real(M_init(:,nearest_index(x.w3,p.w_01.val),1)),'r--');
		legend(ax,'FID from Data','FID from Initial Guess')
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
	save('..\Exp MeSCN DMSO - 2021 Data\Output Data\2020 results.mat','p_arr','p_best_fit_2020','SIGN_arr','C_arr','aux');
	clear p_arr SIGN_arr C aux
%% make Tw series of 2D spectra comparison between data and fit
	[D_spec_apo,x_apo] = FID_to_2Dspec(D_FID,x,4);
	M_fit = ILS_M(x,p_best_fit_2020);
	[M_spec_apo,x_apo] = FID_to_2Dspec(M_fit,x,4);
	for i=1:x.N2
        fig = compare_2Dspec(x_apo,w1_plot_lim,w3_plot_lim,x_apo.Tw(i),D_spec_apo,M_spec_apo,'2020 Data');
		F(i) = getframe(fig);
        close(fig);
	end
	writerObj = VideoWriter('Output Data\Data Fit Residual Video (DMSO 2020 Data).mp4','MPEG-4');
	writerObj.FrameRate = 2;
	writerObj.Quality = 100;
	open(writerObj);
	for i=1:length(F)
		writeVideo(writerObj,F(i));
	end
	close(writerObj);
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');

