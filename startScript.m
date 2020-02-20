%% start Script
clc
disp('-- Start Script')

%% add path
addpath('MeasurementData') 
addpath('functions') 
addpath('TSC') 
% addpath('old')  

%% load default Dataset

load('Testfahrt_2020_02_18.mat')

%% start Simulink Auswertung

run('Analyse_Data_LORD.slx')

disp('-- finished')


