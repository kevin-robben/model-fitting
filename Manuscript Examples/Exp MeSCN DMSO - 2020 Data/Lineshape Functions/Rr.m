%% Rephasing
    function R = Rr(x,p)
        R = EA(p,x.w1(1),x.w3(1),x.t1,x.Tw,x.t3,-1) - GB(p,x.w1(1),x.w3(1),x.t1,x.Tw,x.t3,-1);
        R(:,1,:) = R(:,1,:)/2; % this is preparing for the t3->w3 FFT
    end