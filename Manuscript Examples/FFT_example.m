clear all
close all
%% declare number of samples, maximum sample time, and DC frequency (aka rotating frame)
	N1 = 30; % number of samples
	t1_max = 32; % maximum sample time measured
	DC_freq = 2100; % rotating frame
	
%% generate time axis
	dt1 = t1_max/(N1-1); % time step
	t1 = (0:1:N1-1)*dt1; % DC + positive half of time axis
	t1_neg = -fliplr(1:numel(t1)) * dt1; % negative half of time axis

%% generate frequency axis
	dw1 = 1/(0.03*dt1*2*N1); % frequency step size (factor of 2 accounts for negative half of time axis)
	w1 = (0:1:N1-1)*dw1 + DC_freq; % DC + positive frequency half axis
	w1_neg = -fliplr(1:numel(w1)) * dw1 + DC_freq; % negative frequency half axis
	w = [w1,w1_neg]; % total frequency axis
	
%% compute FID
	w0 = w1(17); % center frequency
	tau = 6; % lifetime
	FID_DC_pos = exp(1i*t1*(w0+DC_freq)*2*pi*0.03-t1/tau); % FID for DC and positive frequency half
	FID_neg = zeros(size(t1_neg)); % FID for negative frequency half
	
%% compute the spectrum
	spec_from_complex_FID = real(fft(FID_DC_pos,2*N1));
	spec_from_real_FID = 2*real(fft(real(FID_DC_pos),2*N1));
	
%% plot: WITHOUT 1/2 scaling of the DC sample, ignoring the Nyquist sample
	f = figure;set(f,'Position',[0,585,1540,210]);tile = tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
	title(tile,'WITHOUT 1/2 scaling of the DC sample, ignoring the Nyquist sample')
	ax = nexttile;
	plot(ax,[t1_neg,t1],[zeros(size(t1_neg)),real(FID_DC_pos)],'r-',[t1_neg,t1],[zeros(size(t1_neg)),imag(FID_DC_pos)],'b-');
	hold on;plot(0,real(FID_DC_pos(1)),'r.','MarkerSize',12);plot(0,imag(FID_DC_pos(1)),'b.','MarkerSize',12);hold off;
	legend(ax,'Re\{FID\}','Im\{FID\}');
	xlabel(ax,'Time');ylabel(ax,'Response');title(ax,'FID');
	ax = nexttile;
	plot(ax,fftshift(w),fftshift(spec_from_complex_FID),'k-',fftshift(w),fftshift(spec_from_real_FID),'k--');
	legend(ax,'Complex-Valued FID','Real-Valued FID');xlim(ax,[w1(1)-1.5*(w1(N1)-w1(1)),w1(1)+1.5*(w1(N1)-w1(1))]);ylim(ax,[0,1.3*tau])
	xlabel(ax,'Frequency');ylabel(ax,'Re\{FFT(FID)\}');title(ax,'Spectrum');

%% now scale DC sample by 1/2
	FID_DC_pos(1) = FID_DC_pos(1)/2; % scale DC sample by 1/2
	spec_from_complex_FID = real(fft(FID_DC_pos,2*N1)); % compute the spectrum from complex-valued FID
	spec_from_real_FID = 2*real(fft(real(FID_DC_pos),2*N1)); % compute the spectrum from real-valued FID
	
%% plot: WITH 1/2 scaling of the DC sample, ignoring the Nyquist sample
	f = figure;set(f,'Position',[0,312,1540,210]);tile = tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
	title(tile,'WITH 1/2 scaling of the DC sample, ignoring the Nyquist sample')
	ax = nexttile;
	plot(ax,[t1_neg,t1],[zeros(size(t1_neg)),real(FID_DC_pos)],'r-',[t1_neg,t1],[zeros(size(t1_neg)),imag(FID_DC_pos)],'b-');
	hold on;plot(0,real(FID_DC_pos(1)),'r.','MarkerSize',12);plot(0,imag(FID_DC_pos(1)),'b.','MarkerSize',12);hold off;
	legend(ax,'Re\{FID\}','Im\{FID\}');
	xlabel(ax,'Time');ylabel(ax,'Response');title(ax,'FID');
	ax = nexttile;
	plot(ax,fftshift(w),fftshift(spec_from_complex_FID),'k-',fftshift(w),fftshift(spec_from_real_FID),'k--');
	legend(ax,'Complex-Valued FID','Real-Valued FID');xlim(ax,[w1(1)-1.5*(w1(N1)-w1(1)),w1(1)+1.5*(w1(N1)-w1(1))]);ylim(ax,[0,1.3*tau])
	xlabel(ax,'Frequency');ylabel(ax,'Re\{FFT(FID)\}');title(ax,'Spectrum');
	
%% now account for nyquist sample and scale by 1/2
	t1_nyquist = t1_max+dt1; % nyquist time
	FID_nyquist = (1/2) * exp(1i*t1_nyquist*(w0+DC_freq)*2*pi*0.03-t1_nyquist/tau); % nyquist sample with 1/2 scaling
	FID = [FID_DC_pos,FID_nyquist,zeros(1,N1-1)]; % append nyquist sample to the FID
	spec_from_complex_FID = real(fft(FID,2*N1)); % compute the spectrum from complex-valued FID
	spec_from_real_FID = 2*real(fft(real(FID),2*N1)); % compute the spectrum from real-valued FID
	
%% plot: WITH 1/2 scaling of the DC sample, including 1/2 scaled Nyquist sample
	f = figure;set(f,'Position',[0,40,1540,210]);tile = tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
	title(tile,'WITH 1/2 scaling of the DC sample, including 1/2 scaled Nyquist sample')
	ax = nexttile;
	plot(ax,[t1_neg,t1],circshift(real(FID),[1,N1]),'r-',[t1_neg,t1],circshift(imag(FID),[1,N1]),'b-');
	hold on;plot(0,real(FID(1)),'r.','MarkerSize',12);plot(0,imag(FID(1)),'b.','MarkerSize',12);
	plot(t1_neg(1),real(FID(N1+1)),'r.','MarkerSize',12);plot(t1_neg(1),imag(FID(N1+1)),'b.','MarkerSize',12);hold off;
	legend(ax,'Re\{FID\}','Im\{FID\}');
	xlabel(ax,'Time');ylabel(ax,'Response');title(ax,'FID');
	ax = nexttile;
	plot(ax,fftshift(w),fftshift(spec_from_complex_FID),'k-',fftshift(w),fftshift(spec_from_real_FID),'k--');
	legend(ax,'Complex-Valued FID','Real-Valued FID');xlim(ax,[w1(1)-1.5*(w1(N1)-w1(1)),w1(1)+1.5*(w1(N1)-w1(1))]);ylim(ax,[0,1.3*tau])
	xlabel(ax,'Frequency');ylabel(ax,'Re\{FFT(FID)\}');title(ax,'Spectrum');


