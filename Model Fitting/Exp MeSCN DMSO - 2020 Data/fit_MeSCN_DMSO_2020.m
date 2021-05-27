clear all
close all
%% set plot limits
	v1_plot_lim = [2110,2180];
	v3_plot_lim = [2110,2180];
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
	update_fig = figure;
		set(update_fig,'Position',[300 200 1200 600]);
%% load data
	load('Input Data\Average 2D IR July 2019.mat');
	[D,x_trunc] = FID_from_2Dspec(avg_spec_3D,x,3.95);
	D(x_trunc.N1,:,:) = 0;
	x = x_trunc;
%% load model
	load('Input Data\p.mat');
%% gather structure of auxiliary information required for algorithm
	aux = ILS_initialize_aux(p);
	save('Output Data\p.mat','p','aux');
%% generate weight mask
% weight along pump time axis
	w_t1 = reshape(ones(size(x.t1)),[x.N1,1,1]); % the reshape function makes this an N1x1x1 vector
	%w_t1(1:nearest_index(x.t1,0.3)) = 0; % don't fit where pulse overlap occurs
	w_t1(x.N1) = 0; % don't fit to last point where unapodizing was unstable
% weight along waiting time axis
	w_Tw = reshape(ones(size(x.Tw)),[1,1,x.N2]); % the reshape function makes this an 1x1xN2 vector
	w_Tw(1:26) = 10;
	w_Tw(27:30) = 20;
	w_Tw(31) = 40;
	w_Tw(32:34) = 60;
	w_Tw(35:36) = 80;
	w_Tw(1:nearest_index(x.Tw,0.3)) = 0; % don't fit where pulse overlap occurs
% weight along probe frequency axis
	w_v3 = reshape(zeros(size(x.v3)),[1,x.N3,1]);  % the reshape function makes this an 1xN3x1 vector
	w_v3(nearest_index(x.v3,2110):nearest_index(x.v3,2180)) = 1;
% composite weight
	w = w_t1.*w_Tw.*w_v3; % the dimensions should end up being N1xN3xN2 if using the reshape functions above
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
	frame = 0;
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
			plot_fit_update(update_fig,p,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,1,aux,timerval,v3_plot_lim);
		%% update video frames from this iteration
			frame = frame+1;
			F_update_fig(frame) = getframe(update_fig);
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
%% determine best fit
	[M,i] = min(SIGN_arr);
	p_best_fit_2020 = p_arr(i);
%% print and save fit
	print_variables(p_best_fit_2020,aux)
	save('Output Data\2020 results.mat','p_arr','p_best_fit_2020','SIGN_arr','C_arr','aux');
	save('..\Exp MeSCN DMSO - 2021 Data\Output Data\2020 results.mat','p_arr','p_best_fit_2020','SIGN_arr','C_arr','aux');
	clear p_arr SIGN_arr C aux
%% save fitting to video
%% make Tw series of 2D spectra comparison between data and fit
	[D_spec_apo,x_apo] = FID_to_2Dspec(D,x,4);
	M_fit = ILS_M(x,p_best_fit_2020);
	[M_spec_apo,x_apo] = FID_to_2Dspec(M_fit,x,4);
	fig = figure;
	for i=1:x.N2
		compare_2Dspec(fig,x_apo,v1_plot_lim,v3_plot_lim,x_apo.Tw(i),D_spec_apo,M_spec_apo);
		F(i) = getframe(fig);
	end
	writerObj = VideoWriter('Output Data\Data Fit Residual Video (DMSO 2019 Data).mp4','MPEG-4');
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
%% run CLS analysis
    CLS_analysis_2020
