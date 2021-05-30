function plot_2Dspec(varargin)
%% Syntax:  
%%      plot_2Dspec(ax,x,spec)
%%		plot_2Dspec(ax,x,w1_lim,w3_lim,spec)
%%      plot_2Dspec(ax,x,w1_lim,w3_lim,spec,title_str)
    if nargin == 3
		ax = varargin{1};
        x = varargin{2};
		w1_lim = [x.w1(1),x.w1(x.N1)];
		w3_lim = [x.w3(1),x.w3(x.N3)];
        spec = varargin{3};
        title_str = 'Default Title';
	elseif nargin == 5
		ax = varargin{1};
        x = varargin{2};
		w1_lim = varargin{3};
		w3_lim = varargin{4};
        spec = varargin{5};
        title_str = 'Default Title';
    elseif nargin == 6
		ax = varargin{1};
        x = varargin{2};
		w1_lim = varargin{3};
		w3_lim = varargin{4};
        spec = varargin{5};
        title_str = varargin{6};
    else
        fprintf('\tERROR in plot_2Dspec: syntax not defined for number of input arguments\n');
    end
    if isempty(w1_lim)
        w1_lim = [x.w1(1),x.w1(x.N1)];
    end
    if isempty(w3_lim)
        w3_lim = [x.w3(1),x.w3(x.N3)];
    end
%% plot 2D spectrum
    if numel(size(spec)) > 2
        fprintf('\tERROR: plot_2Dspec cannot plot 3D data\n');
    else
        contourf(ax,x.w1,x.w3,spec',40);colorbar;
        hold on;line(ax,[0,1e4],[0,1e4],'Color','k','LineStyle','-');hold off;
        xlabel(ax,'Pump (cm^{-1})');ylabel(ax,'Probe (cm^{-1})');
		xlim(ax,w1_lim);ylim(ax,w3_lim);
        title(ax,title_str);
		ax.DataAspectRatio = [1,1,1];
        drawnow
    end
end
