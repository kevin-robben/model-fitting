function cost = ILS_C(x,p,D,w)
	cost = sum(sum(sum(w.*abs(reshape(ILS_M(x,p),size(D))-D).^2)));
end