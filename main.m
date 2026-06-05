clc
clear all
close all

load('OrbitalResults.mat')

model = fea_builder();

fun_mod = @(X) fun(TimeEpSec,S,AngleX,AngleY,AngleZ,AngleAlb,Q_comp_c,Q_comp_h,model,X);

plus_x_left = optimizableVariable('plus_x_left',[0.01,0.11]);
plus_x_right = optimizableVariable('plus_x_right',[0.31,0.49]);
plus_x_down = optimizableVariable('plus_x_down',[0.01,0.11]);
plus_x_up = optimizableVariable('plus_x_up',[0.39,0.49]);
minus_x_left = optimizableVariable('minus_x_left',[0.01,0.11]);
minus_x_right = optimizableVariable('minus_x_right',[0.39,0.49]);
minus_x_down = optimizableVariable('minus_x_down',[0.01,0.11]);
minus_x_up = optimizableVariable('minus_x_up',[0.39,0.49]);
plus_y_left = optimizableVariable('plus_y_left',[0.01,0.11]);
plus_y_right = optimizableVariable('plus_y_right',[0.39,0.49]);
plus_y_down = optimizableVariable('plus_y_down',[0.01,0.11]);
plus_y_up = optimizableVariable('plus_y_up',[0.39,0.49]);

results = bayesopt(fun_mod,[plus_x_left,plus_x_right,plus_x_down,plus_x_up,minus_x_left,minus_x_right,minus_x_down,minus_x_up,plus_y_left,plus_y_right,plus_y_down,plus_y_up],...
    'IsObjectiveDeterministic',true,'NumCoupledConstraints',1,'Verbose',0,'AcquisitionFunctionName','expected-improvement-plus','MaxObjectiveEvaluations',120);

%,'UseParallel',true
save('opt_results_v2.mat')

