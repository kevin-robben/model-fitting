clear all;
close all;
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define model parameters using a structure data type
	%% Formatting Tip: Go to Home->Preferences->Editor/Debugger->Tab, unselect "Tab key inserts spaces"
	p.('A01')				= struct('val',1e-4,	'var',1,	'bounds1',1e-5,     'bounds2',1e-3,     'units','arb. unit','label','A_{01}',           'SD',0, 'CI',0);
	p.('A12')				= struct('val',1e-4,	'var',1,	'bounds1',1e-5,     'bounds2',1e-3,     'units','arb. unit','label','A_{12}',           'SD',0, 'CI',0);
	p.('w_01')				= struct('val',2162.4,	'var',1,	'bounds1',2161.4,	'bounds2',2163.4,	'units','cm^{-1}',	'label','\omega_{01}',		'SD',0, 'CI',0);
	p.('cal_err')			= struct('val',0,		'var',1,	'bounds1',-2,       'bounds2',2,        'units','cm^{-1}',	'label','\delta\omega_1',	'SD',0, 'CI',0);
	p.('Anh')				= struct('val',27,		'var',1,	'bounds1',25,       'bounds2',29,       'units','cm^{-1}',	'label','\Delta_{Anh}',     'SD',0, 'CI',0);
	p.('kubo_anh_fctr')		= struct('val',1,		'var',1,	'bounds1',0.5,      'bounds2',1.5,      'units','unitless',	'label','\beta',            'SD',0, 'CI',0);
	p.('T_LT_inv')			= struct('val',0.02857,	'var',1,	'bounds1',1e-3,     'bounds2',0.1,      'units','ps^{-1}',	'label','T_{LT}^{-1}',      'SD',0, 'CI',0);
	p.('T_hom_inv')			= struct('val',0.2857,	'var',1,	'bounds1',0.01,     'bounds2',1,        'units','ps^{-1}',	'label','T_{Hom}^{-1}',     'SD',0, 'CI',0);
	p.('kubo1_t')			= struct('val',0.4,		'var',1,	'bounds1',0.1,      'bounds2',20,       'units','ps',		'label','\tau_1',           'SD',0, 'CI',0);
	p.('kubo1_D2')			= struct('val',33.64,   'var',1,	'bounds1',0,        'bounds2',50,       'units','cm^{-2}',	'label','\Delta_1^2',       'SD',0, 'CI',0);
	p.('kubo2_t')			= struct('val',3.6,		'var',1,	'bounds1',0.1,      'bounds2',20,       'units','ps',		'label','\tau_2',           'SD',0, 'CI',0);
	p.('kubo2_D2')			= struct('val',0,		 'var',1,	'bounds1',0,        'bounds2',50,       'units','cm^{-2}',	'label','\Delta_2^2',       'SD',0, 'CI',0);
%% save p
	save('Input Data\p.mat','p');
%% define independent variables
    Tw = [ 0:0.1:1 , 1.2:0.2:2 , 2.5:0.5:5, 6:1:10, 15:5:30, 40:20:100];
    x = gen_x([0 4],16,2130,[2110 2190],128,Tw,'real');
%% compute and save FID
	FID = ILS_M(x,p);
	save('Input Data\FID.mat','FID','x');
%% compute, display and save FID, TA, 2D IR and population decay
	[spec,x_apo] = FID_to_2Dspec(FID,x,4);
	fig = figure;set(fig,'Position',[50,50,600,500]);t = tiledlayout(fig,2,2,'Padding','compact','TileSpacing','compact');
	ax = nexttile(t,1);plot(ax,x.t1,FID(:,nearest_index(x.w3,p.w_01.val),1));title('FID at T_w = 0');xlabel('Coherence Time (ps)');ylabel('\DeltaOD')
	ax = nexttile(t,2);plot_2Dspec(ax,x_apo,[x_apo.w1(1),x_apo.w1(x_apo.N1)],[x_apo.w3(1),x_apo.w3(x_apo.N3)],spec(:,:,1),'2D IR at T_w = 0');
	ax = nexttile(t,3);plot(ax,x_apo.w3,FID(1,:,1));title('TA at T_w = 0');xlabel('Probe (cm^{-1})');ylabel('\DeltaOD')
	ax = nexttile(t,4);plot(ax,x_apo.Tw,-min(reshape(FID(1,:,:),[x_apo.N3,x_apo.N2]),[],1),'k.','MarkerSize',10);xlabel('T_w (ps)');ylabel('minus peak \DeltaOD');title('Population Decay')
	savefig(fig,'Output Data\TA 2D IR and Population Decay.fig');
%% compute and save linear absorption spectrum
	probe_abs = M_1st_order_kubo(x,p);
	probe_w3 = x.w3;
	save('Input Data\probe abs.mat','probe_abs','probe_w3');
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');