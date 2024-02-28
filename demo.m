%----------------------------------------------------------------------------------------------------
% @file name:   demo.m
% @description: A demostration code of GS-Package
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.10.26
%----------------------------------------------------------------------------------------------------
userSettings.sampleSettingFileName='D:\outputs\settings.csv'; %sample settings information file, not necessary
userSettings.dataPath='D:\';                     %full path of the raw data files
userSettings.outputPath='D:\outputs\';           %full path of the output files
userSettings.prefixString='all';                          %prefixes for archive file names
userSettings.prepareSampleSettingInfo=true;                         %= true, if userSettings.sampleSettingFileName not exist, generate a new one
userSettings.forceReadRawData=true;                                 %= true, allways read data from raw files;= false, load the rawData.mat if exists in the dataPath; otherwise, read data from raw files
userSettings.MIN_CHANNEL_SIZE_UM=0.05;                              %lower limit of instrument detection (um), should be greater than 0, default is 0.001um
userSettings.MAX_CHANNEL_SIZE_UM=1e4;                               %upper limit of instrument detection (um), default is 10mm
userSettings.GradationCurveFigWidth=7.13;                           %figure width of the gradation curve, in unit of cm
userSettings.GradationCurveFigHeight=6;                             %figure height of the gradation curve, in unit of cm
userSettings.language='cn';                                         %='cn', particle grading curves are labeled in Chinese;='en', particle grading curves are labeled in English
userSettings.userChannelSize=load('200ChannelOf8000.txt','-ascii'); %Specify uniform channel boundaries (samples are measured with several types of instruments with different channel-size definition), in um, example values [0.1,1,2,10:10:5000].
userSettings.exportGradingCurve=true;                               %output particle grading curve figures
userSettings.exportMetadata=true;                                   %output metadata report
userSettings.exportAllData=true;                                    %output all the statistical parameters
userSettings.exportUserComponent=true;                              %output statistical parameters of the user-speicified components
userSettings.exportClassificationScheme=true;                       %output diagnostic triangular phase map
userSettings.exportGBT12763=true ;                                  %output reports in accordance with GB/T12763.8
componentRank=[0.01,3.9,32,62.5,125,250,500,1000,2000,4000,8000]';  %size of the user-defined components,in unit of um
userSettings.componentDownSize=componentRank(1:end-1,1);            %upper size of the user components (um)
userSettings.componentUpSize=componentRank(2:end,1);                %lower size of the user components (um)
%-------------------------------------------------------------------
gs_package_processing_flow(userSettings);