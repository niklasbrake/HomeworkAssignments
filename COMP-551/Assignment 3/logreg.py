import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn import linear_model, datasets, metrics
from scipy.ndimage.filters import gaussian_filter
import matplotlib.image as mpimg
import matplotlib.pyplot as plt


nbrows=50000
train_x=pd.read_csv('train_x.csv',delimiter=",",header=None,dtype=int,nrows=nbrows)
test=pd.read_csv('test_x.csv',header=None,dtype=int,delimiter=",",nrows=nbrows)
train_y=pd.read_csv('train_y.csv',header=None,delimiter=",",nrows=nbrows)
print 'files opened'

#start of machine learning
print 'start regression'
X_train,X_test,Y_train,Y_test=train_test_split(train_x,np.ravel(train_y),test_size=0.2)

scaler=StandardScaler(copy=False)
X_train=scaler.fit_transform(X_train,Y_train)
X_test=scaler.transform(X_test)
test=scaler.transform(test)
print 'scaled'

logistic=LogisticRegression(multi_class='multinomial',penalty='l2',solver='saga',tol=0.1)
logistic.fit(X_train,Y_train)
print 'fitted'

# Y_predict=logistic.predict(X_test)
# print 'predicted'

final_predict=logistic.predict(test)

# stats=metrics.classification_report(Y_test,Y_predict)
# print stats

#write kaggle submission
kaggle=open('kaggle_sumbssion.txt','w')
kaggle.write('Id,Label\n')
counter=1
for i in final_predict:
	kaggle.write(str(counter)+','+str(i)+'\n')
	counter=counter+1
kaggle.close()
