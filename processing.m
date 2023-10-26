function processing(userSettings)
%----------------------------------------------------------------------------------------------------
% @file name:   processing.m
% @description: Main processing flow of GS-Package
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.1, 2023.10.22
%----------------------------------------------------------------------------------------------------
sampleSettings=readSampleSettings(userSettings);
switch userSettings.instrumentId
    case 1
        rawData=readCoulterLsData(userSettings,sampleSettings);
    case 11
        rawData=readCamSizerData(userSettings,sampleSettings);
    case 21
        rawData=readMalvernData(userSettings,sampleSettings);
end
if (isempty(sampleSettings))&&(~isempty(rawData))
    warndlg("Warning: This is the first time the raw data has been processed and the sample setting information file has not been edited.");
end
if ~isempty(rawData)
    statisticalParams=calcStatisticalParams(rawData,userSettings);
    exportDataReport(statisticalParams,userSettings);
    exportForAnalySize(statisticalParams,userSettings);
    plotClassificationScheme(statisticalParams,userSettings);
else
    warndlg("No valid Coulter-data file in the specified path.");
end
