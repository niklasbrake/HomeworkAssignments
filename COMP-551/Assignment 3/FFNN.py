from math import exp, floor
import numpy as np

class NeuralNet(object):
    """docstring for NeuralNet"""
    def __init__(self, network_Arch, Weights, Biases, stepSize):
        # Architecture of neural net
        # Initialize random weights mean 0 variance 1
        self.network_Arch = network_Arch
        self.Weights = Weights
        self.Biases = Biases
        self.stepSize = stepSize
    
    # Takes delta E / delta W and updates weights in that direction by step stepSize
    def updateWeights(self,dW,dB):
        for layer in range(1,len(self.network_Arch)):
            self.Weights[layer] += np.multiply(dW[layer],self.stepSize[layer])
            self.Biases[layer] += np.multiply(dB[layer].T,self.stepSize[layer][:,0]).T
    
    # Returns the output labels for input X
    def getLabels(self,X):
        Y = self.getHiddenLabels(X)
        return Y[len(self.network_Arch)-1]
    
    # Returns outputs of all nodes in network
    def getHiddenLabels(self,X):
        nodeValues = {}
        nodeValues[0] = np.matrix(X).T
        for layer in range(1,len(self.network_Arch)):
            nodeValues[layer] = activation_fnct(np.matrix(self.Weights[layer])*nodeValues[layer-1]+self.Biases[layer])
        # print(nodeValues)
        return nodeValues
    
    # Updates all weight values by backpropagation
    def backProp(self,X,Y):
        # Get architecture of neural network_Arch
        network_Arch = self.network_Arch
        # Get current weights
        W = self.Weights
        # Get hidden values
        nodeValues = self.getHiddenLabels(X)
        # Calculate estimated labels
        YHat = nodeValues[len(network_Arch)-1]
        # d is the delta function for each node
        d = {}
        dW = {}
        # For each output node, calculate the error function and get delta for each node
        
        d[len(network_Arch)-1] = np.multiply(DifErrFunc(Y,YHat),DifRegFunc(YHat))
        dW[len(network_Arch)-1] = d[len(network_Arch)-1]*nodeValues[len(network_Arch)-2].T
        for layer in range(len(network_Arch)-2,0,-1):
            # Calculate delta for layer
            d[layer] = np.multiply(DifRegFunc(nodeValues[layer]),W[layer+1].T*d[layer+1])
            # Calculate change in weights
            dW[layer] = d[layer]*nodeValues[layer-1].T
        # Return changes in weights
        return dW,d

    def train(self,xTrain,yTrain,xVal,yVal,batch_size):

        # Parition data into training, validation, and training
        training_set_size = xTrain.shape[0]

        # Start training in batches
        ET = []
        EV = []
        ET.append(self.score(xTrain,yTrain))
        EV.append(self.score(xVal,yVal))
        print('Batch 0')
        print('Training Accuracy: ' + str(ET[-1]))
        print('Validation Accuracy: ' + str(EV[-1]))
        for Batch in range(0,floor(len(xTrain)/batch_size)):
            secondChance = True
            dW = {}
            dB = {}
            for count in range(floor(Batch*batch_size),floor((Batch+1)*batch_size)):
                temp1,temp2 = self.backProp(xTrain[count],yTrain[count])
                for layer in range(1,len(temp1)+1):
                    if(len(dW) < len(temp1)):
                        dW[layer] = temp1[layer]
                        dB[layer] = temp2[layer]
                    else:
                        dW[layer] += temp1[layer]
                        dB[layer] += temp2[layer]
                for layer in range(1,len(temp1)+1):
                    dW[layer] = dW[layer]/float(batch_size)
                    dB[layer] = dB[layer]/float(batch_size)

            self.updateWeights(dW,dB)
            if(Batch%50 == 0):
                ET.append(self.score(xTrain,yTrain))
                EV.append(self.score(xVal,yVal))
                print('Batch ' + str(Batch+50))
                print('Training Accuracy: ' + str(ET[-1]))
                print('Validation Accuracy: ' + str(EV[-1]))
                if(len(EV) > 2):
                    if(EV[-2] != 0):
                        if((abs((ET[-2]-ET[-1])/ET[-2]) < 0.01 and ET[-1] > 0.05)):
                            if(self.stepSize[1][0][0] < 0.000001):
                                print('Converged')
                                return ET,EV
                            print('Adjusting LEARNING_RATE...')
                            for l in range(len(self.stepSize)):
                                self.stepSize[l+1] = self.stepSize[l+1] * 0.5
                        elif(abs((ET[-2]-ET[-1])/ET[-2]) < 0.01):
                            if(secondChance and self.stepSize[1][0][0] > 0.001):
                                secondChance = False
                                print('Adjusting LEARNING_RATE...')
                                for l in range(len(self.stepSize)):
                                    self.stepSize[l+1] = self.stepSize[l+1] * 0.5
                            else:
                                secondChance = True
                                print('Restarting...')
                                for layer in range(len(self.stepSize)):
                                    self.stepSize[layer+1] = np.ones([self.network_Arch[layer+1],self.network_Arch[layer]])
                                    self.Weights[layer+1] = np.matrix(np.random.randn(self.network_Arch[layer+1],self.network_Arch[layer]))

            
        return ET,EV

    def score(self,X,Y):
        c = 0
        for (count,example) in enumerate(X):
            l = np.argmax(self.getLabels(example))
            if(l==Y[count]):
                c += 1
        # Return percent of correct classifications
        return float(c)/(count+1)

    def copy(self):
        MM = NeuralNet(self.network_Arch, self.Weights, self.Biases, self.stepSize)
        return MM

