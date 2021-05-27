function [apo_mask,inv_apo_mask] = apo_masks(x)
	%% define regular apo mask
		apo_t1 = reshape(ones(size(x.t1)),[x.N1,1,1]);
		apo_Tw = reshape(ones(size(x.Tw)),[1,1,x.N2]);
		apo_v3 = reshape(ones(size(x.v3)),[1,x.N3,1]);
		apo_start = 2.0;
		apo_end = 3.95;
		for i=1:x.N1
			if x.t1(i) >= apo_start
				apo_t1(i) = cos(pi/2*(x.t1(i)-(apo_end-apo_start))/(apo_end-apo_start));
			end
			if x.t1(i) >= apo_end
				apo_t1(i) = 0;
			end
		end
		apo_mask = apo_t1.*apo_Tw.*apo_v3;
	%% define inverse apo mask
		inv_apo_t1 = zeros(size(apo_t1));
		inv_apo_Tw = zeros(size(apo_Tw));
		inv_apo_v3 = zeros(size(apo_v3));
		for i=1:numel(apo_t1)
			if abs(apo_t1(i)) < (1e-5)
				inv_apo_t1(i) = 0;
			else
				inv_apo_t1(i) = 1/apo_t1(i);
			end
		end
		for i=1:numel(apo_Tw)
			if abs(apo_Tw(i)) < (1e-5)
				inv_apo_Tw(i) = 0;
			else
				inv_apo_Tw(i) = 1/apo_Tw(i);
			end
		end
		for i=1:numel(apo_v3)
			if abs(apo_v3(i)) < (1e-5)
				inv_apo_v3(i) = 0;
			else
				inv_apo_v3(i) = 1/apo_v3(i);
			end
		end
		inv_apo_mask = inv_apo_t1.*inv_apo_Tw.*inv_apo_v3;
end