%% Ground State Bleach
    function R = GB(p,w1_shift,w3_shift,t1,Tw,t3,r_nr)
        R = p.A01.val*exp(+1i*2*pi*0.03*(t3.*(p.v_01.val-w3_shift)+r_nr*t1.*(p.v_01.val-w1_shift+p.cal_err.val))).*exp_g_hom_01(t1,Tw,t3,p.T_LT_inv.val,p.T_hom_inv.val);
        if isfield(p,'kubo1_t') && isfield(p,'kubo1_D2')
            R = R.*exp_g_kubo(t1,Tw,t3,p.kubo1_t.val,p.kubo1_D2.val,r_nr,1);
        end
        if isfield(p,'kubo2_t') && isfield(p,'kubo2_D2')
            R = R.*exp_g_kubo(t1,Tw,t3,p.kubo2_t.val,p.kubo2_D2.val,r_nr,1);
        end
        if isfield(p,'kubo3_t') && isfield(p,'kubo3_D2')
            R = R.*exp_g_kubo(t1,Tw,t3,p.kubo3_t.val,p.kubo3_D2.val,r_nr,1);
        end
    end