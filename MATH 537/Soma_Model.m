function [FullSystem X0]= Soma_Forrest(I_app)
	if(nargin == 0)
		I_app = @(t) 0;
	end

	dNav16 = dI_Na_r;
	dI_Na_r_C1 = dNav16{1};
	dI_Na_r_C2 = dNav16{2};
	dI_Na_r_C3 = dNav16{3};
	dI_Na_r_C4 = dNav16{4};
	dI_Na_r_C5 = dNav16{5};
	dI_Na_r_O = dNav16{6};
	dI_Na_r_OB = dNav16{7};
	dI_Na_r_I1 = dNav16{8};
	dI_Na_r_I2 = dNav16{9};
	dI_Na_r_I3 = dNav16{10};
	dI_Na_r_I4 = dNav16{11};
	dI_Na_r_I5 = dNav16{12};
	dI_Na_r_I6 = dNav16{13};

	FullSystem = @(t,X) [ ...
			dV(t,X,I_app(t)); ... % V
			dI_K_HTS_m(t,X(1),X(2)); ... % I_K_HTS_m
			dI_K_HTS_h(t,X(1),X(3)); ... % I_K_HTS_h
			dI_K_MTS_m(t,X(1),X(4)); ... % I_K_MTS_m
			dI_K_NTS_m(t,X(1),X(5)); ... % I_K_NTS_m
			dI_K_SK_z(t,X(1),X(6),X(29)); ... % I_K_SK_z
			dI_K_BK_m(t,X(1),X(7)); ... % I_K_BK_m
			dI_K_BK_z(t,X(1),X(8),X(29)); ... % I_K_BK_z
			dI_K_BK_h(t,X(1),X(9)); ... % I_K_BK_h
			dI_Na_f_m(t,X(1),X(10)); ... % I_Na_f_m
			dI_Na_f_h(t,X(1),X(11)); ... % I_Na_f_h
			dI_Na_p_m(t,X(1),X(12)); ... % I_Na_p_m
			dI_Na_r_C1(t,X(1),X(13:25)); ... % I_Na_r_C1
			dI_Na_r_C2(t,X(1),X(13:25)); ... % I_Na_r_C2
			dI_Na_r_C3(t,X(1),X(13:25)); ... % I_Na_r_C3
			dI_Na_r_C4(t,X(1),X(13:25)); ... % I_Na_r_C4
			dI_Na_r_C5(t,X(1),X(13:25)); ... % I_Na_r_C5
			dI_Na_r_O(t,X(1),X(13:25)); ... % I_Na_r_O
			dI_Na_r_OB(t,X(1),X(13:25)); ... % I_Na_r_OB
			dI_Na_r_I1(t,X(1),X(13:25)); ... % I_Na_r_I1
			dI_Na_r_I2(t,X(1),X(13:25)); ... % I_Na_r_I2
			dI_Na_r_I3(t,X(1),X(13:25)); ... % I_Na_r_I3
			dI_Na_r_I4(t,X(1),X(13:25)); ... % I_Na_r_I4
			dI_Na_r_I5(t,X(1),X(13:25)); ... % I_Na_r_I5
			dI_Na_r_I6(t,X(1),X(13:25)); ... % I_Na_r_I6
			dI_Ca_t_m(t,X(1),X(26)); ... % I_Ca_t_m
			dI_Ca_t_h(t,X(1),X(27)); ... % I_Ca_t_h
			dI_Ca_p_m(t,X(1),X(28)); ... % I_Ca_p_m
			dCa_Cai(t,X(1),X(29),I_Ca(X(1),X(26),X(27),X(28))); ... % Ca_Cai
			dI_h_m(t,X(1),X(30)); % I_h_m
		]; 

	X0 = [-80,0,0,0,0,0,0,0,1,0,0,0,[1 zeros(1,12)],1,0,1,5e-3,0]';

function T = temp
	T = 36;

