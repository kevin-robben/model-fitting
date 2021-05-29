function [CL_w3, w1_axis, CLS] = trace_CL(w1,w1_range,w3,w3_range,spec,peak_model)
    %% gather indicies of min and max fitting range of along pump and probe axes
        [n1_min,n1_max] = nearest_index(w1,w1_range);
        [n3_min,n3_max] = nearest_index(w3,w3_range);
    %% trim down axes and spectra to fitting range
        w1_axis = w1(n1_min:n1_max);
        w3_axis = w3(n3_min:n3_max);
        spec1 = spec(n1_min:n1_max,n3_min:n3_max);
        CL_w3 = zeros(size(w1_axis)); %initialize center line array
    %% initialize options for peak fitting the center line
        switch peak_model
            case 'Asymmetric Lorentzian'
                fit_type = fittype('a/(1+((x-b)/c)^2)+d*(x-b)');
            case 'Symmetric Lorentzian'
                fit_type = fittype('a/(1+((x-b)/c)^2)+z');
            otherwise
                fprintf('Error: center line peak fitting model undefined\n')
                return
        end
        fit_options = fitoptions(fit_type);
        fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-10,'TolFun',1e-10);
    %% for loop over each probe slice
        for i=1:numel(w1_axis)
            [amp_guess,indx_guess] = min(spec1(i,:));
            switch peak_model
                case 'Asymmetric Lorentzian'
                    %% define initial guess and fit peak
                        fit_options = fitoptions(fit_options,'StartPoint',[amp_guess,w3_axis(indx_guess),6,0]);
                        [f1,gof,output] = fit(w3_axis',spec1(i,:)',fit_type,fit_options);
                    %% numerical peak search
                        x = w3_axis(1):1e-3:w3_axis(numel(w3_axis));
                        y = (f1.a)./(1+(x-f1.b).^2/(f1.c)^2)+f1.d*(x-f1.b);
                        [M,I] = min(y);
                    %% refine numeric peak search
                        x = (x(I(1))-(1e-3)):1e-6:(x(I(1))+(1e-3));
                        y = (f1.a)./(1+(x-f1.b).^2/(f1.c)^2)+f1.d*(x-f1.b);
                        [M,I] = min(y);
                    %% save to center line
                        CL_w3(i) = x(I(1));
                case 'Symmetric Lorentzian'
                    %% define initial guess and fit peak
                        fit_options = fitoptions(fit_options,'StartPoint',[amp_guess,w3_axis(indx_guess),6,0]);
                        [f1,gof,output] = fit(w3_axis',spec1(i,:)',fit_type,fit_options);
                    %% save to center line
                        CL_w3(i) = f1.b;
            end
        end
    %% calculate CLS from center line
        CLS = sum((w1_axis-mean(w1_axis)).*(CL_w3-mean(CL_w3)))/sum((w1_axis-mean(w1_axis)).^2);
end

