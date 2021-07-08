clear all
close all
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% load data
	load('Input Data\2020 data (MATLAB-Ready).mat');
	load('Output Data 1-Kubo\2020 results.mat');
	p_fit = p_best_fit_2020;
	[D_spec,x_zpd] = FID_to_2Dspec(D_FID,x,4);
%% measure CLS
	for i=1:x.N2
		[CL_w3, w1_axis_2020, CLS] = trace_CL(x_zpd.w1,[2153.3-2.5,2153.3+2.5],x_zpd.w3,[2153.3-6,2153.3+6],D_spec(:,:,i),'Asymmetric Lorentzian');
		CLS_arr_01_2020(i) = CLS;
		CL_w3_arr_01_2020(i,:) = CL_w3;
		[CL_w3, w1_axis_2020, CLS] = trace_CL(x_zpd.w1,[2153.3-2.5,2153.3+2.5],x_zpd.w3,[2127.8-6,2127.8+6],-D_spec(:,:,i),'Asymmetric Lorentzian');
		CLS_arr_12_2020(i) = CLS;
		CL_w3_arr_12_2020(i,:) = CL_w3;
	end
	n_tw_start = nearest_index(x_zpd.Tw,2); % make lower bound of Tw fitting range 2 ps for 2020 data
	n_tw_end = nearest_index(x_zpd.Tw,10); % make upper bound of Tw fitting range 10
	CLS_fit_01_2020 = fit_exp_decay(x_zpd.Tw(n_tw_start:n_tw_end),CLS_arr_01_2020(n_tw_start:n_tw_end),[0.4,0.3]);
	CLS_fit_12_2020 = fit_exp_decay(x_zpd.Tw(n_tw_start:n_tw_end),CLS_arr_12_2020(n_tw_start:n_tw_end),[0.4,0.3]);
	Tw_arr_2020 = x_zpd.Tw;
	save('Output Data\CLS Analysis (2020 Data).mat','Tw_arr_2020','CLS_arr_01_2020','CLS_fit_01_2020','CLS_fit_12_2020','w1_axis_2020','CL_w3_arr_01_2020');
	save('..\Exp MeSCN DMSO - 2021 Data\Output Data\CLS Analysis (2020 Data).mat','Tw_arr_2020','CLS_arr_01_2020','CLS_fit_01_2020','CLS_fit_12_2020');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