function dX = dV(t,X,I_app)
	% Conductances in mS/cm^2
	g_k_hts = 41.6/1000;
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

	% g_na_p = 4/1000;
	% g_k_sk = 7/1000;
	% g_na_p = 0;
	% g_k_sk = 0;

	V_Na = 60;
	V_Na_f = 45;
	V_L = -60;
	V_K = -88;
	V_h = -30;

	% Specific membrane capacitance in microF / cm^2
	c_m = 0.8;

	% Surface area of soma [cylindrical] (in cm^2)
	soma_len = 22e-4; % 1 cm = 10000 microns
	soma_diam = 22e-4;
	soma_SA = soma_diam*pi*soma_len+ 2*(pi*(soma_diam/2)^2);
	soma_SA = 1521e-8;

	% Total capacitance in microF / cm^2
	C_m = c_m*soma_SA;

	I_K_HTS = g_k_hts*X(2).^3.*X(3).*(X(1)-V_K);
	I_K_MTS = g_k_mts*X(4).^4.*(X(1)-V_K);
	I_K_NTS = g_k_nts*X(5).^4.*(X(1)-V_K);
	I_K_SK = g_k_sk*X(6).^2.*(X(1)-V_K);
	I_K_BK = g_k_bk*X(7).^3.*X(8).^2.*X(9).*(X(1)-V_K);
	I_Na_f = g_na_f*X(10).^3.*X(11).*(X(1)-V_Na_f);
	I_Na_p = g_na_p*X(12).*(X(1)-V_Na);
	I_Na_r = g_na_r*X(18).*(X(1)-V_Na);
	I_Ca_t = g_ca_t*X(26).*X(27).*(X(1)-135);
	I_Ca_p = g_ca_p*X(28).*E_Ca(X(1));
	I_h = g_i_h*X(30).*(X(1)-V_h);
	I_L = g_l*(X(1)-V_L);

	dX = -1/C_m*(I_K_HTS+I_K_MTS+I_K_NTS+I_K_SK+I_K_BK+I_Na_f+I_Na_p+I_Na_r+I_Ca_t+I_Ca_p+I_h+I_L-I_app);

function dX = dI_K_HTS_m(t,V,m)
	m_inf = 1/(1+exp(-(V--24)/15.4));
	if(V<-35)
		tau_m = 0.000103+0.0149*exp(0.035*V);
	else
		tau_m = 0.000129+1/(exp((V+100.7)/12.9) + exp((V-56)/-23.1));
	end
	tau_m = tau_m * 1000;
	dX = 3^((temp-22)/10)*(m_inf-m)/tau_m;

function dX = dI_K_HTS_h(t,V,h)
	h_inf = 0.31+(1-0.31)/(1+exp(-(V--5.8)/-11.2));
	if(V<=0)
		tau_h = 1.22e-5+0.012*exp(-((V+56.3)/49.6)^2);
	else
		tau_h = 0.0012 + 0.0023*exp(-0.141*V);
	end
	tau_h = tau_h*1000;
	dX = 3^((temp-22)/10)*(h_inf-h)/tau_h;

function dX = dI_K_MTS_m(t,V,m)
	m_inf = 1/(1+exp(-(V--24)/20.4));
	if(V<-20)
		tau_m = 0.000688+1/(exp((V+64.2)/6.5) + exp((V-141.5)/-34.8));
	else
		tau_m = 0.00016+0.0008*exp(-0.0267*V);
	end
	tau_m = tau_m * 1000;
	dX = 3^((temp-22)/10)*(m_inf-m)/tau_m;

function dX = dI_K_NTS_m(t,V,m)
	m_inf = 1/(1+exp(-(V--16.5)/18.4));
	tau_m = 0.000796+1/(exp((V+73.2)/11.7)+exp((V-306.7)/-74.2));
	tau_m = tau_m * 1000;
	dX = 3^((temp-22)/10)*(m_inf-m)/tau_m;

function dX = dI_K_SK_z(t,V,z,Cai)
	z_inf = 20*48*Cai^2/(48*Cai^2+0.03);
	tau_z = 1/(48*Cai+0.03);
	dX = (z_inf-z)/tau_z;

function dX = dI_K_BK_m(t,V,m)
	m_inf = 1/(1+exp(-(V--28.9)/6.2));
	tau_m = 0.000505+1/(exp((V+86.4)/10.1) + exp((V-33.3)/-10));
	tau_m = tau_m * 1000;
	dX = 3^((temp-22)/10)*(m_inf-m)/tau_m;

