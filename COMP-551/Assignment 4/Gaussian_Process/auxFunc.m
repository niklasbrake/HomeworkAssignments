function [u,s,c,Network_Depth,sig_w,sig_b] = auxFunc()
	
	u_max = 18;
	s_max = 100;
	n_g = 501;
	n_v = 501;
	n_c = 500;

	Network_Depth = 100;
	sig_w = sqrt(1.79);
	sig_b = sqrt(0.83);

	u = linspace(-u_max,u_max,n_g);
	s = linspace(0,s_max,n_v);
	s = s(2:end); % Remove s = 0
	c = linspace(-0.99999,0.99999,n_c);

end