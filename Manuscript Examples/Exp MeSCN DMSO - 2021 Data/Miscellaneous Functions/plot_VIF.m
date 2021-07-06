function cond_num = plot_VIF(varargin)
%% Syntax:  
%%              cond_num = plot_VIF(x,p)
%%              cond_num = plot_VIF(x,p,w)
%%              cond_num = plot_VIF(ax,x,p)
%%              cond_num = plot_VIF(ax,x,p,w)
	%% initialize inputs
		if nargin == 2
			x = varargin{1};
			p = varargin{2};
			f = figure;set(f,'Position',[100,100,300,250]);
			ax = axes(f);
			w = ones(x.N1,x.N3,x.N2);
			fprintf('Warning: No weights input given. Assuming uniform weights.\n');
		elseif nargin == 3
			if isa(varargin{1},'matlab.graphics.axis.Axes')
				ax = varargin{1};
				x = varargin{2};
				p = varargin{3};
				w = ones(x.N1,x.N3,x.N2);
				fprintf('Warning: No weights input given. Assuming uniform weights.\n');
			else
				x = varargin{1};
				p = varargin{2};
				w = varargin{3};
				f = figure;set(f,'Position',[100,100,300,250]);
				ax = axes(f);
			end
		elseif nargin == 4
			ax = varargin{1};
			x = varargin{2};
			p = varargin{3};
			w = varargin{4};
		else
			fprintf('\tERROR: syntax not defined for number of in arguments\n');
		end
	%% initialize aux
		aux = ILS_initialize_aux(p);
	%% center and normalize JwJ
		f = @(x,p) M_3rd_order_kubo(x,p);
		J = Jacobian_f(f,x,p,aux);
		Jw = J.*reshape(w,[x.numel,1]);
		JwJ = real(Jw'*J);
		JwJ_norm = JwJ ./ sqrt( diag(JwJ) * diag(JwJ)' );
		if any(isnan(JwJ_norm),'all') || any(isinf(JwJ_norm),'all') || cond(JwJ_norm) > 1e10
			VIF = 1e10*(ones(aux.num_var,1));
			cond_num = 1e10;
		else
			VIF = diag(inv(JwJ_norm));
			s = svd(JwJ_norm);
			cond_num = (max(s)/min(s))^(1/2);
		end
	%% compute and plot VIF
		semilogy(ax,1:numel(VIF),VIF,'k.','MarkerSize',12)
		fn = fieldnames(p);
		for i=1:aux.num_var
			param_labels{i} = p.(fn{aux.var_indx(i)}).label;
			ax_ticks(i) = i;
		end
		hold(ax,'on');
		xticks(ax,ax_ticks);
		xticklabels(ax,param_labels);
		set(ax,'TickLength',[0.025,0]);
		ax.XLim(1) = 1;
		xlim(ax,[0.5,aux.num_var+0.5])
		ylabel(ax,'VIF')
end
