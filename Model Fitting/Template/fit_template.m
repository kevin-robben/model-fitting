clear all;
close all;
%% set plot limits
	w1_plot_lim = [2115,2185];
	w3_plot_lim = [2115,2185];
%% set SIGN limit
	SIGN_lim = 1e-9;
%% load data and independent variables x
    load('Input Data\FID.mat');
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% import initial collective parameter guess
	load('Input Data\p.mat');
%% gather structure of auxiliary fitting information required for algorithm
	aux = ILS_initialize_aux(p);
%% clear p_fit, SIGN, C and aux before next trial
	clear p_fit SIGN C aux
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