function dX = dI_K_BK_z(t,V,z,Cai)
	z_inf = 1/(1+0.001/Cai);
	tau_z = 1;
	dX = 3^((temp-22)/10)*(z_inf-z)/tau_z;

function dX = dI_K_BK_h(t,V,h)
	h_inf = 0.085+(1-0.085)/(1+exp(-(V--32)/-5.8));
	tau_h = 0.0019+1/(exp((V+48.5)/5.2) + exp((V-54.2)/-12.9));
	tau_h = tau_h * 1000;
	dX = 3^((temp-22)/10)*(h_inf-h)/tau_h;

function dX = dI_Na_f_m(t,V,m)
	a_m = 35/(0+exp((V+5)/-10));
	b_m = 7/(0+exp((V+65)/20));
	m_inf = a_m/(b_m+a_m);
	tau_m = 1/(a_m+b_m);
	dX = 3^((temp-37)/10)*(m_inf-m)/tau_m;

function dX = dI_Na_f_h(t,V,h)
	a_h = 0.225/(1+exp((V+80)/10));
	b_h = 7.5/(0+exp((V+-3)/-18));
	h_inf = a_h/(b_h+a_h);
	tau_h = 1/(a_h+b_h);
	dX = 3^((temp-37))*(h_inf-h)/tau_h;

function dX = dI_Na_r
	qt = 3^((temp-22)/10);
	a = @(v) 150*exp(v/20);
	b = @(v) 3*exp(v/-20);
	c = @(v) 150;
	d = @(v) 40;
	e = @(v) 1.75;
	f = @(v) 0.03*exp(-v/25);
	% f = @(v) 0.03*exp(2*v/25);

	con = 0.005;
	coff = 0.5;
	oon = 0.75;
	ooff = 0.005;

	A = (oon/con)^0.25;
	B = (ooff/coff)^0.25;

	n1 = 4;
	n2 = 3;
	n3 = 2;
	n4 = 1;

	dX{1} = @(t,V,X) qt*(n4*b(V)*X(2) + coff*X(8) - X(1)*(n1*a(V) + con));
	dX{2} = @(t,V,X) qt*(n1*a(V)*X(1) + n3*b(V)*X(3) + coff*B^1*X(9) - X(2)*(n4*b(V) + n2*a(V) + con*A^1));
	dX{3} = @(t,V,X) qt*(n2*a(V)*X(2) + n2*b(V)*X(4) + coff*B^2*X(10) - X(3)*(n3*b(V) + n3*a(V) + con*A^2));
	dX{4} = @(t,V,X) qt*(n3*a(V)*X(3) + n1*b(V)*X(5) + coff*B^3*X(11) - X(4)*(n2*b(V) + n4*a(V) + con*A^3));
	dX{5} = @(t,V,X) qt*(n4*a(V)*X(4) + d(V)*X(6) + coff*B^4*X(12) - X(5)*(n1*b(V) + c(V) + con*A^4));
	dX{6} = @(t,V,X) qt*(c(V)*X(5) + f(V)*X(7) + ooff*X(13) - X(6)*(oon + d(V) + e(V)));
	dX{7} = @(t,V,X) qt*(e(V)*X(6) - f(V)*X(7));
	dX{8} = @(t,V,X) qt*(n4*b(V)*B*X(9) + con*X(1)- X(8)*(coff + n1*a(V)*A));
	dX{9} = @(t,V,X) qt*(n1*a(V)*A*X(8) + n3*b(V)*B*X(10) + con*A*X(2) - X(9)*(n4*b(V)*B  + n2*a(V)*A + coff*B));
	dX{10} = @(t,V,X) qt*(n2*a(V)*A*X(9) + n2*b(V)*B*X(11) + con*A^2*X(3) - X(10)*(n3*b(V)*B + n3*a(V)*A + coff*B^2));
	dX{11} = @(t,V,X) qt*(n3*a(V)*A*X(10) + n1*b(V)*B*X(12) + con*A^3*X(4) - X(11)*(n2*b(V)*B + n4*a(V)*A + coff*B^3));
	dX{12} = @(t,V,X) qt*(n4*a(V)*A*X(11) + d(V)*X(13) + con*A^4*X(5) - X(12)*(n1*b(V)*B + c(V) + coff*B^4));
	dX{13} = @(t,V,X) qt*(c(V)*X(12) + oon*X(6) - X(13)*(d(V) + ooff));

