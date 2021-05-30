%% 1st order FID: pure dephasing + 2-component kubo model
    function lin_spec = M_1st_order_kubo(x,p)
        FID = (1e7)*GB(p,0,x.w3(1),0,0,x.t3,0); % generate complex-valued FID
        FID(1) = FID(1)/2; %prepare for FFT
        lin_spec = fft(FID,2*x.N3); %two-sided complex-valued FFT
        lin_spec = real(lin_spec(1:x.N3)); %discard negative frequency half
    end