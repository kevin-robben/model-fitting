function x = gen_x(varargin)
%% Syntax:
%%      x = gen_x(w1_range,N1,w3_range,N3,Tw,num_type)
%%      x = gen_x(t1_range,N1,w1_shift,w3_range,N3,Tw,num_type)

%% translate inputs and calculate pump axis according to number of input variables
    if nargin == 6 % x = gen_x(w1_range,N1,w3_range,N3,Tw,num_type)
        %% capture input arguments
            w1_range = varargin{1};
            N1 = varargin{2};
            w3_range = varargin{3};
            N3 = varargin{4};
            Tw = varargin{5};
            num_type = varargin{6};
        %% compute pump axis
            dw1 = (w1_range(2) - w1_range(1))/(N1-1);
            w1 = w1_range(1) + (0:1:N1-1)*dw1;
            dt1 = 1/(0.03*dw1*2*N1); % factor of 2 accounts for negative half of axis (two-sided FFT)
            t1 = (0:1:N1-1)*dt1;
    elseif nargin == 7 % x = gen_x(t1_range,N1,w1_shift,w3_range,N3,Tw,num_type)
        %% capture input arguments
            t1_range = varargin{1};
            N1 = varargin{2};
            w1_shift = varargin{3};
            w3_range = varargin{4};
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
            dw1 = 1/(0.03*dt1*2*N1); % factor of 2 accounts for negative half of axis (two-sided FFT)
            w1 = w1_shift(1) + (0:1:N1-1)*dw1;
    else
        fprintf('\tERROR: syntax not defined for number of input arguments\n');
    end
    if ~(strcmp(num_type,'complex') || strcmp(num_type,'real'))
        fprintf('\tERROR: num_type must be either ''real'' or ''complex''\n')
    end
%% compute probe axis
    dw3 = (w3_range(2) - w3_range(1))/(N3-1);
    w3 = w3_range(1) + (0:1:N3-1)*dw3;
    dt3 = 1/(0.03*dw3*2*N3); % factor of 2 accounts for negative half of axis (two-sided FFT)
    t3 = (0:1:N3-1)*dt3;
%% generate 3D time axes and write all axes to the x struct
    x.('t1')        = reshape( t1 , [N1,1,1] );
    x.('Tw')        = reshape( Tw , [1,N3,1] );
    x.('t3')        = reshape( t3 , [1,1,N2] );
    x.('w1')        = w1;
    x.('w3')        = w3;
    x.('N1')        = N1;
    x.('N3')        = N3;
    x.('N2')        = numel(Tw);
    x.('numel')     = N1*N3*numel(Tw);
    x.('num_type')  = num_type;
end