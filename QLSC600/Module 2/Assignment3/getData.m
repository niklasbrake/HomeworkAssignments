fid = fopen('datastd.csv');
txt = textscan(fid,'%s');
T = cellfun(@(X) strsplit(X,','),txt{1},'UniformOutput',false);
T = vertcat(T{:});
X = cellfun(@str2num,T(2:end,2:end),'un',0);
X = cell2mat(X);

fid = fopen('header.csv');
txt = textscan(fid,'%s');
Populations = string(strsplit(txt{1}{2},','));

fid = fopen('superpops.csv');
txt = textscan(fid,'%s');
T = cellfun(@(X) strsplit(X,','),txt{1},'UniformOutput',false);
T = vertcat(T{:});
SuperPopulations = string(cellfun(@str2num,T(:,2),'un',0));

fid = fopen('Ynew.csv');
txt = textscan(fid,'%s');
T = cellfun(@(X) strsplit(X,','),txt{1},'UniformOutput',false);
T = vertcat(T{:});
Y = cell2mat(cellfun(@str2num,T(2:end,2),'un',0));
SampleLabels = string(cellfun(@str2num,T(2:end,1),'un',0));

save('Data.mat','X','Y','SuperPopulations','Populations','SampleLabels');


[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(X);
pareto(EXPLAINED);


SCORE = SCORE(:,1:10);
[~,~,stats] = glmfit(SCORE,Y);
Yresid = stats.resid;
for j = 1:size(X,2)
	[~,~,stats] = glmfit(SCORE,X(:,j));
	Xresid(:,j) = stats.resid;
end


temp = unique(SuperPopulations);
selectedSuperPopulation = temp{1};
selectIdcs = find(strcmp(SuperPopulations,selectedSuperPopulation));
selectPops = unique(Populations(selectIdcs));
uniquePops = unique(Populations);

for k = 1:length(selectPops)
	looIdcs = find(strcmp(selectPops{k},Populations));
	remainIdcs = setdiff(selectIdcs,looIdcs);
	for j = 1:size(X,2)
		[~,~,stats] = glmfit(Xresid(remainIdcs,j),Yresid(remainIdcs));
		B(j,k) = stats.beta(2);
		P(j,k) = stats.p(2);
	end
end

testTheseThresholds = [1,0.5,0.01,1e-5,1e-8,1e-12];
% For several P_thresholds...
for i = 1:length(testTheseThresholds)
    P_Threshold = testTheseThresholds(i);
    % For each leave-one-out condition...
    for k = 1:length(selectPops)
        % All SNP residuals who contribute to the linear model with confidence 
        % determined by P_Threshold
        selectedSNPIdcs = find(P(:,k) < P_Threshold);
        % Calcute risk score based on these significant SNP residuals
        S(:,k) = Xresid(:,selectedSNPIdcs)*B(selectedSNPIdcs,k);
        % Calculate how well this risk score matches phenotype residual
        % for each population
        for K = 1:length(uniquePops)
            idcs = find(strcmp(Populations,uniquePops{K}));
            MSE(K,k,i) = sum((Yresid(idcs)-S(idcs,k)).^2)/length(idcs);
        end
    end
end


for i = 1:size(MSE,3)
    fig = figure(i);
    bar(MSE(:,:,i));
    title(['P-thresh:' num2str(testTheseThresholds(i))]);
    set(gca,'XTick',[1:26]); set(gca,'XTickLabels',unique(Populations))
    box off; set(gca,'TickDir','out')
    L = legend(selectPops); L.Title.String = 'LOO'; L.Location = 'north';
    pos = get(fig,'InnerPosition');
    pos(3) = 700;
    set(fig,'InnerPosition',pos);
    set(gca,'FontSize',6);
end





