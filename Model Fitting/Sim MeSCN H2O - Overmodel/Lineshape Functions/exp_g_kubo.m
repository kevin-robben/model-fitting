%% Kubo lineshape function (i.e. FFCF integrated twice): kubo model
    function gt = exp_g_kubo(t1,Tw,t3,tc,Dw2,r_nr,anh_fctr)
        c = 0.03; %cm/ps
        if (tc > 0)
            tbwp = (2*pi*c)^2*Dw2*tc^2;
            % r_nr = +1 for nonrephasing, -1 for rephasing, 0 for uncorrelated
            gt = exp(-tbwp*(expm1(-t1/tc)+t1/tc)).*exp(-tbwp*(anh_fctr^2)*(expm1(-t3/tc)+t3/tc)).*exp(-r_nr*tbwp*anh_fctr*exp(-Tw/tc).*expm1(-t1/tc).*expm1(-t3/tc));
        else
            gt = zeros(size(t3));
        end
    end