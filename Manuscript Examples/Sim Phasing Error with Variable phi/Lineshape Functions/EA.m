%% Excited State Absorption
    function R = EA(p,w1_shift,w3_shift,t1,Tw,t3,r_nr)
        R = p.A12.val*exp(+1i*2*pi*0.03*(t3.*(p.w_01.val-p.Anh.val-w3_shift)+r_nr*t1.*(p.w_01.val-w1_shift+p.cal_err.val))).*exp_g_hom_12(t1,Tw,t3,p.T_LT_inv.val,p.T_hom_inv.val);
        if isfield(p,'kubo1_t') && isfield(p,'kubo1_D2')
            R = R.*exp_g_kubo(t1,Tw,t3,p.kubo1_t.val,p.kubo1_D2.val,r_nr,p.kubo_anh_fctr.val);
        end
        if isfield(p,'kubo2_t') && isfield(p,'kubo2_D2')
            R = R.*exp_g_kubo(t1,Tw,t3,p.kubo2_t.val,p.kubo2_D2.val,r_nr,p.kubo_anh_fctr.val);
        end
        if isfield(p,'kubo3_t') && isfield(p,'kubo3_D2')
            R = R.*exp_g_kubo(t1,Tw,t3,p.kubo3_t.val,p.kubo3_D2.val,r_nr,p.kubo_anh_fctr.val);
        end
    end