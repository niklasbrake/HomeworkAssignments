function PlotCurrents

	% g_k_hts = 41.6/1000;
	g_k_hts = 200/1000;
	g_k_mts = 20.8/1000;
	g_k_nts = 41.6/1000;
	g_k_sk = 4/1000;
	g_k_bk = 72.8/1000;
	g_na_f = 0.1/1000;
	g_na_p = 4/1000;
	g_na_r =  156/1000;
	g_ca_t = 0.1/1000;
	g_ca_p = 0.52/1000;
	g_i_h = 1.04/1000;
	g_l = 0.52/1000;

	g_k_sk = 40/1000;
	g_na_p = 4/1000;

	V_Na = 60;
	V_Na_f = 45;
	V_L = -60;
	V_K = -88;
	V_h = -30;

	% I = @(t) 2*(t>40)*(t<45);

	% [dX X0] = Soma_Forrest_clean;
	[dX X0] = Soma_Forrest_edit;
	s = ode15s(dX,[1 100],X0');
	X = s.y;

	I_K_HTS = g_k_hts*X(2,:).^3.*X(3,:).*(X(1,:)-V_K);
	I_K_MTS = g_k_mts*X(4,:).^4.*(X(1,:)-V_K);
	I_K_NTS = g_k_nts*X(5,:).^4.*(X(1,:)-V_K);
	I_K_SK = g_k_sk*X(6,:).^2.*(X(1,:)-V_K);
	I_K_BK = g_k_bk*X(7,:).^3.*X(8,:).^2.*X(9,:).*(X(1,:)-V_K);
	I_Na_f = g_na_f*X(10,:).^3.*X(11,:).*(X(1,:)-V_Na);
	I_Na_p = g_na_p*X(12,:).*(X(1,:)-V_Na);
	I_Na_r = g_na_r*X(18,:).*(X(1,:)-V_Na);
	I_Ca_t = g_ca_t*X(26,:).*X(27,:).*(X(1)-135);
	I_Ca_p = g_ca_p*X(28,:).*E_Ca(X(1,:),X(29,:));
	I_h = g_i_h*X(30,:).*(X(1,:)-V_h);
	I_L = g_l*(X(1,:)-V_L);

	figure(1)
	yyaxis left;
	hold off;
	plot(s.x,X(1,:),'-k');
	yyaxis right; hold off;
	plot(s.x,-I_K_HTS,'-b'); hold on;
	plot(s.x,-I_K_MTS,'--b'); 
	plot(s.x,-I_K_NTS,'-.b'); 
	plot(s.x,-I_K_SK,'-c'); 
	plot(s.x,-I_K_BK,'--c'); 
	plot(s.x,-I_Na_f,'-r'); 
	plot(s.x,-I_Na_p,'--r'); 
	plot(s.x,-I_Na_r,'-.r'); 
	plot(s.x,-I_Ca_t,'-g'); 
	plot(s.x,-I_Ca_p,'--g'); 
	plot(s.x,-I_h,'-y'); 
	plot(s.x,-I_L,'--y'); 

	legend({'V','I-K-HTS','I-K-MTS','I-K-NTS','I-K-SK','I-K-BK','I-Na-f','I-Na-p','I-Na-r','I-Ca-t','I-Ca-p','I-h','I-L'});
	figure(2)
	% plot(s.x,s.y(29,:))
	yyaxis left; hold off;
	plot(s.x,X(1,:),'-k');
	yyaxis right; hold off;
	plot(s.x,-I_Na_p,'--r'); hold on;
	plot(s.x,-I_K_SK,'-c');
	plot(s.x,-I_K_BK,'--c');
	legend({'V','I-Na-P','I-K-SK','I-K-BK'});
	figure(3)
	subplot(3,1,1); plot(s.x,I_Na_p,'-r');
	subplot(3,1,2);	plot(s.x,I_K_SK,'-b');
	subplot(3,1,3); plot(s.x,I_K_BK,'-c');
	
end

