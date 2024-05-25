% Simple Image Classification Network
% https://it.mathworks.com/help/deeplearning/gs/create-simple-deep-learning-classification-network.html?lang=en
% https://it.mathworks.com/help/deeplearning/gs/create-simple-deep-learning-classification-network.html?lang=en

close all;

% Load data and make every class of equal size (size of class with lowest number of images)
imds = imageDatastore('data_no_colors','IncludeSubfolders',true, 'LabelSource','foldernames');
%classes = {'back', 'card_0' , 'card_1', 'card_2', 'card_3' , 'card_4', 'card_5', 'card_6' , 'card_7', 'card_8', 'card_9' , 'draw_card', 'reverse_card', 'skip_card', 'wild' , 'wild_draw'};

% Balance the data count between of all classes.
% Make every class of equal size (size of class with lowest number of images)
%minClassCount = min(countEachLabel(imds).Count)
%index = find(countEachLabel(imds).Count == minClassCount);
%fprintf(1, "%s class with %d elements\n", classes{index(1)}, minClassCount);
%imds = partition(allImds{1}, minClassCount, 'sequential'); % Or 'randomize'

% Inspect the number of images per category
tbl = countEachLabel(imds)

% Separate the sets into training and validation data. Pick 60% of images from each set for the training data and the remainder, 40%, for the validation data.
% Randomize the split to avoid biasing the results.
[trainingSet, validationSet] = splitEachLabel(imds, 0.6, 'randomize');

% La data augmentation è particolarmente utile per piccoli dataset.
% Le trasformazioni di rotazione, traslazione e scala aumentano artificialmente la varietà dei dati di training,
% migliorando la capacità della rete di generalizzare.
% L’aumento dei dati aiuta la rete ad evitare l’overfitting e a memorizzare i dettagli esatti delle immagini di addestramento.
imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-10 10], ...
    'RandXTranslation',[-5 5], ...
    'RandYTranslation',[-5 5], ...
    'RandScale',[0.9 1.1]);

% augmentedImageDatastore ridimensiona esclusivamente le immagini per
% adattarle alle dimensioni specificate e alle ulteriori impostazioni
% definite (ColorPreprocessing e DataAugmentation)
inputSize=[224 224 1];

augmentedTrainingSet = augmentedImageDatastore(inputSize, trainingSet, ColorPreprocessing="rgb2gray", DataAugmentation=imageAugmenter);
augmentedValidationSet = augmentedImageDatastore(inputSize, validationSet,'ColorPreprocessing','rgb2gray');

% Define the convolutional neural network architecture.
% Specify the size of the images in the input layer of the network and the number of classes in the fully connected layer.
% Each image is 224-by-224-by-1 pixels and there are 16 classes
numClasses = 16;

layers = [
    imageInputLayer(inputSize)
    convolution2dLayer(5,20)
    batchNormalizationLayer
    reluLayer
    dropoutLayer    %aggiunto perchè sembra che una bassa validation accuracy sia sinonimo di overfitting
    fullyConnectedLayer(numClasses)
    softmaxLayer];

% Specify the training options. Choosing among the options requires empirical analysis.
% To explore different training option configurations by running experiments, you can use the Experiment Manager app.
% Adam is the best among the adaptive optimizers in most of the cases.
% accuracyMetric return an object to record and plot the training and validation accuracy.
metric = accuracyMetric(AverageType="macro")

options = trainingOptions('adam', ...
    'MaxEpochs',20, ...                 % 20 epoche è un buon punto di partenza per evitare l'overfitting per il nostro dataset relativamente piccolo. Se si nota che la rete non raggiunge una buona accuratezza di validazione dopo 20 epoche, puoi aumentarne il numero.
    'Metrics',metric, ...
    'InitialLearnRate',0.0001, ...      % Un learning rate più basso può aiutare a stabilizzare l'addestramento. Con un dataset piccolo, un learning rate troppo alto potrebbe causare fluttuazioni nei valori di perdita
    'MiniBatchSize',32, ...             % Batch size ragionevole per bilanciare memoria e velocità di addestramento
    'ValidationData',augmentedValidationSet, ...
    'ValidationFrequency',50, ...
    'Verbose',false, ...                % Disabilita l'output in console
    'Plots','training-progress', ...    % Visualizza il progresso dell'addestramento
    'Metrics','accuracy', ...
    'Shuffle','every-epoch', ...        % Mescola i dati ad ogni epoca
    'ValidationPatience',5);            % Previene overfitting terminando l'addestramento se la validazione non migliora per 5 epoche        

% Train the neural network using the trainnet function. For classification, use cross-entropy loss. By default, the trainnet function uses a GPU if one is available.
% Using a GPU requires a Parallel Computing Toolbox™ license and a supported GPU device.
% Otherwise, the function uses the CPU
[net, info] = trainnet(augmentedTrainingSet, layers, "crossentropy", options);
save("SimpleCNNClassifier.mat", "net");

% Classify the training data and calculate classification and validation accuracy.
info.TrainingHistory
info.ValidationHistory


%scores = classify(net, augmentedTrainingSet);

%YTraining = trainingSet.Labels;
%trainingAccuracy = mean(scores == YTraining)


%TValidation = validationSet.Labels;
%accuracy = mean(YValidation == TValidation)