def activation_fnct(X):
    Y = []
    for i in range(len(X)):
        Y.append(1.0/(1+exp(-X[i])))
    return np.array(Y).reshape(-1,1)
    # return np.maximum(X,0)

def DifRegFunc(X):
    return np.multiply(X,(1-X))
    # return np.multiply(X,X>0)

def DifErrFunc(Y,YHat):
    dif = -YHat
    dif[int(Y)] = 1+dif[int(Y)]
    return dif

def initializeNN(LEARNING_RATE,LAYER_COUNT,HIDDEN_UNITS,num_of_classes,num_of_parameters):
    # Define network architecture
    network_Arch = [num_of_parameters]
    for l in range(LAYER_COUNT):
        network_Arch.append(HIDDEN_UNITS)
    network_Arch.append(num_of_classes)

    # Initiailize neural netowrk
    Weights = {}
    Biases = {}
    stepSize = {}
    for layer in range(1,len(network_Arch)):
        Weights[layer] = np.matrix(np.random.randn(network_Arch[layer],network_Arch[layer-1]))
        Biases[layer] = np.matrix(np.random.randn(network_Arch[layer],1))
        stepSize[layer] = np.ones([network_Arch[layer],network_Arch[layer-1]])*LEARNING_RATE
    return NeuralNet(network_Arch,Weights,Biases,stepSize)

def kFold(NN,X,Y,KFOLD,BATCH_SIZE):
    # train network in batches with k-fold validation
    training_set_size = X.shape[0]
    foldSize = training_set_size/KFOLD
    EV = []
    ET = []
    for k in range(KFOLD):
        print('Fold: ' + str(k))
        MM = initializeNN(NN.stepSize[1][0][0],len(NN.network_Arch),NN.network_Arch[1],NN.network_Arch[-1],NN.network_Arch[0])
        et,ev = MM.train(np.vstack([X[0:int(k*foldSize),:],X[int((k+1)*foldSize):,:]]),np.vstack([Y[0:int(k*foldSize),:],Y[int((k+1)*foldSize):,:]]),
            X[int(k*foldSize):int((k+1)*foldSize),:],Y[int(k*foldSize):int((k+1)*foldSize),:],BATCH_SIZE)

        EV.append(ev)
        ET.append(et)    

    return EV,ET,MM


# Load data
Y = np.loadtxt("train_y.csv", delimiter=",").reshape(-1,1)
X = np.loadtxt("features.csv", delimiter=",")

# Get data sizes
training_set_size, num_of_parameters = X.shape
num_of_classes = len(np.unique(Y))

# Normalize features
for i in range(training_set_size):
    X[i,:] = (X[i,:]-np.mean(X[i,:]))/np.std(X[i,:])

# computed number -> class label
A = np.unique(Y) == Y
for y in range(0,training_set_size):
    Y[y] = np.argmax(A[y]).astype('int')

# HYPERPARAMETERS
LEARNING_RATE = 0.16
HIDDEN_UNITS = 70
LAYER_COUNT = 2
KFOLD = 5
BATCH_SIZE = 1

EV = []
ET = []

NN = initializeNN(LEARNING_RATE,LAYER_COUNT,HIDDEN_UNITS,num_of_classes,num_of_parameters)
[ev,et,MM] = kFold(NN,X[:5000],Y[:5000],KFOLD,BATCH_SIZE)
EV.append(ev)
ET.append(et)

