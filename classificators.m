clear;
close all;

load("features_data.mat");

%creiamo l'oggetto cvpartition
cv = cvpartition(labels, "holdout", 0.3);

example1 = test_classifier_cart(qhist, labels, cv);
example1.test_perf.accuracy
example2 = test_classifier_cart(CEDD, labels, cv);
example2.test_perf.accuracy
example3 = test_classifier_cart(lbp, labels, cv);
example3.test_perf.accuracy
%example4 = test_classifier_bayes(qhist, labels, cv);
%example4.test_perf.accuracy
%example5 = test_classifier_bayes(CEDD, labels, cv);
%example5.test_perf.accuracy
%example6 = test_classifier_bayes(lbp, labels, cv);
%example6.test_perf.accuracy
example7 = test_classifier_knn(qhist, labels, cv, 3);
example7.test_perf.accuracy
example8 = test_classifier_knn(CEDD, labels, cv, 3);
example8.test_perf.accuracy
example9 = test_classifier_knn(lbp, labels, cv, 3);
example9.test_perf.accuracy

%concatenazione di feature per cercare di aumentare l'accuratezza (nel mio
%caso di partizionamento peggiora l'accuratezza
f1 = cat(2, lbp, CEDD);
example10 = test_classifier_cart(f1, labels, cv);
example10.test_perf.accuracy
example11 = test_classifier_knn(f1, labels, cv, 3);
example11.test_perf.accuracy