function plot_2Dspec(varargin)
%% Syntax:  
%%      plot_2Dspec(ax,x,spec)
%%		plot_2Dspec(ax,x,v1_lim,v3_lim,spec)
%%      plot_2Dspec(ax,x,v1_lim,v3_lim,spec,title_str)
    if nargin == 3
		ax = varargin{1};
        x = varargin{2};
		v1_lim = [x.v1(1),x.v1(x.N1)];
		v3_lim = [x.v3(1),x.v3(x.N3)];
        spec = varargin{3};
        title_str = 'Default Title';
	elseif nargin == 5
		ax = varargin{1};
        x = varargin{2};
		v1_lim = varargin{3};
		v3_lim = varargin{4};
        spec = varargin{5};
        title_str = 'Default Title';
    elseif nargin == 6
		ax = varargin{1};
        x = varargin{2};
		v1_lim = varargin{3};
		v3_lim = varargin{4};
        spec = varargin{5};
        title_str = varargin{6};
    else
        fprintf('\tERROR in plot_2Dspec: syntax not defined for number of input arguments\n');
    end
    if isempty(v1_lim)
        v1_lim = [x.v1(1),x.v1(x.N1)];
    end
    if isempty(v3_lim)
        v3_lim = [x.v3(1),x.v3(x.N3)];
    end
%% plot 2D spectrum
    if numel(size(spec)) > 2
        fprintf('\tERROR: plot_2Dspec cannot plot 3D data\n');
    else
        contourf(ax,x.v1,x.v3,spec',40);colorbar;
        hold on;line(ax,[0,1e4],[0,1e4],'Color','k','LineStyle','-');hold off;
        xlabel('\nu_1 (cm^{-1})');ylabel('\nu_3 (cm^{-1})');
		xlim(ax,v1_lim);ylim(ax,v3_lim);
        title(ax,title_str);
		ax.DataAspectRatio = [1,1,1];
        drawnow
    end
end
