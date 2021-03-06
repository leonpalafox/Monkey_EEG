
NoComponents=70;%NoCOmponents states the final number of components 
%MasterArray contains a Tx3200 Feature matrix (Channelsx10x10)
X=MasterArray;
%NewMotionData has the normalized and aligned Motion Data from rearrandeData.m
y=NewMotionData;
%To identify the shapes of both the data matrix and the y
[n,p] = size(X);
[ny,py]=size(y);
%Here we generate the crossvalidated sets
%indices = crossvalind('Kfold',ny,10);
indices(1:n)=0;
indices(1:ceil(1*n/10))=1; %I've used 1/3d of the data for testing, rest for training
test = (indices == 1); train = ~test;

%plsregress is the matlab function that performs PLS regression 
%It returns the loadings for both X and Y, and the coefficients beta that are used to do predictions.
%I call it several times to calculate the r^2 for different components
for i=2:NoComponents
        [Xloadings,Yloadings,Xscores,Yscores,betaPLS,pctVar,PLSmsep] = plsregress(X(train,:),y(train,:),i);
        %To do prediction, we need to append a vector of 1s since the matrix beta is an augmented matrix to account for the affine factor of the regression
        %yfitPLS = [ones(sum(train),1) X(train,:)]*betaPLS;
        %TSS = sum((y(train,:)-repmat(mean(y(train,:)),sum(train),1)).^2);
        %RSS_PLS = sum((y(train,:)-yfitPLS).^2);
        yfitPLS = [ones(sum(test),1) X(test,:)]*betaPLS;
        %This section calculates the r squared parameter to see the goodness of the fit
        TSS = sum((y(test,:)-repmat(mean(y(test,:)),sum(test),1)).^2);
        RSS_PLS = sum((y(test,:)-yfitPLS).^2);
        rsquaredPLS(i-1) = 1 - RSS_PLS/TSS;
end
figure
plot(y(test,:),yfitPLS,'bo');
%plot(y(train,:),yfitPLS,'bo');
xlabel('Observed Response');
ylabel('Fitted Response');
legend({'PLSR with 20 Components'},'location','NW');
figure
plotyy([1:NoComponents-1],rsquaredPLS,[1:NoComponents-1],PLSmsep(2,3:end),'plot','plot')


