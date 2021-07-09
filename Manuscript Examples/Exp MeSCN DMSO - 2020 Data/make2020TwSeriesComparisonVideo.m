clear all
close all
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% load CLS data
	load('Output Data\CLS Analysis (2020 Data).mat');
%% load FID and fitting results
	load('Input Data\2020 data (MATLAB-Ready).mat');
	load('Output Data 1-Kubo\2020 results.mat');
	p_fit = p_best_fit_2020;
%% set plot limits
	w1_plot_lim = [2110,2180];
	w3_plot_lim = [2110,2180];
%% make Tw series of 2D spectra comparison between data and fit
	M_fit = ILS_M(x,p_best_fit_2020);
	[M_spec,x_zpd] = FID_to_2Dspec(M_fit,x,4);
	[D_spec,x_zpd] = FID_to_2Dspec(D_FID,x,4);
	for i=1:x.N2
        fig = compare_2Dspec(x_zpd,w1_plot_lim,w3_plot_lim,x_zpd.Tw(i),D_spec,M_spec,'2020 Data');
		plot(fig.Children(2),w1_axis_2020,CL_w3_arr_01_2020(i,:),'y.','MarkerSize',4);
		plot(fig.Children(6),w1_axis_2020,CL_w3_arr_01_2020(i,:),'y.','MarkerSize',4);
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
