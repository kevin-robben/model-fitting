function cond_num = plot_VIF(ax,x,p,w,aux)
	%% center and normalize JwJ
		f = @(x,p) M_3rd_order_kubo(x,p);
		J = Jacobian_f(f,x,p,aux).*reshape(w,[x.numel,1]);
		JJ = real(J'*J);
		JJ_norm = JJ ./ sqrt( diag(JJ) * diag(JJ)' );
		VIF = diag(inv(JJ_norm));
	%% compute condition number
		s = svd(JJ_norm);
		cond_num = (max(s)/min(s))^(1/2);
	%% compute and plot VIF
		semilogy(ax,1:numel(VIF),VIF,'k.','MarkerSize',12)
		fn = fieldnames(p);
		for i=1:aux.num_var
			param_labels{i} = p.(fn{aux.var_indx(i)}).label;
			ax_ticks(i) = i;
		end
		hold(ax,'on');
		set(ax,'xtick',ax_ticks,'xticklabels',param_labels)
		ax.XLim(1) = 1;
		xlim(ax,[0.5,aux.num_var+0.5])
		ylabel('VIF')
end
