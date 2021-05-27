function x = gen_x(varargin)
%% Syntax:
%%      x = gen_x(v1_range,N1,v3_range,N3,Tw,num_type)
%%      x = gen_x(t1_range,N1,v1_shift,v3_range,N3,Tw,num_type)

%% translate inputs and calculate pump axis according to number of input variables
    if nargin == 6 % x = gen_x(v1_range,N1,v3_range,N3,Tw,num_type)
        %% capture input arguments
            v1_range = varargin{1};
            N1 = varargin{2};
            v3_range = varargin{3};
            N3 = varargin{4};
            Tw = varargin{5};
            num_type = varargin{6};
        %% compute pump axis
            dv1 = (v1_range(2) - v1_range(1))/(N1-1);
            v1 = v1_range(1) + (0:1:N1-1)*dv1;
            dt1 = 1/(0.03*dv1*2*N1); % factor of 2 accounts for negative half of axis (two-sided FFT)
            t1 = (0:1:N1-1)*dt1;
    elseif nargin == 7 % x = gen_x(t1_range,N1,v1_shift,v3_range,N3,Tw,num_type)
        %% capture input arguments
            t1_range = varargin{1};
            N1 = varargin{2};
            v1_shift = varargin{3};
            v3_range = varargin{4};
            N3 = varargin{5};
            Tw = varargin{6};
            num_type = varargin{7};
        %% compute pump axis
            if t1_range(1) ~= 0
                fprintf('\tERROR: Lower bound input of t1 axis does not equal zero. Overwriting to make it equal to zero.\n');
            end
            if t1_range(2) <= 0
                fprintf('\tERROR: Upper bound input of t1 axis is less than zero. This may cause errors.\n');
            end
            dt1 = t1_range(2)/(N1-1);
            t1 = (0:1:N1-1)*dt1;
            dv1 = 1/(0.03*dt1*2*N1); % factor of 2 accounts for negative half of axis (two-sided FFT)
            v1 = v1_shift(1) + (0:1:N1-1)*dv1;
    else
        fprintf('\tERROR: syntax not defined for number of input arguments\n');
    end
    if ~(strcmp(num_type,'complex') || strcmp(num_type,'real'))
        fprintf('\tERROR: num_type must be either ''real'' or ''complex''\n')
    end
%% compute probe axis
    dv3 = (v3_range(2) - v3_range(1))/(N3-1);
    v3 = v3_range(1) + (0:1:N3-1)*dv3;
    dt3 = 1/(0.03*dv3*2*N3); % factor of 2 accounts for negative half of axis (two-sided FFT)
    t3 = (0:1:N3-1)*dt3;
%% generate 3D time axes and write all axes to the x struct
    [t3_3D,t1_3D,Tw_3D] = meshgrid(t3,t1,Tw);
    x.('t1')        = t1;
    x.('Tw')        = Tw;
    x.('t3')        = t3;
    x.('v1')        = v1;
    x.('v3')        = v3;
    x.('t1_3D')     = t1_3D;
    x.('Tw_3D')     = Tw_3D;
    x.('t3_3D')     = t3_3D;
    x.('N1')        = N1;
    x.('N3')        = N3;
    x.('N2')        = numel(Tw);
    x.('numel')     = N1*N3*numel(Tw);
    x.('num_type')  = num_type;
%% print summary
%     fprintf('\tt1: [%.5g,%.5g] ps with %.5g ps steps\n',x.t1(1),x.t1(N1),dt1)
%     fprintf('\tv1: [%.5g,%.5g] cm-1 with %.5g cm-1 steps\n',x.v1(1),x.v1(N1),dv1)
%     fprintf('\tt3: [%.5g,%.5g] ps with %.5g ps steps\n',x.t3(1),x.t3(N3),dt3)
%     fprintf('\tv3: [%.5g,%.5g] cm-1 with %.5g cm-1 steps\n',x.v3(1),x.v3(N3),dv3)
end