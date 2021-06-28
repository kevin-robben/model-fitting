%% Homogeneous lineshape function for the 1-2 transition which includes the vibrational lifetime contribution and non-vibrational lifetime contributions (i.e. pure dephasing and orientational correlation time)
    function gt = exp_g_hom_12(t1,Tw,t3,T_LT_inv,T_hom_inv)
        % assumes dephasing mode1: 1/T2(12) = 1/T2(01) during t1, and 1/T2(12) = 1/T2(01) + 1/T1 during t3
        gt = exp(-T_LT_inv*Tw).*exp(-T_hom_inv*t1).*exp(-(T_hom_inv+T_LT_inv)*t3);
    end