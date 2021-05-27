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
%% load data
%     [file,path] = uigetfile('Input Data\*.mat','Select Input Data');
%     load(strcat(path,file));
	load('Input Data\FID.mat');
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
	C_SIGN_fig = figure;
		set(C_SIGN_fig,'Position',[50 50 400 600]);
		C_SIGN_layout = tiledlayout(C_SIGN_fig,2,1,'Padding','compact');
%% load p
	load('Input Data\p.mat');
%% create undersampling masks
	US_fctr = [1,2,3,5,10,20,40];
	mask = ones(length(US_fctr),x.N2);
	n_common = nearest_index(x.Tw,1);
	mask(:,1:2) = 0;
	US_mask_fig = figure;set(US_mask_fig,'Position',[500 300 400 300]);
	ax = axes(US_mask_fig,'Box','on','TickLength',[0.02,0.025]);
	hold(ax,'on');
	ax.YTick = 1:numel(US_fctr);
	for k=1:numel(US_fctr)
		%% undersampling mask
			for n=1:x.N2
				if rem(n-n_common,US_fctr(k)) ~= 0
					mask(k,n) = 0;
				end
				if mask(k,n) == 1
					plot(ax,x.Tw(n),numel(US_fctr)-k+1,'k.','MarkerSize',10);
					ax.XScale = 'log';
					ylim([0,length(US_fctr)+1]);
					xlabel('T_w (ps)');ylabel('Number of Points Sampled');
				end
			end
			ax.YTickLabel(k) = {num2str(sum(mask(k,:)))};
	end
	ax.YTickLabel = flip(ax.YTickLabel);
	ax.XLim(2) = 10^3;
	title(ax,'Sampling Masks');
	savefig('Output Data\Sampling Masks.fig');
	save('Output Data\Undersampling.mat','US_fctr','mask');
%% for loop over different sampling masks
frame = 0;
for k=1:numel(US_fctr)
	%% gather structure of auxiliary fitting information required for algorithm
		aux = ILS_initialize_aux(p);
		save('Output Data\p.mat','p','aux');
	%% generate undersampled x structure
		x_US = gen_x([x.v1(1),x.v1(x.N1)],x.N1,[x.v3(1),x.v3(x.N3)],x.N3,x.Tw(logical(mask(k,:))),'complex');
	%% generate weight mask
    % weight along pump time axis
        w_t1 = reshape(ones(size(x_US.t1)),[x_US.N1,1,1]);
    % weight along waiting time axis
        w_Tw = reshape(ones(size(x_US.Tw)),[1,1,x_US.N2]);
    % weight along probe frequency axis
		w_v3 = reshape(zeros(size(x_US.v3)),[1,x_US.N3,1]);
		w_v3(nearest_index(x_US.v3,2110):nearest_index(x_US.v3,2180)) = 1;
    % composite weight
        w = w_t1.*w_Tw.*w_v3;
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
				[p_arr(iter),cov,C_arr(iter),SIGN_arr(iter),aux] = ILS_p_min(x_US,p_prev,D(:,:,logical(mask(k,:))),w,aux);
			%% check for stall or convergence
				[aux,break_flag] = ILS_check_stall_conv(aux,C_arr,SIGN_arr,SIGN_lim,iter);
				if break_flag
					break
				end
			%% update fitting report
				plot_fit_update(update_fig,p,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D(:,:,logical(mask(k,:))),x_US,k,aux,timerval,v3_plot_lim);
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
		p_best_fit(k) = p_arr(i);
	%% update cost function and SIGN plot
        ax = nexttile(C_SIGN_layout,1);
            hold(ax,'on');
			name = strcat(num2str(sum(mask(k,:))),' T_w points');
            C_line = plot(ax,C_arr,'DisplayName',name);
			set(ax,'YMinorTick','on','YScale','log','Box','on');
            ylabel(ax,'C');xlabel(ax,'Iteration');title(ax,'Cost Function');
			if k == 1
				max_iter = numel(C_line.XData);
			else
				if numel(C_line.XData) > max_iter
					max_iter = numel(C_line.XData);
				end
			end
			xlim([1,max_iter]);
			legend
		ax = nexttile(C_SIGN_layout,2);
			ax.Box = 'on';
            hold(ax,'on');
			if k == 1
				plot(ax,ones(1,500)*SIGN_lim,'--','Color',[0.5,0.5,0.5],'DisplayName','SIGN Limit');
			end
			lines = plot(ax,SIGN_arr,'Color',C_line.Color,'DisplayName',name);
			set(ax,'YMinorTick','on','YScale','log');
            xlabel(ax,'Iteration');ylabel(ax,'$$\widetilde{|\nabla{C}|}$$','Interpreter','LaTeX');title(ax,'Scale Invariant Gradient Norm (SIGN)');
			xlim([1,max_iter]);
			legend(ax)
		savefig(C_SIGN_fig,'Output Data\\C and SIGN.fig');
	%% print and save fit
		fprintf('Sampling Mask = %i points:\n',sum(mask(k,:)));
		print_variables(p_best_fit(k),aux)
		save('Output Data\p_best_fit.mat','p_best_fit');
		save(strcat('Output Data\results Num_sample_',num2str(sum(mask(k,:))),'.mat'),'p_arr','SIGN_arr','C_arr','aux');
		clear p_arr SIGN_arr C_arr aux
end
%% make Tw series of 2D IR comparison between data and fit
	[D_spec_apo,x_apo] = FID_to_2Dspec(D,x,4);
	M_fit = ILS_M(x,p_best_fit(1));
	[M_spec_apo,x_apo] = FID_to_2Dspec(M_fit,x,4);
	fig = figure;
	for i=1:x.N2
		compare_2Dspec(fig,x_apo,v1_plot_lim,v3_plot_lim,x_apo.Tw(i),D_spec_apo,M_spec_apo);
		F(i) = getframe(fig);
	end
	writerObj = VideoWriter('Output Data\Data Fit Residual Video.mp4','MPEG-4');
	writerObj.FrameRate = 2;
	writerObj.Quality = 100;
	open(writerObj);
	for i=1:length(F)
		writeVideo(writerObj,F(i));
	end
	close(writerObj);
%% save fitting to video
	for i=1:numel(US_fctr)
		writerObj = VideoWriter(sprintf('Output Data\\Fitting Video N_%i.mp4',US_fctr(i)),'MPEG-4');
		writerObj.FrameRate = 2;
		writerObj.Quality = 50;
		open(writerObj);
		for frame=1:numel(F_update_fig)
			writeVideo(writerObj,F_update_fig(frame));
		end
		close(writerObj);
	end
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
%% run fitting analysis
	fitting_analysis_2021
	
