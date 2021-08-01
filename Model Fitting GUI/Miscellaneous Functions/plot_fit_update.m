%% print parameters
function plot_fit_update(fig,p_init,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,w,trial_num,aux,timerval,w3_plot_lim)
	%% include p_init in p_arr array *** note that this pushes p_arr(i) --> p_arr(i+1), however, p_arr(i) still corresponds to C_arr(i) and SIGN(i)***
		p_arr = [p_init,p_arr];
	%% gather arrays to plot later on
		for i=1:iter+1
			vib_arr(i,:) = gather([p_arr(i).w_01.val,p_arr(i).Anh.val]);
			hom_arr(i,:) = gather([p_arr(i).T_hom_inv.val,p_arr(i).T_LT_inv.val]);
			amp_arr(i,:) = gather([p_arr(i).A01.val,p_arr(i).A12.val]);
			if isfield(p_arr(1),'kubo1_t') && isfield(p_arr(1),'kubo1_D2')
				kubo_arr_1(i,:) = gather([p_arr(i).kubo1_t.val,p_arr(i).kubo1_D2.val]);
			end
			if isfield(p_arr(1),'kubo2_t') && isfield(p_arr(1),'kubo2_D2')
				kubo_arr_2(i,:) = gather([p_arr(i).kubo2_t.val,p_arr(i).kubo2_D2.val]);
			end
			if isfield(p_arr(1),'kubo3_t') && isfield(p_arr(1),'kubo3_D2')
				kubo_arr_3(i,:) = gather([p_arr(i).kubo3_t.val,p_arr(i).kubo3_D2.val]);
			end
		end
	%% initialize layout, title
		t = tiledlayout(fig,2,4,'TileSpacing','Compact','Padding','Compact');
		pupr_ax = nexttile(t,1); set(pupr_ax,'Tag','pupr_ax');
		C_ax = nexttile(t,2); set(C_ax,'Tag','C_ax');
		SIGN_ax = nexttile(t,3); set(SIGN_ax,'Tag','SIGN_ax');
		VIF_ax = nexttile(t,4); set(VIF_ax,'Tag','VIF_ax');
		kubo_ax = nexttile(t,5); set(kubo_ax,'Tag','kubo_ax');
		hom_ax = nexttile(t,6); set(hom_ax,'Tag','hom_ax');
		freq_ax = nexttile(t,7); set(freq_ax,'Tag','freq_ax');
		amp_ax = nexttile(t,8); set(amp_ax,'Tag','amp_ax');
		s = seconds(toc(timerval));s.Format = 'hh:mm:ss';
		if aux.stall > 0 && aux.is_nan_or_inf == 0
			title(t,sprintf('Trial %i, Iteration %i (Time: %s)\nFitting Stalled. Attempting to Resolve...',trial_num,iter,s))
		elseif aux.stall > 0 && aux.is_nan_or_inf == 1
			title(t,sprintf('Trial %i, Iteration %i (Time: %s)\nInf or NaN present in model. Attempting to Resolve...',trial_num,iter,s))
		else
			title(t,sprintf('Trial %i, Iteration %i (Time: %s)\n',trial_num,iter,s))
		end
    %% plot the cost function
        ax = C_ax;
		ax.Box = 'on';
		hold(ax,'on');
		plot(ax,1:iter,C_arr(1:iter),'k.-')
		set(ax,'YMinorTick','on','YScale','log');
		ylim(ax,[0.9*min(C_arr(1:iter)),1.1*max(C_arr(1:iter))]);
		xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
		ylabel(ax,'C(\bfp\rm)');xlabel(ax,'Iteration');title(ax,'Cost Function');
    %% plot the scale invariant gradient norm (SIGN)
        ax = SIGN_ax;
		ax.Box = 'on';
		hold(ax,'on');
		plot(ax,1:iter,SIGN_arr(1:iter),'k.-');
		plot(ax,1:iter,ones(1,iter)*SIGN_lim,'--','Color',[0.5,0.5,0.5]);
		set(ax,'YMinorTick','on','YScale','log');
		xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
		xlabel(ax,'Iteration');ylabel(ax,'$$\widetilde{|\nabla{C}|}$$','Interpreter','LaTeX');title(ax,'Scale Invariant Gradient Norm (SIGN)');
	%% plot VIF
		ax = VIF_ax;
		cond_num = plot_VIF(ax,x,p_arr(length(p_arr)),w);
		ylim(ax,[1,1e10]);
		title(ax,sprintf('Multicollinearity\n(Condition Number = %.3e)',cond_num));
	%% plot fit comparison
        ax = pupr_ax;
		ax.Box = 'on';
		M = ILS_M(x,p_arr(iter+1));
		plot(ax,x.w3,real(D(1,:,1)),'k-',x.w3,real(M(1,:,1)),'r-')
		xlim(ax,w3_plot_lim);
		xlabel(ax,'\omega_3 (cm^{-1})');ylabel(ax,'\DeltaOD');title(ax,'Fit Comparison');
		xtickformat(ax,'%0.0g');ytickformat(ax,'%0.0g')
		legend(ax,'Data','Model Fit')
	%% plot frequency components
        ax = freq_ax;
		ax.Box = 'on';
		hold(ax,'on');
		for i=1:iter
			temp = plot(ax,[vib_arr(i,1),vib_arr(i+1,1)],[vib_arr(i,2),vib_arr(i+1,2)]);
			color_arr(i,:) = temp.Color;
		end
		for i=1:length(aux.stall_iter)
			plot(ax,vib_arr(aux.stall_iter(i)+1,1),vib_arr(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
		end
		plot(ax,vib_arr(iter+1,1),vib_arr(iter+1,2),'ko');
		xlim(ax,[p_init.w_01.bounds1,p_init.w_01.bounds2]);
		ylim(ax,[p_init.Anh.bounds1,p_init.Anh.bounds2]);
		xlabel(ax,'0-1 Transition (cm^{-1})');ylabel(ax,'Anharmonic Shift (cm^{-1})');title(ax,'Vibrational Frequencies');
		xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
    %% plot kubo components
        ax = kubo_ax;
		ax.Box = 'on';
		hold(ax,'on');
		if isfield(p_arr(1),'kubo1_t') && isfield(p_arr(1),'kubo1_D2')
			for i=1:iter
				plot(ax,[kubo_arr_1(i,1),kubo_arr_1(i+1,1)],[kubo_arr_1(i,2),kubo_arr_1(i+1,2)],'Color',color_arr(i,:));
			end
			for i=1:length(aux.stall_iter)
				plot(ax,kubo_arr_1(aux.stall_iter(i)+1,1),kubo_arr_1(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
			end
			plot(ax,kubo_arr_1(iter+1,1),kubo_arr_1(iter+1,2),'ko');
			text(ax,kubo_arr_1(iter+1,1),kubo_arr_1(iter+1,2),'  1');
			x_low(1) = p_init.kubo1_t.bounds1;
			x_high(1) = p_init.kubo1_t.bounds2;
			y_low(1) = p_init.kubo1_D2.bounds1;
			y_high(1) = p_init.kubo1_D2.bounds2;
		end
		if isfield(p_arr(1),'kubo2_t') && isfield(p_arr(1),'kubo2_D2')
			for i=1:iter
				plot(ax,[kubo_arr_2(i,1),kubo_arr_2(i+1,1)],[kubo_arr_2(i,2),kubo_arr_2(i+1,2)],'Color',color_arr(i,:));
			end
			for i=1:length(aux.stall_iter)
				plot(ax,kubo_arr_2(aux.stall_iter(i)+1,1),kubo_arr_2(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
			end
			plot(ax,kubo_arr_2(iter+1,1),kubo_arr_2(iter+1,2),'ko');
			text(ax,kubo_arr_2(iter+1,1),kubo_arr_2(iter+1,2),'  2');
			x_low(2) = p_init.kubo2_t.bounds1;
			x_high(2) = p_init.kubo2_t.bounds2;
			y_low(2) = p_init.kubo2_D2.bounds1;
			y_high(2) = p_init.kubo2_D2.bounds2;
		end
		if isfield(p_arr(1),'kubo3_t') && isfield(p_arr(1),'kubo3_D2')
			for i=1:iter
				plot(ax,[kubo_arr_3(i,1),kubo_arr_3(i+1,1)],[kubo_arr_3(i,2),kubo_arr_3(i+1,2)],'Color',color_arr(i,:));
			end
			for i=1:length(aux.stall_iter)
				plot(ax,kubo_arr_3(aux.stall_iter(i)+1,1),kubo_arr_3(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
			end
			plot(ax,kubo_arr_3(iter+1,1),kubo_arr_3(iter+1,2),'ko');
			text(ax,kubo_arr_3(iter+1,1),kubo_arr_3(iter+1,2),'  3');
			x_low(3) = p_init.kubo3_t.bounds1;
			x_high(3) = p_init.kubo3_t.bounds2;
			y_low(3) = p_init.kubo3_D2.bounds1;
			y_high(3) = p_init.kubo3_D2.bounds2;
		end
		xlim(ax,[min(x_low),max(x_high)]);
		ylim(ax,[min(y_low),max(y_high)]);
		ax.XScale = 'log';
		xlabel(ax,'\tau_c (ps)');ylabel(ax,'\Delta^2 (cm^{-1})^2');title(ax,'Kubo Components');
		xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
	%% plot inverse homogeneous components
		ax = hom_ax;
		ax.Box = 'on';
		hold(ax,'on');
		for i=1:iter
			plot(ax,[hom_arr(i,1),hom_arr(i+1,1)],[hom_arr(i,2),hom_arr(i+1,2)],'Color',color_arr(i,:));
		end
		for i=1:length(aux.stall_iter)
			plot(ax,hom_arr(aux.stall_iter(i)+1,1),hom_arr(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
		end
		plot(ax,hom_arr(iter+1,1),hom_arr(iter+1,2),'ko');
		xlim(ax,[p_init.T_hom_inv.bounds1,p_init.T_hom_inv.bounds2]);
		ylim(ax,[p_init.T_LT_inv.bounds1,p_init.T_LT_inv.bounds2]);
		xlabel(ax,'Inverse Hom. Lifetime (1/ps)');ylabel(ax,'Inverse Vib. Lifetime (1/ps)');title(ax,'Inverse Hom. and Vib. Lifetimes');
		xtickformat(ax,'%.2g');ytickformat(ax,'%.3g')
	%% plot amplitude components
		ax = amp_ax;
		ax.Box = 'on';
		hold(ax,'on');
		for i=1:iter
			plot(ax,[amp_arr(i,1),amp_arr(i+1,1)],[amp_arr(i,2),amp_arr(i+1,2)],'Color',color_arr(i,:));
		end
		for i=1:length(aux.stall_iter)
			plot(ax,amp_arr(aux.stall_iter(i)+1,1),amp_arr(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
		end
		plot(ax,amp_arr(iter+1,1),amp_arr(iter+1,2),'ko');
		xlim(ax,[p_init.A01.bounds1,p_init.A01.bounds2]);
		ylim(ax,[p_init.A12.bounds1,p_init.A12.bounds2]);
		xlabel(ax,'A_{01}');ylabel(ax,'A_{12}');title(ax,'Amplitudes');
		xtickformat(ax,'%.2g');ytickformat(ax,'%.3g')
		ax.XScale = 'log';ax.YScale = 'log';
    drawnow
end
