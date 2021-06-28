%% Homogeneous lineshape function for the 0-1 transition which includes the vibrational lifetime contribution and non-vibrational lifetime contributions (i.e. pure dephasing and orientational correlation time)
    function gt = exp_g_hom_01(t1,Tw,t3,T_LT_inv,T_hom_inv)
        gt = exp(-T_LT_inv*Tw).*exp(-T_hom_inv*t1).*exp(-T_hom_inv*t3);
    end