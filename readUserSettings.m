function userSettings=readUserSettings(userSettingFileName)
%----------------------------------------------------------------------------------------------------
% @file name:   readUserSettings.m
% @description: Read the contents of the user settings information file
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.01.22
%----------------------------------------------------------------------------------------------------
% @param:
% userSettingFileName, file name
% @return: 
% userSettings(nSample).
%            dataPath: path of the raw data
%            fileName: file name of the raw data
%                name: sample name
%            sampleId: sample id, numeric and unique
%             discard: discard flag
%                      =0, the sample data is valid
%                      =1, discard the sample data
%        minValidSize: minimum valid particle size, in unit of mm
%        maxValidSize: maximum valid particle size, in unit of mm
%           groupName: Name of sample grouping
%             groupId: id of sample grouping, numeric and unique
%   exportToAnalySize: export the sample data to AnalySize
%                      =0, disable
%                      =1, enable
% @others:
%    format of the user setting file:
%    1) First row is fixed as the table header with tab spacing between columns, allways is:
%       dataPath fileName   name    sampleId   discard minValidSize    maxValidSize    gourpName   gourpId exportToAnalySize
%    2) Starting on the second row, each row represent one sample record with tab spacing: 
%       column 01, sample data path
%       column 02, sample file name
%       column 03, sample name
%       column 04, sample id, numeric and unique
%       column 05, discard flag,0: valid sample data; 1: discard the sample data
%       column 06, minimum valid particle size, in unit of mm
%       column 07, maximum valid particle size, in unit of mm
%       column 08, Name of sample grouping
%       column 09, id of sample grouping, numeric and unique
%       column 10, export the sample data to AnalySize. =0, disable; =1, enable
% @references:
% NONE
%----------------------------------------------------------------------------------------------------
if exist(userSettingFileName,"file")==false
    userSettings=[];
    return;
end

userSettings=readtable(userSettingFileName,'ReadVariableNames',true,'Delimiter','\t');
