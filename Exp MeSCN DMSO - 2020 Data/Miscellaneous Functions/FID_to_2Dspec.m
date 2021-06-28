%% fft time-frequency spectrum to frequency-frequency spectrum
function varargout = FID_to_2Dspec(varargin)
%% Syntax:  
%%              spec = FID_to_2Dspec(FID)
%%      [spec,x_apo] = FID_to_2Dspec(FID,x,zero_pad_fctr)
    if nargin == 1
        FID = varargin{1};
        zero_pad_fctr = 1;
    elseif nargin == 3 % apodize and zero pad by factor of apo_fctr (1 = no zero padding and no apodization)
        FID = varargin{1};
        x = varargin{2};
        zero_pad_fctr = round(varargin{3});
        dt1 = x.t1(2)-x.t1(1);
		x_apo = gen_x([x.t1(1),(x.N1*zero_pad_fctr-1)*dt1],x.N1*zero_pad_fctr,x.w1(1),[x.w3(1),x.w3(x.N3)],x.N3,x.Tw,x.num_type);
        [apo_mask,inv_apo_mask] = apo_masks(x);
        FID = FID.*apo_mask;
    else
        fprintf('\tERROR: syntax not defined for number of in arguments\n');
    end
    FID(1,:,:) = FID(1,:,:)/2;
    N1 = size(FID,1);
    spec = real(fft(FID,2*N1*zero_pad_fctr,1))/sqrt(N1);
    spec = spec(1:N1*zero_pad_fctr,:,:);
    %% determine outputs
    if nargout == 1
        varargout{1} = spec;
    elseif nargout == 2
        varargout{1} = spec;
        varargout{2} = x_apo;
    else
        fprintf('\tERROR: syntax not defined for number of output arguments\n');
    end
end
    
