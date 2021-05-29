clear all;
close all;
%% define model parameters using a structure data type
	% Formatting Tip: Go to Home->Preferences->Editor/Debugger->Tab, unselect "Tab key inserts spaces"
	p.('A01')				= struct('val',1e-4,	'var',1,	'bounds1',1e-6,	'bounds2',1e-2,	'units','arb. unit','label','A_{01}',		'SD',0, 'CI',[0,0]);
	p.('A12')				= struct('val',1e-4,	'var',1,	'bounds1',1e-6,	'bounds2',1e-2,	'units','arb. unit','label','A_{12}',		'SD',0, 'CI',[0,0]);
	p.('v_01')				= struct('val',2160,	'var',1,	'bounds1',2159,	'bounds2',2161,	'units','cm^{-1}',	'label','\omega_{01}',		'SD',0, 'CI',[0,0]);
	p.('cal_err')			= struct('val',0,		'var',1,	'bounds1',-0.5,	'bounds2',0.5,	'units','cm^{-1}',	'label','\delta\omega_1',	'SD',0, 'CI',[0,0]);
	p.('Anh')				= struct('val',25,		'var',1,	'bounds1',24,	'bounds2',26,	'units','cm^{-1}',	'label','\Delta_{Anh}',	'SD',0, 'CI',[0,0]);
	p.('kubo1_t')			= struct('val',3.5,		'var',1,	'bounds1',1e-9,	'bounds2',10,	'units','ps',		'label','\tau_1',		'SD',0, 'CI',[0,0]);
	p.('kubo1_D2')			= struct('val',15,      'var',1,	'bounds1',0,	'bounds2',50,	'units','cm^{-2}',	'label','\Delta_1^2',	'SD',0, 'CI',[0,0]);
	p.('kubo_anh_fctr')		= struct('val',1,		'var',1,	'bounds1',0.5,	'bounds2',1.5,	'units','unitless',	'label','\beta',		'SD',0, 'CI',[0,0]);
	p.('T_LT_inv')			= struct('val',0.2,     'var',1,	'bounds1',1e-9,	'bounds2',0.5,	'units','ps^{-1}',	'label','T_{LT}^{-1}',	'SD',0, 'CI',[0,0]);
	p.('T_hom_inv')			= struct('val',0.4, 	'var',1,	'bounds1',1e-9,	'bounds2',1,	'units','ps^{-1}',	'label','T_{Hom}^{-1}',	'SD',0, 'CI',[0,0]);
%% save p
	save('Input Data\p.mat','p');
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define independent variables
    Tw = [ 0.2:0.2:1 , 1.5:0.5:4, 6:2:10, 20:10:30];
    x = gen_x([0 4],16,2130,[2100 2200],256,Tw,'real');
%% compute and save FID and x
	FID = ILS_M(x,p);
	save('Input Data\FID.mat','FID','x');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');
	