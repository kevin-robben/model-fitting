%% 3rd order FID: Kubo + pure dephasing model
function FID = M_3rd_order_kubo(x,p)
%% generate FID
		  %    non-rephasing              rephasing
	FID = fft(Rnr(x,p),2*x.N3,2) + conj(fft(Rr(x,p),2*x.N3,2)) ;
	FID = FID(:,1:x.N3,:); % discard negative time half
	if strcmp(x.num_type,'real')
		FID = real(FID);
	end
end