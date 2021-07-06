function plot_2DFID(varargin)
%% Syntax:  
%%      plot_FID(ax,x,FID)
%%      plot_FID(ax,x,t1_lim,w3_lim,FID)
%%      plot_FID(ax,x,t1_lim,w3_lim,FID,title_str)
    if nargin == 3
        ax = varargin{1};
        x = varargin{2};
		t1_lim = [x.t1(1),x.t1(x.N1)];
		w3_lim = [x.w3(1),x.w3(x.N3)];
        FID = varargin{3};
        title_str = 'Default Title';
    elseif nargin == 5
        ax = varargin{1};
        x = varargin{2};
		t1_lim = varargin{3};
		w3_lim = varargin{4};
        FID = varargin{5};
        title_str = 'Default Title';
    elseif nargin == 6
        ax = varargin{1};
        x = varargin{2};
		t1_lim = varargin{3};
		w3_lim = varargin{4};
        FID = varargin{5};
        title_str = varargin{6};
    else
        fprintf('\tERROR: syntax not defined for number of input arguments\n');
    end
    if isempty(t1_lim)
        t1_lim = [x.t1(1),x.t1(x.N1)];
    end
    if isempty(w3_lim)
        w3_lim = [x.w3(1),x.w3(x.N3)];
    end
%% plot FID
    if numel(size(FID)) > 2
        fprintf('\tERROR: plot_FID cannot plot 3D data\n');
    else
        contourf(ax,x.t1,x.w3,real(FID)',20);colorbar(ax);
        xlabel(ax,'\tau_1 (ps)');ylabel(ax,'\omega_3 (cm^{-1})');
        xlim(ax,t1_lim);ylim(ax,w3_lim);
        title(ax,title_str);
        drawnow
    end
end