function dX = dI_Na_p_m(t,V,m)
	a_m = 0.091*(V+42)/(1-exp(-(V+42)/5));
	b_m = -0.062*(V+42)/(1-exp((V+42)/5));

	m_inf = 1/(1+exp(-(V+42)/5));
	tau_m = 5/(a_m+b_m);

	dX = 3^((temp-30)/10)*(m_inf-m)/tau_m;

function dX = dI_Ca_t_m(t,V,m)
	a_m = 2.6/(1+exp((V+21)/-8));
	b_m = 0.18/(1+exp((V+40)/4));
	m_inf = a_m/(b_m+a_m);
	tau_m = 1/(a_m+b_m);
	dX = 3^((temp-37)/10)*(m_inf-m)/tau_m;

function dX = dI_Ca_t_h(t,V,h)
	a_h = 0.0025/(1+exp((V+40)/8));
	b_h = 0.19/(1+exp((V+50)/-10));
	h_inf = a_h/(b_h+a_h);
	tau_h = 1/(a_h+b_h);
	dX = 3^((temp-37)/10)*(h_inf-h)/tau_h;

function ghk = E_Ca(V)
	Cai = 100e-6;
	Cao = 2; %mM
	T = 295; %22 C
	P_Ca = 5e-5; %cm/sec
	% P_Ca = P_Ca / 100; % cm/sec -> m/s
	F = 96485; %C per mol e-
	R = 8.314; % J/molK
	z = 2; % Valence (e- / Ca ion)
	v = V/1000; % mV -> V
	xi = z*v*F/(R*T);

	D = 1-exp(-v*xi);
	if(abs(D) < 1e-6)
		ghk = P_Ca*z*F*(Cai-Cao);
	else
		ghk = (P_Ca*z*F*xi*v.*(Cai-Cao*exp(-v*xi)).*D.^(-1))';
	end
	% ghk = 1000*ghk; % V -> mV

function dX = dI_Ca_p_m(t,V,m)
	m_inf = 1/(1+exp(-(V--19)/5.5));
	if(V<=-50)
		tau_m = 0.000264+0.128*exp(0.103*V);
	else
		tau_m = 0.000191+0.00376*exp(-((V+41.9)/27.8)^2);
		% tau_m = 0.000191+0.00376*exp(-((V+11.9)/27.8)^2);
	end
	tau_m = tau_m * 1000;
	dX = 3^((temp-22)/10)*(m_inf-m)/tau_m;

function dX = dI_h_m(t,V,m)
	m_inf = 1/(exp(-(V--90.1)/-9.9));
	tau_m = 0.19+0.72*exp(-((V+81.5)/11.9)^2);
	% tau_m = tau_m*1000;
	dX = 3^((temp-22)/10)*(m_inf-m)/tau_m;

function dX = dCa_Cai(t,V,Cai,I_Ca)
	% [Ca2+] is calculated for the intracellular space within 100 nm of the membrane. [Ca2+] changes as ICa2+ brings Ca2+ into this space and Ca2+ leaves by diffusion to the bulk cytoplasm. The diffusion rate constant, b,is set to 1/msec
	b = 1; % ms^-1
	d = 0.1; % depth is 0.1 microns
	A = 1521; % Area is 1,521 microns^2
	F = 96485; %C per M e-

	% dX  = -1e7*I_Ca/(2*F*d*A)-b*(Cai-100e-6);
	dX  = -1e8*I_Ca/(2*F*d*A)-b*(Cai-100e-6);
	% dX  = -1e7*I_Ca/(2*F*d*A)-b*(Cai-100e-6);

function I = I_Ca(V,I_Ca_t_m,I_Ca_t_h,I_Ca_p_m)
	g_ca_t = 0.1/1000; g_ca_p = 0.52/1000;
	I = g_ca_t*I_Ca_t_m*I_Ca_t_h*(V-135) + g_ca_p*I_Ca_p_m*E_Ca(V);
