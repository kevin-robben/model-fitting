clear all;
close all;
%% define model parameters using a structure data type
	% Formatting Tip: Go to Home->Preferences->Editor/Debugger->Tab, unselect "Tab key inserts spaces"
	p.('A01')				= struct('val',1e-4,	'var',1,	'bounds1',1e-5,	'bounds2',1e-3,	'units','arb. unit','label','A_{01}',		'SD',0, 'CI',[0,0]);
	p.('A12')				= struct('val',1e-4,	'var',1,	'bounds1',1e-5,	'bounds2',1e-3,	'units','arb. unit','label','A_{12}',		'SD',0, 'CI',[0,0]);
	p.('v_01')				= struct('val',2162.4,	'var',1,	'bounds1',2161,	'bounds2',2163,	'units','cm^{-1}',	'label','\nu_{01}',		'SD',0, 'CI',[0,0]);
	p.('cal_err')			= struct('val',0,		'var',1,	'bounds1',-2,	'bounds2',2,	'units','cm^{-1}',	'label','\delta\nu_1',	'SD',0, 'CI',[0,0]);
	p.('Anh')				= struct('val',27,		'var',1,	'bounds1',25,	'bounds2',29,	'units','cm^{-1}',	'label','\Delta_{Anh}',	'SD',0, 'CI',[0,0]);
	p.('kubo1_t')			= struct('val',0.4,		'var',1,	'bounds1',1e-9,	'bounds2',10,	'units','ps',		'label','\tau_1',		'SD',0, 'CI',[0,0]);
	p.('kubo1_D2')			= struct('val',33.64,	'var',1,	'bounds1',0,	'bounds2',50,	'units','cm^{-2}',	'label','\Delta_1^2',	'SD',0, 'CI',[0,0]);
	p.('kubo2_t')			= struct('val',1.7,		'var',1,	'bounds1',1e-9,	'bounds2',10,	'units','ps',		'label','\tau_2',		'SD',0, 'CI',[0,0]);
	p.('kubo2_D2')			= struct('val',6.76,	'var',1,	'bounds1',0,	'bounds2',50,	'units','cm^{-2}',	'label','\Delta_2^2',	'SD',0, 'CI',[0,0]);
	p.('kubo_anh_fctr')		= struct('val',1,		'var',1,	'bounds1',0.5,	'bounds2',1.5,	'units','unitless',	'label','\beta',		'SD',0, 'CI',[0,0]);
	p.('T_LT_inv')			= struct('val',0.02857,	'var',1,	'bounds1',1e-9,	'bounds2',0.06,	'units','ps^{-1}',	'label','T_{LT}^{-1}',	'SD',0, 'CI',[0,0]);
	p.('T_hom_inv')			= struct('val',0.2857,	'var',1,	'bounds1',1e-9,	'bounds2',0.6,	'units','ps^{-1}',	'label','T_{Hom}^{-1}',	'SD',0, 'CI',[0,0]);
%% save p
	save('Input Data\p.mat','p');
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define independent variables
    Tw = [ 0:0.1:1 , 1.2:0.2:2 , 2.5:0.5:5, 6:1:10, 15:5:30, 40:20:100];
    x = gen_x([0 4],16,2130,[2100 2200],256,Tw,'complex');
%% compute and save FID
	FID = ILS_M(x,p);
	save('Input Data\FID.mat','FID','x');
%% compute and save linear absorption spectrum
	probe_abs = M_1st_order_kubo(x,p);
	probe_v3 = x.v3;
	save('Input Data\probe abs.mat','probe_abs','probe_v3');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
	