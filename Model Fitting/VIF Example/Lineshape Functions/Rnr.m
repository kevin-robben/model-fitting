%% Nonrephasing
    function R = Rnr(x,p)
        R = EA(p,x.v1(1),x.v3(1),x.t1_3D,x.Tw_3D,x.t3_3D,+1) - GB(p,x.v1(1),x.v3(1),x.t1_3D,x.Tw_3D,x.t3_3D,+1);
        R(:,1,:) = R(:,1,:)/2; % this is preparing for the t3->v3 FFT
    end