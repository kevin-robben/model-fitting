clear all
close all
%% add paths
    addpath('ILS Functions\');
    addpath('Lineshape Functions\');
    addpath('Miscellaneous Functions\');
%% define initial (guess) model parameters using a structure data type
	% Formatting Tip: Go to Home->Preferences->Editor/Debugger->Tab, unselect "Tab key inserts spaces"
    p.('A01')				= struct('val',15,		'var',1,	'bounds1',1e-1,	'bounds2',1e2,	'units','arb. unit','label','A_{01}',		'SD',0, 'CI',0);
	p.('A12')				= struct('val',15,		'var',1,	'bounds1',1e-1,	'bounds2',1e2,	'units','arb. unit','label','A_{12}',		'SD',0, 'CI',0);
    p.('w_01')				= struct('val',2153.3,	'var',1,	'bounds1',2152,	'bounds2',2156,	'units','cm^{-1}',	'label','\omega_{01}',		'SD',0, 'CI',0);
    p.('cal_err')			= struct('val',-0.3,	'var',1,	'bounds1',-5,	'bounds2',5,	'units','cm^{-1}',	'label','\delta\omega_1',	'SD',0, 'CI',0);
    p.('Anh')				= struct('val',25.5,	'var',1,	'bounds1',24,	'bounds2',28,	'units','cm^{-1}',	'label','\Delta_{Anh}',	'SD',0, 'CI',0);
    p.('kubo_anh_fctr')		= struct('val',1,		'var',1,	'bounds1',0.5,	'bounds2',1.5,	'units','unitless',	'label','\beta',		'SD',0, 'CI',0);
    p.('T_LT_inv')			= struct('val',0.013,	'var',1,	'bounds1',0.01,	'bounds2',0.02,	'units','ps^{-1}',	'label','T_{LT}^{-1}',	'SD',0, 'CI',0);
    p.('T_hom_inv')			= struct('val',0.4,		'var',1,	'bounds1',0.1,	'bounds2',2,	'units','ps^{-1}',	'label','T_{Hom}^{-1}',	'SD',0, 'CI',0);
	p.('kubo1_t')			= struct('val',1,		'var',1,	'bounds1',0.1,	'bounds2',20,	'units','ps',		'label','\tau_1',		'SD',0, 'CI',0);
    p.('kubo1_D2')			= struct('val',15,		'var',1,	'bounds1',0,	'bounds2',50,	'units','cm^{-2}',	'label','\Delta_1^2',	'SD',0, 'CI',0);
%% save p
	save('Input Data\p.mat','p');
%% load data, FFT to FID, restore rectangular window and save FID
	load('Input Data\Average 2D IR July 2019.mat');
	[D,x_trunc] = FID_from_2Dspec(avg_spec_3D,x,3.95);
	D(x_trunc.N1,:,:) = 0;
	x = x_trunc;
	save('Input Data\FID.mat','D','x');
%% compute model
	M = ILS_M(x,p);
%% compute and display FID, TA, 2D IR and population decay
	[M_spec,x_apo] = FID_to_2Dspec(M,x,4);
	fig = figure;set(fig,'Position',[50,50,600,500]);t = tiledlayout(fig,2,2,'Padding','compact','TileSpacing','compact');
	title(t,'Initial Guess')
	ax = nexttile(t,1);plot(ax,x.t1,M(:,nearest_index(x.w3,p.w_01.val),1),'r-',x.t1,D(:,nearest_index(x.w3,p.w_01.val),1),'k-');
		title('FID at T_w = 0');xlabel('Coherence Time (ps)');ylabel('\DeltaOD');legend('Model','Data')
	ax = nexttile(t,2);plot_2Dspec(ax,x_apo,[x_apo.w1(1),x_apo.w1(x_apo.N1)],[x_apo.w3(1),x_apo.w3(x_apo.N3)],M_spec(:,:,1),'2D IR at T_w = 0');
	ax = nexttile(t,3);plot(ax,x.w3,M(1,:,1),x.w3,D(1,:,1));
		title('TA at T_w = 0');xlabel('Probe (cm^{-1})');ylabel('\DeltaOD');legend('Model','Data')
	ax = nexttile(t,4);plot(ax,x.Tw,-min(reshape(M(1,:,:),[x.N3,x.N2]),[],1),'r.','MarkerSize',10);hold on;
		plot(ax,x.Tw,-min(reshape(real(D(1,:,:)),[x.N3,x.N2]),[],1),'k.','MarkerSize',10);
		title('Population Decay');xlabel('T_w (ps)');ylabel('minus peak \DeltaOD');legend('Model','Data')
%% remove paths
    rmpath('ILS Functions\');
    rmpath('Lineshape Functions\');
    rmpath('Miscellaneous Functions\');