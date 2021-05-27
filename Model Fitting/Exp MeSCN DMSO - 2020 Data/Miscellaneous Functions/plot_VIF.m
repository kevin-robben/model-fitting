function cond_num = plot_VIF(ax,x,p,w,aux)
	%% compute JwJ
% 		[JwJ,dC] = ILS_JwJ_dC(x,p,M_3rd_order_kubo(x,p),w,aux);
	%% center and normalize JwJ
		f = @(x,p) M_3rd_order_kubo(x,p);
		J = Jacobian_f(f,x,p,aux).*reshape(w,[x.numel,1]);
		J_centered = J - repmat(mean(J,1),[x.numel,1]);
		JJ = real(J_centered'*J_centered);
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
		plot(ax,(0:aux.num_var+1),10*ones(size(0:aux.num_var+1)),'k--')
		set(ax,'xtick',ax_ticks,'xticklabels',param_labels)
		xlim(ax,[0,aux.num_var+1])
		ylabel('Variance Inflation Factor (VIF)')
end
