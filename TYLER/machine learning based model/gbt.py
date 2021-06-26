import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
train_feature = np.genfromtxt("trainfeatures.txt",delimiter=",",dtype=np.float32)
train_label=np.genfromtxt("trainlabels.txt",delimiter=",",dtype=np.float32)

train_feature = pd.DataFrame(train_feature)
train_label=pd.DataFrame(train_label)


test_feature = np.genfromtxt("testfeatures.txt",delimiter=",",dtype=np.float32)
test_label = np.genfromtxt("testlabels.txt",delimiter=",",dtype=np.float32)

test_feature = pd.DataFrame(test_feature)
test_label = pd.DataFrame(test_label)

gbdt = GradientBoostingRegressor(
  loss = 'ls'
, learning_rate = 0.1
, n_estimators = 180
, subsample = 1
, min_samples_split = 2
, min_samples_leaf = 1
, max_depth = 3
, init = None
, random_state = None
, max_features = None
, alpha = 0.9
, verbose = 0
, max_leaf_nodes = None
, warm_start = False
)

gbdt.fit(train_feature, train_label)
pred = gbdt.predict(test_feature)

predvalue=[]
for i in range(len(pred)):
    predvalue.append(pred[i])
Pvalue=pd.DataFrame(predvalue)
Pvalue.to_csv("Pvalue.csv",sep=',',header=False,index=False)

