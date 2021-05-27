function matched_abs = match_abs(probe_v3,probe_abs,unmatched_v3,unmatched_abs)
	probe_abs_2 = reshape(probe_abs,[numel(probe_abs),1]);
	probe_v3_2 = reshape(probe_v3,[numel(probe_v3),1]);
	unmatched_abs_2 = reshape(unmatched_abs,[numel(unmatched_abs),1]);
	unmatched_v3_2 = reshape(unmatched_v3,[numel(unmatched_v3),1]);
	unmatched_abs_2 = spline(unmatched_v3_2,unmatched_abs_2,probe_v3_2);
	J = [unmatched_abs_2,ones(size(unmatched_abs_2))];
	v = pinv(J'*J)*J'*real(probe_abs_2-unmatched_abs_2);
	matched_abs = (1+v(1))*unmatched_abs_2+v(2);
end