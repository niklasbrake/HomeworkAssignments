function dX = Assignment1(r,c,D)

K = 1;
W = 1;
s = 0.1;

r_in = r;
K_in = K;
c_in = c;
D_in = D;
s_in = s;
W_in = W;

F1 = @(N,P) r*N.*(1-N/K) - c*N.*P./(D+N);
F2 = @(N,P) s*P.*(1-P/W);
dX = @(t,X) [F1(X(1),X(2)); ...
			 F2(X(1),X(2))];

syms r K c D s W
syms N P
dNdt = r*N*(1-N/K)-c*N*P/(D+N);
dPdt = s*P*(1-P/W);

disp('Equations:');
disp('dN/dt = rN(1-N/k)-cNP/(D+N)');
disp('dP/dt = sP(1-P/W)');

fprintf('\n');

J(1,1) = diff(dNdt,N);
J(1,2) = diff(dNdt,P);
J(2,1) = diff(dPdt,N);
J(2,2) = diff(dPdt,P);
disp('Jacobian Matrix:');
disp(J);


sols1 = solve(dPdt==0,P,'IgnoreAnalyticConstraints',true);
disp('P Nullclines:')
for i = 1:length(sols1)
	disp(['P = ' char(sols1(i))]);
end

fprintf('\n');

sols2 = solve(dNdt==0,N,'IgnoreAnalyticConstraints',true);
disp('N Nullclines:')
for i = 1:length(sols2)
	disp(['N = ' char(sols2(i))]);
end

fprintf('\n');

disp('Steady States ([N,P]):');
SS = sym([]);
for i = 1:length(sols1)
	for j = 1:length(sols2)
		px = sols1(i);
		nx = feval(symengine,'simplify',subs(sols2(j),P,px),'IgnoreAnalyticConstraints');
		SS(end+1,1) = nx;
		SS(end,2) = px;
	end
end
disp(SS)


%{
fprintf('\n');

disp('Linear Approximations...')
for i = 1:size(SS,1)
	try
		Jx = subs(J,{N,P},SS(i,:));
		disp(['...at (' char(SS(i,1)) ',' char(SS(i,2)) ')']);
		disp(Jx)
	catch
		disp(['...at (' char(SS(i,1)) ',' char(SS(i,2)) ')']);
		fprintf('Numerically unstable.\n\n');
	end
end
%}

fprintf('\n');
disp('--------------------------------------------------')

disp('Parameter Values:');
disp(['r = ' num2str(r_in)]);
disp(['K = ' num2str(K_in)]);
disp(['c = ' num2str(c_in)]);
disp(['D = ' num2str(D_in)]);
disp(['s = ' num2str(s_in)]);
disp(['W = ' num2str(W_in)]);
params = {r,K,c,D,s,W};
params_in = {r_in,K_in,c_in,D_in,s_in,W_in};


fprintf('\n');
disp('Linear Stability:')
for i = 1:size(SS,1)
	try
		Jx = subs(J,{N,P},SS(i,:));
		Jx = matlabFunction(vpa(subs(Jx,params,params_in)));
		V(:,i) = eig(Jx());
		temp = matlabFunction(subs(SS(i,:),params,params_in));
		SSP(i,:) = temp();
		if(prod(real(V(:,i)))<0 || (prod(real(V(:,i)))>0 && V(1,i) > 0))
			disp(['(' char(SS(i,1)) ',' char(SS(i,2)) ') = (' num2str(SSP(i,1)) ',' num2str(SSP(i,2)) ')  UNSTABLE']);
			Stable(i) = 0;
		elseif(prod(real(V(:,i)))>0 && V(1,i) < 0)
			disp(['(' char(SS(i,1)) ',' char(SS(i,2)) ') = (' num2str(SSP(i,1)) ',' num2str(SSP(i,2)) ')  STABLE']);
			Stable(i) = 1;
		else
			disp(['(' char(SS(i,1)) ',' char(SS(i,2)) ') = (' num2str(SSP(i,1)) ',' num2str(SSP(i,2)) ')  CENTER']);
			Stable(i) = 0;
		end
		fprintf([num2str(char(955)) '1 = ' num2str(V(1,i)) '  ' num2str(char(955)) '2 = ' num2str(V(2,i)) '\n\n'])
	catch
		disp(['(' char(SS(i,1)) ',' char(SS(i,2)) ')']);
		fprintf('Numerical Error.\n\n');
		Stable(i) = 0;
	end
end

warning('off','MATLAB:plot:IgnoreImaginaryXYPart')
warning('off','MATLAB:specgraph:private:specgraph:UsingOnlyRealComponentOfComplexData');

% fig = figure;
X = linspace(0,K_in,5000);
Y = linspace(0,W_in,5000);
for i = 1:length(sols1)
	NCP{i} = matlabFunction(subs(sols1(i),params,params_in),'Vars',[N P]);
	nanswitch = 0;
	for j = 1:5000
		F(j) = NCP{i}(X(j),Y(j));
		if(~isreal(F(j)))
			if(nanswitch)
				F(j) = nan;
			end
			nanswitch = 1;
		end
	end
	plot(X,F,'LineWidth',1,'color','r'); hold on;
end
for i = 1:length(sols2)
	NCN{i} = matlabFunction(subs(sols2(i),params,params_in),'Vars',[N P]);
	nanswitch = 0;
	for j = 1:5000
		F(j) = NCN{i}(X(j),Y(j));
		if(~isreal(F(j)))
			if(nanswitch)
				F(j) = nan;
			end
			nanswitch = 1;
		end
	end
	plot(F,Y,'LineWidth',1,'color','b');
end

for i = 1:size(SS,1)
	if(isreal(SSP(i,:)))
		if(Stable(i))
			scatter(SSP(i,1),SSP(i,2),20,[0 0 0],'filled');
		else
			scatter(SSP(i,1),SSP(i,2),20,[0 0 0]);
		end
	end
end

box off; set(gca,'TickDir','out');
xlim([0,K_in]); ylim([0,W_in]);
xlabel('N'); ylabel('P');

X = linspace(0,K_in,100);
Y = linspace(0,W_in,100);
[X,Y] = meshgrid(X,Y);
U = F1(X,Y);
V = F2(X,Y);
a = quiver(X,Y,U,V,'AutoScale','on');


c = uicontextmenu;
c2 = uicontextmenu;
set(a,'UIContextMenu',c)
set(gca,'UIContextMenu',c2)
uimenu(c,'Label','Specify Initial Condition','Callback',@(source,data) integrate(source,data,dX,a))
uimenu(c2,'Label','Specify Initial Condition','Callback',@(source,data) integrate(source,data,dX,a))


function integrate(source,data,dX,a)
	h = impoint();
	hChildren = get(h,'Children');
	pos = [hChildren(1).XData hChildren(1).YData];
	hChildren(2).Visible = 'off';
	hChildren(1).Marker = '*';
	hChildren(1).MarkerFaceColor = 'k';
	hChildren(1).MarkerEdgeColor = 'k';
	s = ode15s(dX,[0 1000],pos);
	plot(s.y(1,:),s.y(2,:),'Color','k');
