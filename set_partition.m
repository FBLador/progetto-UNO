load("features_data.mat");

%partiziona il data set in training e test set, con 20% di dati per il test
%e resto per il training
cv = cvpartition(labels, "HoldOut", 0.3);

%creo una struttura train con dentro le immagini che sono state scelte da
%cvpartition come immagini di training, faccio lo stesso con il resto
train.images = images(cv.training(1));
train.labels = labels(cv.training(1));
train.lbp    = lbp(cv.training(1));
train.qhist  = qhist(cv.training(1));
train.CEDD   = CEDD(cv.training(1));

%creo una struttura test con dentro le immagini che sono state scelte da
%cvpartition come immagini di test, faccio lo stesso con il resto
test.images = images(cv.test(1));
test.labels = labels(cv.test(1));
test.lbp    = lbp(cv.test(1));
test.qhist  = qhist(cv.test(1));
test.CEDD   = CEDD(cv.test(1));

%salvo
save("train_test_set.mat", "train", "test");