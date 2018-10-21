import numpy as np
import csv
import mahotas
import cv2
from skimage.feature import hog
from sklearn.neighbors import KNeighborsClassifier
from sklearn import datasets, linear_model
from sklearn.model_selection import train_test_split

# Loading data 
x1 = np.loadtxt("train_x.csv", delimiter=",")
y1 = np.loadtxt("train_y.csv", delimiter=",")
x1 = x1.reshape(-1,64,64)
y1 = y1.reshape(-1,1)

x_test = np.loadtxt("test_x.csv", delimiter=",")
x_test = x_test.reshape(-1,64,64)
X = np.zeros(x1.shape)
for i,I in enumerate(x1):
   I_blur = cv2.GaussianBlur(I, (3,3), 0)
   _, dst = cv2.threshold(np.uint8(I_blur),190,1,cv2.THRESH_BINARY)
   X[i,:,:] = dst

X_test = np.zeros(x_test.shape)
for i,I in enumerate(x_test):
   I_blur = cv2.GaussianBlur(I, (3,3), 0)
   _, dst = cv2.threshold(np.uint8(I_blur),190,1,cv2.THRESH_BINARY)
   X_test[i,:,:] = dst

Y_flat = np.ravel(y1)
def crop_minAreaRect(img, rect):
    # rotate img
    angle = rect[2]
    rows,cols = img.shape[0], img.shape[1]
    M = cv2.getRotationMatrix2D((cols/2,rows/2),angle,1)
    img_rot = cv2.warpAffine(img,M,(cols,rows))
    # rotate bounding box
    rect0 = (rect[0], rect[1], 0.0)
    box = cv2.boxPoints(rect)
    pts = np.int0(cv2.transform(np.array([box]), M))[0]    
    pts[pts < 0] = 0
    # crop
    img_crop = img_rot[pts[1][1]:pts[0][1], 
                       pts[1][0]:pts[2][0]]
    return img_crop

zernike_features = []
for im in X:
   image = im.copy()
   (_,cnts, _) = cv2.findContours(np.uint8(im).copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
   cnts = sorted(cnts, key = cv2.contourArea, reverse = True)
   zernike_feats = []
   for cnt in cnts[0:4]:
       rect = cv2.minAreaRect(cnt)
       img = crop_minAreaRect(image, rect)
       #cv2.imshow("img", img)
       zval = mahotas.features.zernike_moments(img, 30)
       zernike_feats.append(zval)
   zernike_features.append(zernike_feats)

zernike_features_norm = [] 
for feat in zernike_features:
   if len(feat) == 3:
       feat.append(np.zeros(25))
   elif len(feat) == 2:
       feat.extend([np.zeros(25),np.zeros(25)])
   elif len(feat) == 1:
       feat.extend([np.zeros(25),np.zeros(25),np.zeros(25)])
   z_array = np.array(feat)
   z_1_D = z_array.reshape((4*25,1))
   zernike_features_norm.append(z_1_D.flatten())

zernike_features_test = []
for im in X_test:
   image = im.copy()
   (_,cnts, _) = cv2.findContours(np.uint8(im).copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
   cnts = sorted(cnts, key = cv2.contourArea, reverse = True)
   zernike_feats = []
   for cnt in cnts[0:4]:
       rect = cv2.minAreaRect(cnt)
       img = crop_minAreaRect(image, rect)
       #cv2.imshow("img", img)
       zval = mahotas.features.zernike_moments(img, 30)
       zernike_feats.append(zval)
   zernike_features_test.append(zernike_feats)

zernike_features_norm_test = [] 
for feat in zernike_features_test:
   if len(feat) == 3:
       feat.append(np.zeros(25))
   elif len(feat) == 2:
       feat.extend([np.zeros(25),np.zeros(25)])
   elif len(feat) == 1:
       feat.extend([np.zeros(25),np.zeros(25),np.zeros(25)])
   z_array = np.array(feat)
   z_1_D = z_array.reshape((4*25,1))
   zernike_features_norm_test.append(z_1_D.flatten())

rect = cv2.minAreaRect(cnts[1])
img = crop_minAreaRect(image, rect)
cv2.imshow("img", img)
#

# Using the binary image as features
features = []
for I in X:
   features.append(I.flatten())

features_test = []
for I in X_test:
   features_test.append(I.flatten())
# Histogram of Oriented Gradients extraction (Only applied on training data)
hog_features = []
visuals = []
for im in X:
   hog_image, vis = hog(im, orientations=9, pixels_per_cell=(4, 4),
                   cells_per_block=(1, 1), visualise=True)
   hog_features.append(hog_image)
   visuals.append(vis)

# Zernike features extraction from image
zernike_features = []
for im in X:
   zval = mahotas.features.zernike_moments(im, 30)
   zernike_features.append(zval)

zernike_features_test = []
for im in X_test:
   zval = mahotas.features.zernike_moments(im, 30)
   zernike_features_test.append(zval)

# Hu moments extraction from image
hu_moments_features = []
for im in X:
   Mom = cv2.moments(im, binaryImage=True)
   hu = cv2.HuMoments(Mom)
   hu_moments_features.append(hu.flatten())
   
hu_moments_features_test = []
for im in X_test:
   Mom = cv2.moments(im, binaryImage=True)
   hu = cv2.HuMoments(Mom)
   hu_moments_features_test.append(hu.flatten())
#

# Training and Splitting the training data after feature extraction
trainRI, testRI, trainRL, testRL = train_test_split(zernike_features_norm, Y_flat,
                                                   test_size=0.25,random_state=40)

# # K-Nearest Neighbor Model
# model = KNeighborsClassifier(n_neighbors=8)
# model.fit(trainRI, trainRL)
# acc = model.score(testRI, testRL)
# print("Validation accuracy: {:.2f}%".format(acc * 100))
#
#SVM model
from sklearn.svm import SVC
classifier = SVC(kernel = 'rbf', random_state = 0)
classifier.fit(trainRI, trainRL)
acc = classifier.score(testRI, testRL)
print("Validation accuracy: {:.2f}%".format(acc * 100))
# # Logistic Regression Model
# logreg = linear_model.LogisticRegression()
# logreg.fit(trainRI, trainRL)
# acc = logreg.score(testRI, testRL)
# print("Validation accuracy: {:.2f}%".format(acc * 100))
# #

# Applying the model of choice on the test data
Pred_labels = classifier.predict(zernike_features_norm_test)
Pred = Pred_labels.astype(int)
with open("Output_4.csv", 'wb') as f:
   writer = csv.writer(f, delimiter=",")
   writer.writerow(list(Pred))
    
print "test"
