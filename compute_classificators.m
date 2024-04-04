clear;
close all;

load("features_data.mat");

%creiamo l'oggetto cvpartition
cv = cvpartition(labels, "holdout", 0.2);

example = test_classifier_cart(qhist, labels, cv);
example.test_perf.accuracy
example = test_classifier_cart(CEDD, labels, cv);
example.test_perf.accuracy
example = test_classifier_cart(lbp, labels, cv);
example.test_perf.accuracy
%example = test_classifier_bayes(qhist, labels, cv);
%example.test_perf.accuracy
%example = test_classifier_bayes(CEDD, labels, cv);
%example.test_perf.accuracy
%example = test_classifier_bayes(lbp, labels, cv);
%example.test_perf.accuracy
example = test_classifier_knn(qhist, labels, cv, 54);
example.test_perf.accuracy
example = test_classifier_knn(CEDD, labels, cv, 54);
example.test_perf.accuracy
example = test_classifier_knn(lbp, labels, cv, 54);
example.test_perf.accuracy

%concatenazione di feature per cercare di aumentare l'accuratezza (nel mio
%caso di partizionamento peggiora l'accuratezza
f1 = cat(2, lbp, qhist);
example = test_classifier_cart(f1, labels, cv);
example.test_perf.accuracy
example = test_classifier_knn(f1, labels, cv, 54);
example.test_perf.accuracy