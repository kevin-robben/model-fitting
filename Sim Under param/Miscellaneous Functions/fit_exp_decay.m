function fit_obj = fit_exp_decay(varargin)
%% syntax
%% fit_obj = fit_exp_decay(x,y,[A1,tau1])
%% fit_obj = fit_exp_decay(x,y,[A1,A2,tau1])
%% fit_obj = fit_exp_decay(x,y,[A1,A2,tau1,tau2])
%% fit_obj = fit_exp_decay(x,y,[A1,A2,A3,tau1,tau2])
%% fit_obj = fit_exp_decay(x,y,___,lower_lim,upper_lim)
%% determine type of algorithm and number of components
	if nargin == 3
		guess = varargin{3};
		if length(guess) == 2
			fit_type = fittype('A1*exp(-x/tau1)');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2)]);
		elseif length(guess) == 3
			fit_type = fittype('A1*exp(-x/tau1)+A2');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2),guess(3)]);
		elseif length(guess) == 4
			fit_type = fittype('A1*exp(-x/tau1)+A2*exp(-x/tau2)');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2),guess(3),guess(4)]);
		elseif length(guess) == 5
			fit_type = fittype('A1*exp(-x/tau1)+A2*exp(-x/tau2)+A3');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Levenberg-Marquardt','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2),guess(3),guess(4),guess(5)]);
		end
	elseif nargin == 5
		guess = varargin{3};
		lower = varargin{4};
		upper = varargin{5};
		if length(guess) == 2
			fit_type = fittype('A1*exp(-x/tau1)');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Trust-Region','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2)]);
			fit_options = fitoptions(fit_options,'Lower',[lower(1),lower(2)]);
			fit_options = fitoptions(fit_options,'Upper',[upper(1),upper(2)]);
		elseif length(guess) == 3
			fit_type = fittype('A1*exp(-x/tau1)+A2');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Trust-Region','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2),guess(3)]);
			fit_options = fitoptions(fit_options,'Lower',[lower(1),lower(2),lower(3)]);
			fit_options = fitoptions(fit_options,'Upper',[upper(1),upper(2),upper(3)]);
		elseif length(guess) == 4
			fit_type = fittype('A1*exp(-x/tau1)+A2*exp(-x/tau2)');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Trust-Region','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2),guess(3),guess(4)]);
			fit_options = fitoptions(fit_options,'Lower',[lower(1),lower(2),lower(3),lower(4)]);
			fit_options = fitoptions(fit_options,'Upper',[upper(1),upper(2),upper(3),upper(4)]);
		elseif length(guess) == 5
			fit_type = fittype('A1*exp(-x/tau1)+A2*exp(-x/tau2)+A3');
			fit_options = fitoptions(fit_type);
			fit_options = fitoptions(fit_options,'Algorithm','Trust-Region','TolX',1e-10,'TolFun',1e-10);
			fit_options = fitoptions(fit_options,'StartPoint',[guess(1),guess(2),guess(3),guess(4),guess(5)]);
			fit_options = fitoptions(fit_options,'Lower',[lower(1),lower(2),lower(3),lower(4),lower(5)]);
			fit_options = fitoptions(fit_options,'Upper',[upper(1),upper(2),upper(3),upper(4),upper(5)]);
		end
	end
%% check that x and y are column vectors
	x = varargin{1};
	y = varargin{2};
	if size(x,1) == 1
		x = transpose(x);
	end
	if size(y,1) == 1
		y = transpose(y);
	end
%% fit model
	[fit_obj,gof,output] = fit(x,y,fit_type,fit_options);
end