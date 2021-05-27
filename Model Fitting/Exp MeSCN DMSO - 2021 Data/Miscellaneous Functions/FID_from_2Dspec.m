%% ifft frequency-frequency spectrum to time-frequency spectrum
function varargout = FID_from_2Dspec(varargin)
%% Syntax:  
%%	FID = FID_from_2Dspec(spec)
%%	[FID,x_trunc] = FID_from_2Dspec(spec,x,t1_trunc)
	if nargin == 1
        spec = varargin{1};
	elseif nargin == 3
		spec = varargin{1};
		x = varargin{2};
		t1_trunc = round(varargin{3});
		N1 = size(spec,1);
		N3 = size(spec,2);
        dv1 = (x.v1(N1)-x.v1(1))/(N1-1);
		dt1 = 1/(0.03*dv1*2*N1); % factor of 2 accounts for negative half of axis (two-sided FFT)
		t1 = (0:1:N1-1)*dt1;
        n1_trunc = nearest_index(t1,t1_trunc);
		x_trunc = gen_x([0,t1(n1_trunc)],n1_trunc,x.v1(1),[x.v3(1),x.v3(N3)],N3,x.Tw,'complex');
		[apo_mask,inv_apo_mask] = apo_masks(x_trunc);
	else
        fprintf('\tERROR: syntax not defined for number of in arguments\n');
	end
	N1 = size(spec,1);
    FID = ifft(spec,2*N1,1)*sqrt(N1);
	if nargin == 1
		FID = FID(1:N1,:,:);
	elseif nargin == 3
		FID = FID(1:x_trunc.N1,:,:).*inv_apo_mask;
	end
% 	FID(1,:,:) = 2*FID(1,:,:); % if first element of FID was divided by 2 prior to FFT, uncomment this line
    %% determine outputs
    if nargout == 1
        varargout{1} = FID;
    elseif nargout == 2
        varargout{1} = FID;
        varargout{2} = x_trunc;
    else
        fprintf('\tERROR: syntax not defined for number of output arguments\n');
    end
end
    
