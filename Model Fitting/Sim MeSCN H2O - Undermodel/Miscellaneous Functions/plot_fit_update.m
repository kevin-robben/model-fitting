%% print parameters
function plot_fit_update(fig,p_init,p_arr,C_arr,SIGN_arr,SIGN_lim,iter,D,x,trial_num,aux,timerval,v3_plot_lim)
	%% include p_init in p_arr array *** note that this pushes p_arr(i) --> p_arr(i+1), however, p_arr(i) still corresponds to C_arr(i) and SIGN(i)***
		p_arr = [p_init,p_arr];
	%% gather arrays to plot later on
		for i=1:iter+1
			vib_arr(i,:) = [p_arr(i).v_01.val,p_arr(i).Anh.val];
			hom_arr(i,:) = [p_arr(i).T_hom_inv.val,p_arr(i).T_LT_inv.val];
			if isfield(p_arr(1),'kubo1_t') && isfield(p_arr(1),'kubo1_D2')
				kubo_arr_1(i,:) = [p_arr(i).kubo1_t.val,p_arr(i).kubo1_D2.val];
			end
			if isfield(p_arr(1),'kubo2_t') && isfield(p_arr(1),'kubo2_D2')
				kubo_arr_2(i,:) = [p_arr(i).kubo2_t.val,p_arr(i).kubo2_D2.val];
			end
			if isfield(p_arr(1),'kubo3_t') && isfield(p_arr(1),'kubo3_D2')
				kubo_arr_3(i,:) = [p_arr(i).kubo3_t.val,p_arr(i).kubo3_D2.val];
			end
		end
	%% initialize layout, title
		t = tiledlayout(fig,2,3,'TileSpacing','Compact','Padding','Compact');
		s = seconds(toc(timerval));s.Format = 'hh:mm:ss';
		if aux.stall > 0
			title(t,sprintf('Trial %i, Iteration %i (Time: %s)\nFitting Stalled. Randomizing Fit Parameters...',trial_num,iter,s))
		else
			title(t,sprintf('Trial %i, Iteration %i (Time: %s)\n',trial_num,iter,s))
		end
    %% plot the cost function
        ax = nexttile(t,1);
            ax.Box = 'on';
			hold(ax,'on');
            plot(ax,1:iter,C_arr(1:iter),'k.-')
			set(ax,'YMinorTick','on','YScale','log');
            ylim(ax,[0.9*min(C_arr(1:iter)),1.1*max(C_arr(1:iter))]);
            xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
            ylabel(ax,'C');xlabel(ax,'Iteration');title(ax,'Cost Function');
    %% plot the scale invariant gradient norm (SIGN)
        ax = nexttile(t,4);
            ax.Box = 'on';
			hold(ax,'on');
            plot(ax,1:iter,SIGN_arr(1:iter),'k.-');
			plot(ax,1:iter,ones(1,iter)*SIGN_lim,'--','Color',[0.5,0.5,0.5]);
			set(ax,'YMinorTick','on','YScale','log');
            xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
            xlabel(ax,'Iteration');ylabel(ax,'$$\widetilde{|\nabla{C}|}$$','Interpreter','LaTeX');title(ax,'Scale Invariant Gradient Norm (SIGN)');
    %% plot frequency components
        ax = nexttile(t,2);
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
			xlabel(ax,'0-1 Transition (cm^{-1})');ylabel(ax,'Anharmonic Shift (cm^{-1})');title(ax,'Vibrational Frequencies');
			xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
    %% plot inverse homogeneous components
        ax = nexttile(t,5);
            ax.Box = 'on';
			hold(ax,'on');
			for i=1:iter
                plot(ax,[hom_arr(i,1),hom_arr(i+1,1)],[hom_arr(i,2),hom_arr(i+1,2)],'Color',color_arr(i,:));
			end
			for i=1:length(aux.stall_iter)
				plot(ax,hom_arr(aux.stall_iter(i)+1,1),hom_arr(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
			end
			plot(ax,hom_arr(iter+1,1),hom_arr(iter+1,2),'ko');
            xlabel(ax,'Inverse Hom. Lifetime (1/ps)');ylabel(ax,'Inverse Vib. Lifetime (1/ps)');title(ax,'Inverse Hom. and Vib. Lifetimes');
            xtickformat(ax,'%.2g');ytickformat(ax,'%.3g')
    %% plot kubo components
        ax = nexttile(t,3);
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
			end
			if isfield(p_arr(1),'kubo2_t') && isfield(p_arr(1),'kubo2_D2')
				for i=1:iter
					plot(ax,[kubo_arr_2(i,1),kubo_arr_2(i+1,1)],[kubo_arr_2(i,2),kubo_arr_2(i+1,2)],'Color',color_arr(i,:));
				end
				for i=1:length(aux.stall_iter)
					plot(ax,kubo_arr_2(aux.stall_iter(i)+1,1),kubo_arr_2(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
				end
				plot(ax,kubo_arr_2(iter+1,1),kubo_arr_2(iter+1,2),'ko');
			end
			if isfield(p_arr(1),'kubo3_t') && isfield(p_arr(1),'kubo3_D2')
				for i=1:iter
					plot(ax,[kubo_arr_3(i,1),kubo_arr_3(i+1,1)],[kubo_arr_3(i,2),kubo_arr_3(i+1,2)],'Color',color_arr(i,:));
				end
				for i=1:length(aux.stall_iter)
					plot(ax,kubo_arr_3(aux.stall_iter(i)+1,1),kubo_arr_3(aux.stall_iter(i)+1,2),'r^','MarkerSize',4,'MarkerFaceColor','r');
				end
				plot(ax,kubo_arr_3(iter+1,1),kubo_arr_3(iter+1,2),'ko');
			end
            xlabel(ax,'\tau_c (ps)');ylabel(ax,'\Delta^2 (cm^{-1})^2');title(ax,'Kubo Components');
            xtickformat(ax,'%.2g');ytickformat(ax,'%.2g')
    %% plot fit comparison
        ax = nexttile(t,6);
			ax.Box = 'on';
			M = ILS_M(x,p_arr(iter+1));
			plot(ax,x.v3,real(D(1,:,1)),'k-',x.v3,real(M(1,:,1)),'r-')
			xlim(ax,v3_plot_lim);
            xlabel(ax,'\nu_3 (cm^{-1})');ylabel(ax,'\DeltaOD');title(ax,'Fit Comparison');
            xtickformat(ax,'%0.0g');ytickformat(ax,'%0.0g')
            legend(ax,'Data','Model Fit')
    drawnow
end
