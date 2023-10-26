function sampleSettings=readSampleSettings(userSettings)
%----------------------------------------------------------------------------------------------------
% @file name:   readSampleSettings.m
% @description: Read the contents of the sample settings information file
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.01.22
%----------------------------------------------------------------------------------------------------
% @param:
% userSettings.
%    sampleSettingFileName: file name
%    instrumentId: = 1, coulter LS Serials; =11, camsizer X2; =21, malvern MasterSizer Serials
% @return: 
% sampleSettings.
%            dataPath: path of the raw data
%            fileName: file name of the raw data
%                name: sample name
%            sampleId: sample id, numeric and unique
%             discard: discard flag
%                      =0, the sample data is valid
%                      =1, discard the sample data
%        minValidSize: minimum valid particle size, in unit of um
%        maxValidSize: maximum valid particle size, in unit of um
%           groupName: Name of sample grouping
%             groupId: id of sample grouping, numeric and unique
%   exportToAnalySize: export the sample data to AnalySize
%                      =0, disable
%                      =1, enable
% @others:
%    format of the user setting file:
%    1) First row is fixed as the table header with comma seperated columns, allways is:
%       "dataPath,fileName,name,sampleId,discard,minValidSize,maxValidSize,gourpName,gourpId,exportToAnalySize"
%    2) Starting on the second row, each row represent one sample record with comma spacing: 
%       column 01, sample data path
%       column 02, sample file name
%       column 03, sample name
%       column 04, sample id, numeric and unique
%       column 05, discard flag,0: valid sample data; 1: discard the sample data
%       column 06, minimum valid particle size, in unit of um
%       column 07, maximum valid particle size, in unit of um
%       column 08, Name of sample grouping
%       column 09, id of sample grouping, numeric and unique
%       column 10, export the sample data to AnalySize. =0, disable; =1, enable
% @references:
% NONE
%----------------------------------------------------------------------------------------------------
if exist(sampleSettingFileName,"file")==false
    %fresh data firstly to be processed, prepare an example file.
    sampleSettings=[];
    switch userSettings.instrumentId
        case 1
            rawData=readCoulterLsData(userSettings);
        case 11
            rawData=readCamSizerData(userSettings);
        case 21
            rawData=readMalvernData(userSettings);
    end
    nSample=length(rawData);
    if nSample>0
        if strcmpi(userSettings.language,'en')
            fidout=fopen(userSettings.sampleSettingFileName,"wt","n","UTF-8");
        else
            fidout=fopen(userSettings.sampleSettingFileName,"wt","n","GB2312");
        end
    else
        return;
    end
    fprintf(fidout,'dataPath,fileName,name,sampleId,discard,minValidSize,maxValidSize,gourpName,gourpId,exportToAnalySize\n');
    for iSample=1:nSample
        fprintf(fidout,'%s,%s',rawData(iSample).dataPath,rawData(iSample).fileName);
        fprintf(fidout,',%s,%d,0',rawData(iSample).sampleName,rawData(iSample).sampleId);
        fprintf(fidout,',%.1f,%.1f',rawData(iSample).validSizeLim(1),rawData(iSample).validSizeLim(1));
        fprintf(fidout,',%.1f,%.1f',rawData(iSample).validSizeLim(1),rawData(iSample).validSizeLim(1));
        fprintf(fidout,',%s,%d,1\n',rawData(iSample).gourpName,rawData(iSample).gourpId);
    end
    fclose(fidout);
else
    sampleSettings=readtable(userSettings.sampleSettingFileName,'ReadVariableNames',true,'Delimiter','\t');
end