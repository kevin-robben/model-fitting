%% define initial (guess) model parameters using a structure data type
	% Formatting Tip: Go to Home->Preferences->Editor/Debugger->Tab, unselect "Tab key inserts spaces"
    p.('A01')				= struct('val',4,		'var',1,	'bounds1',1e-1,	'bounds2',1e2,	'units','arb. unit','label','A_{01}',		'SD',0, 'CI',[0,0]);
	p.('A12')				= struct('val',4,		'var',1,	'bounds1',1e-1,	'bounds2',1e2,	'units','arb. unit','label','A_{12}',		'SD',0, 'CI',[0,0]);
    p.('v_01')				= struct('val',2153.3,	'var',0,	'bounds1',2152,	'bounds2',2156,	'units','cm^{-1}',	'label','\omega_{01}',		'SD',0, 'CI',[0,0]);
    p.('cal_err')			= struct('val',-0.3,	'var',1,	'bounds1',-5,	'bounds2',5,	'units','cm^{-1}',	'label','\delta\omega_1',	'SD',0, 'CI',[0,0]);
    p.('Anh')				= struct('val',25.5,	'var',0,	'bounds1',24,	'bounds2',28,	'units','cm^{-1}',	'label','\Delta_{Anh}',	'SD',0, 'CI',[0,0]);
    p.('kubo1_t')			= struct('val',1,		'var',1,	'bounds1',1e-9,	'bounds2',20,	'units','ps',		'label','\tau_1',		'SD',0, 'CI',[0,0]);
    p.('kubo1_D2')			= struct('val',15,		'var',1,	'bounds1',0,	'bounds2',50,	'units','cm^{-2}',	'label','\Delta_1^2',	'SD',0, 'CI',[0,0]);
    p.('kubo_anh_fctr')		= struct('val',1,		'var',1,	'bounds1',0.5,	'bounds2',1.5,	'units','unitless',	'label','\beta',		'SD',0, 'CI',[0,0]);
    p.('T_LT_inv')			= struct('val',0.013,	'var',1,	'bounds1',0.01,	'bounds2',0.02,	'units','ps^{-1}',	'label','T_{LT}^{-1}',	'SD',0, 'CI',[0,0]);
    p.('T_hom_inv')			= struct('val',0.4,		'var',1,	'bounds1',1e-9,	'bounds2',1,	'units','ps^{-1}',	'label','T_{Hom}^{-1}',	'SD',0, 'CI',[0,0]);
%% save p
	save('Input Data\p.mat','p');