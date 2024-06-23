% Deep learning neural network with residual connection (ResNet)
% For many applications, using a network that consists of a simple sequence of layers is sufficient.
% However, some applications require networks with a more complex graph structure in which layers
% can have inputs from multiple layers and outputs to multiple layers. 
% These types of networks are often called directed acyclic graph (DAG) networks. 
% A residual network (ResNet) is a type of DAG network that has residual (or shortcut)
% connections that bypass the main network layers.
% Residual connections enable the parameter gradients to propagate more easily from the output
% layer to the earlier layers of the network, which makes it possible to train deeper networks. 
% This increased network depth can result in higher accuracies on more difficult tasks.
% https://it.mathworks.com/help/deeplearning/ug/train-residual-network-for-image-classification.html?searchHighlight=Image%20Classification&s_tid=srchtitle_support_results_1_Image%20Classification

close all;

% Load data and make every class of equal size (size of class with lowest number of images)
imds = imageDatastore('data_no_colors','IncludeSubfolders',true, 'LabelSource','foldernames');

% Show the number of images per category
tbl = countEachLabel(imds)

% Separate the sets into training and validation data. Pick 60% of images from each set for the training data and the remainder, 40%, for the validation data.
% Randomize the split to avoid biasing the results.
[trainingSet, validationSet] = splitEachLabel(imds, 0.6, 'randomize');

% La data augmentation è particolarmente utile per piccoli dataset.
% Le trasformazioni di rotazione, traslazione e scala aumentano artificialmente la varietà dei dati di training,
% migliorando la capacità della rete di generalizzare. Se prima, ad ogni
% epoca, veniva ri-analizzato lo stesso dataset, ora ad ogni epoca la rete
% riceverà immagini potenzialmente modificate dall'imageDataAugmenter.
% L’aumento dei dati aiuta la rete ad evitare l’overfitting e a memorizzare i dettagli esatti delle immagini di addestramento.
imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-20 20], ...
    'RandXTranslation',[-5 5], ...
    'RandYTranslation',[-5 5], ...
    'RandScale', [0.8 1.2], ...
    'RandXShear', [-20 20]);

% augmentedImageDatastore ridimensiona esclusivamente le immagini per
% adattarle alle dimensioni specificate e alle ulteriori impostazioni
% definite (ColorPreprocessing e DataAugmentation)
imageSize=[224 224 1];

augmentedTrainingSet = augmentedImageDatastore(imageSize, trainingSet, ColorPreprocessing="rgb2gray", DataAugmentation=imageAugmenter);
augmentedValidationSet = augmentedImageDatastore(imageSize, validationSet,'ColorPreprocessing','rgb2gray');

% Define resnet architecture
numClasses = 16;
initialFilterSize = 3;
numInitialFilters = 64;
initialStride = 2;
numFilters = [16 32 64];
stackDepth = [4 3 2];

layers = resnetLayers(imageSize, numClasses, ...
    InitialFilterSize=initialFilterSize, ...
    InitialNumFilters=numInitialFilters, ...
    InitialStride=initialStride, ...
    InitialPoolingLayer="max", ...
    StackDepth=stackDepth, ... 
    NumFilters=numFilters);

% Specify the training options. Choosing among the options requires empirical analysis.
% To explore different training option configurations by running experiments, you can use the Experiment Manager app.
% Adam is the best among the adaptive optimizers in most of the cases.
% accuracyMetric return an object to record and plot the training and validation accuracy.
miniBatchSize = 64;
%learnRate = 0.1*miniBatchSize/128;
learnRate = 0.01;
%valFrequency = floor(size(augmentedTrainingSet.Files, 1)/miniBatchSize);
valFrequency = 50;
options = trainingOptions("rmsprop", ...
    InitialLearnRate=learnRate, ...
    MaxEpochs=250, ...
    MiniBatchSize=miniBatchSize, ...
    VerboseFrequency=valFrequency, ...
    ValidationPatience=15, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false, ...
    ValidationData=augmentedValidationSet, ...
    ValidationFrequency=valFrequency, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropFactor=0.5, ...
    LearnRateDropPeriod=20);

% Train the neural network using the trainNetwork function.By default, the trainnet function uses a GPU if one is available.
% Using a GPU requires a Parallel Computing Toolbox™ license and a supported GPU device.
% Otherwise, the function uses the CPU
net = trainNetwork(augmentedTrainingSet, layers, options);
save("ResNetClassifierNew.mat", "net");



