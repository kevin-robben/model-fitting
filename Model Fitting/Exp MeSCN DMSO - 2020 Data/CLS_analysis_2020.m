clear all
close all
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% load data
	load('Input Data\Average 2D IR July 2019.mat');
	load('Output Data\2020 results.mat');
	p_fit = p_best_fit_2020;
%% set plot limits
	w1_plot_lim = [2110,2180];
	w3_plot_lim = [2110,2180];
%% measure CLS
	for i=1:x.N2
		[CL_w3, w1_axis_2020, CLS] = trace_CL(x.w1,[2153.3-2.5,2153.3+2.5],x.w3,[2153.3-6,2153.3+6],avg_spec_3D(:,:,i),'Asymmetric Lorentzian');
		CLS_arr_01_2020(i) = CLS;
		CL_w3_arr_01_2020(i,:) = CL_w3;
		[CL_w3, w1_axis_2020, CLS] = trace_CL(x.w1,[2153.3-2.5,2153.3+2.5],x.w3,[2127.8-6,2127.8+6],-avg_spec_3D(:,:,i),'Asymmetric Lorentzian');
		CLS_arr_12_2020(i) = CLS;
		CL_w3_arr_12_2020(i,:) = CL_w3;
	end
	n_tw_start = nearest_index(x.Tw,2);
	n_tw_end = nearest_index(x.Tw,10);
	CLS_fit_01_2020 = fit_exp_decay(x.Tw(n_tw_start:n_tw_end),CLS_arr_01_2020(n_tw_start:n_tw_end),[0.4,0.3]);
	CLS_fit_12_2020 = fit_exp_decay(x.Tw(n_tw_start:n_tw_end),CLS_arr_12_2020(n_tw_start:n_tw_end),[0.4,0.3]);
	Tw_arr_2020 = x.Tw;
	save('Output Data\CLS Analysis (2020 Data).mat','Tw_arr_2020','CLS_arr_01_2020','CLS_fit_01_2020','CLS_fit_12_2020');
	save('..\Exp MeSCN DMSO - 2021 Data\Output Data\CLS Analysis (2020 Data).mat','Tw_arr_2020','CLS_arr_01_2020','CLS_fit_01_2020','CLS_fit_12_2020');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
