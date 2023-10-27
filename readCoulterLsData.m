function rawData=readCoulterLsData(userSettings,sampleSettings)
%----------------------------------------------------------------------------------------------------
% @file name:   readCoulterLsData.m
% @description: Batch read all *.$ls data files in the Coulter data directory
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.1, 10/21/2023
%----------------------------------------------------------------------------------------------------
% userSettings.
%             dataPath: full path of the data files
%     forceReadRawData:
%            = true  allways read data from raw files
%            = false load the rawData.mat if exists in the dataPath; otherwise, read data from raw files
%  MIN_CHANNEL_SIZE_UM: lower limit of instrument detection (um), should be greater than 0, default is 0.01um
%  MAX_CHANNEL_SIZE_UM: upper limit of instrument detection (um), default is 10mm
%         instrumentId: = 1, coulter LS Serials; =11, camsizer X2; =21, malvern MasterSizer Serials
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
%
% @return:
% rawData.
%           dataPath: full path of the raw-data file
%           fileName: file name of the raw-data file
%       instrumentId: instrument code, here is 1
%                     = 1, coulter LS 13320
%                     =11, camsizer X2
%                     =21, malvern
%                     =99, unknown
%          groupName: sample group
%            groupId: unique numeric id of the group
%         sampleName: sample name
%           sampleId: unique numeric id of the sample
%  exportToAnalySize: export the sample data to AnalySize. =0, disable; =1, enable
%         configInfo: configuration file name of the instrument (xxx.cfg)
%               type: Rules for particle size statistics(string), here is 'x_area'
%                     ='xc_min', perpendicular to sieving methods
%                     ='x_area', perpendicular to laser diffraction methods
%                     ='xFemin', perpendicular to the width of the vernier methods
%                     ='xFemax', perpendicular to the length of the vernier methods
%                     ='xMamin', martin diameter
%       analysisTime: Time to start on-board measurements(datetime)
%       validSizeLim: user defined valid range of grainsize [minLim(um),maxLim(um)]
%     analysisPeriod: measurement period(s)
%        obscuration: obscuration(%), only for laser diffraction method
%          pumpSpeed: pump speed, only for laser diffraction method
%                SSa: specific surface area, only for laser diffraction method
%  waterRefractivity: water refractivity, only for laser diffraction method
%particleRefractivity: particle refractivity, only for laser diffraction method
%particleAbsorptivity: particle absorptivity, only for laser diffraction method
%    channelDownSize: lower limit size of the channel(um)
%      channelUpSize: upper limit size of the channel(um)
%     channelMidSize: logarithmic midpoint size of the channel(um)
%                 p3: raw differential volume(%)
%                 q3: raw cumulative volume(%)
%           adjustP3: differential volume percentage after removal of invalid components (%)
%           adjustQ3: cumulative volume percentage after removal of invalid components (%)
%      haveShapeData: , here is 0
%                = 0, no particle shape information
%                = 1, particle shape information only indexed by particle size
%                = 2, particle shape information both indexed by particle size and normalized shape factor
%              spht3: sphericity, =4*pi*area/(round^2)
%              symm3: Symmetry
%               b_l3: Aspect ratio = Xc_min (particle width: sieve size)/XFe_Max (particle length)
%            B_LRec3: Minimum aspect ratio = min(Xc/XFe)
%            sigmav3: Standard deviation of ?
%              conv3: Convexity = sqrt(real area / convex particle area)
%             rdnsc3: Roundness, ratio of the averaged radius of curvature of all convex regions to the circumscribed cricle of the particle
%                pdv: volume-based number of particle detections
%    channelMeanSize: mean value of the particle size
%channelSize_xFe_avg: average feret diameter
%channelSize_xMa_avg: average martin diameter
% channelSize_xc_avg: average chord diameter
%channelSize_xFe_min: minimum feret diameter, particle width
%channelSize_xMa_min: minimum martin diameter, paticle thickness
% channelSize_xc_min: minimum chord diameter, sieve size
%channelSize_xFe_max: maxmum feret diameter, paticle length
%channelSize_xMa_max: maxmum martin diameter
% channelSize_xc_max: maxmum chord diameter
%   channelDownShape: lower limit of normalized shape index(0~1), only when haveShapeData==2
%     channelUpShape: upper limit of normalized shape index(0~1), only when haveShapeData==2
%    channelMidShape: logarithmic midpoint of normalized shape index(0~1), only when haveShapeData==2
%             q3Spht: cumulative volume percentage of sphericity, only when haveShapeData==2
%             q3Symm: cumulative volume percentage of symmetry, only when haveShapeData==2
%             q3_b_l: cumulative volume percentage of aspect ratio, only when haveShapeData==2
%           q3B_LRec: cumulative volume percentage of minimum aspect ratio, only when haveShapeData==2
%           q3Sigmav: cumulative volume percentage of Sigmav, only when haveShapeData==2
%             q3Conv: cumulative volume percentage of convexity, only when haveShapeData==2
%            q3Rdnsc: cumulative volume percentage of roundness, only when haveShapeData==2
%             q0Spht: cumulative number percentage of sphericity, only when haveShapeData==2
%             q0Symm: cumulative number percentage of symmetry, only when haveShapeData==2
%             q0_b_l: cumulative number percentage of aspect ratio, only when haveShapeData==2
%           q0B_LRec: cumulative number percentage of minimum aspect ratio, only when haveShapeData==2
%           q0Sigmav: cumulative number percentage of Sigmav, only when haveShapeData==2
%             q0Conv: cumulative number percentage of convexity, only when haveShapeData==2
%            q0Rdnsc: cumulative number percentage of roundness, only when haveShapeData==2
%            sfCorey: Corey shape factor=channelSize_xMa_min/sqrt(channelSize_xFe_min*channelSize_xFe_max)
% @references:
% NONE
%----------------------------------------------------------------------------------------------------
rawData={};

if userSettings.dataPath(end)~='\'
    userSettings.dataPath(end+1)='\';
end

hidWait=waitbar(0,'Reading Coulter data, please wait...');
if exist([userSettings.dataPath,'rawData.mat'],'file')&&(userSettings.forceReadRawData==false)
    load([userSettings.dataPath,'rawData.mat'],'-mat','rawData');
    close(hidWait);
    return;
end

suffix='.$ls';
tempVar=dir([userSettings.dataPath,'*',suffix]);
allFile=char(tempVar.name);
sampleNum=size(allFile,1);
validFileNum=0;
if sampleNum<1
    close(hidWait);
    return;
end

backslashId=strfind(userSettings.dataPath,'\');
if length(backslashId)<=1
    lastLevelDataPath=userSettings.dataPath;  % root dir, for example: "c:\"
else
    lastLevelDataPath=userSettings.dataPath(backslashId(end-1)+1:backslashId(end)-1);
end
%
for iSample=1:sampleNum
    %readdata
    thisDataFileName=allFile(iSample,:);

    fidIn=fopen(strcat(userSettings.dataPath,thisDataFileName),'r');

    thisSampleName=thisDataFileName(1:end-3);
    thisDiscardFlag=false;
    thisSampleId=nan;
    validSizeLim=[0,inf];
    thisGroupName='undefined';
    thisGroupId=-999;
    exportToAnalySize=1;

    getValidDataFlag=false;
    recordStarted=false;
    thisSampleData=zeros(500,2);
    diamChannelNum=0;
    hightChannelNum=0;
    serialNumber='';


    while ~feof(fidIn)
        tempStr=fgetl(fidIn);
        if (strcmpi(tempStr,'[sample]')==true)&&(recordStarted==false)
            recordStarted=true;
        elseif recordStarted==false
            continue;
        end
        if contains(tempStr,'GroupID=')
            if thisGroupId<-998
                thisGroupName=strrep(tempStr,'GroupID=','');
            end
        elseif contains(tempStr,'SampleID=')
            thisSampleName=strrep(tempStr,'SampleID=','');
            % retrieve user settings
            if ~isempty(sampleSettings)
                userSetRecordNum=length(sampleSettings.name);
                for iSet=1:userSetRecordNum
                    % sample search principle: file name and directory are the same
                    if (strcmpi(strrep(thisDataFileName,' ',''),strrep(sampleSettings.fileName{iSet},' ',''))==true)&&(strcmpi(lastLevelDataPath,sampleSettings.dataPath{iSet})==true)
                        if sampleSettings.discard(iSet)==1
                            thisDiscardFlag=true;
                        end
                        thisSampleName=sampleSettings.name{iSet};
                        validSizeLim=[sampleSettings.minValidSize(iSet),sampleSettings.maxValidSize(iSet)];
                        thisGroupName=sampleSettings.groupName{iSet};
                        thisGroupId=sampleSettings.groupId(iSet);
                        thisSampleId=sampleSettings.sampleId(iSet);
                        exportToAnalySize=sampleSettings.exportToAnalySize(iSet);
                        break;
                    end
                end
            end
            if thisDiscardFlag==true
                break;
            end

            validFileNum=validFileNum+1;
            rawData(validFileNum).instrumentId=userSettings.instrumentId;
            rawData(validFileNum).sampleName=thisSampleName;
            if isnan(thisSampleId)
                thisSampleId=-validFileNum;
            end
            rawData(validFileNum).sampleId=thisSampleId;
            rawData(validFileNum).groupName=thisGroupName;
            rawData(validFileNum).groupId=thisGroupId;
            rawData(validFileNum).dataPath=userSettings.dataPath;
            rawData(validFileNum).fileName=thisDataFileName;
            rawData(validFileNum).exportToAnalySize=exportToAnalySize;
            rawData(validFileNum).configInfo='';
            rawData(validFileNum).type='x_area';
            rawData(validFileNum).analysisTime=[];
            rawData(validFileNum).validSizeLim=validSizeLim;
            rawData(validFileNum).analysisPeriod=0;
            rawData(validFileNum).obscuration=0;
            rawData(validFileNum).pumpSpeed=0;
        elseif contains(tempStr,'StartTime=')
            rawData(validFileNum).analysisTime=str2double(tempStr(12:21))/3600/24+8/24+datetime('1970/1/1');
        elseif contains(tempStr,'RunTime=')
            rawData(validFileNum).analysisPeriod=str2double(strrep(tempStr,'RunTime=',''));
        elseif contains(tempStr,'OMfile=')
            rawData(validFileNum).configInfo=strrep(tempStr,'OMfile=','');
        elseif contains(tempStr,'OMRIs=')
            rawData(validFileNum).configInfo=[rawData(validFileNum).configInfo,',',tempStr];
            omris=str2num(tempStr(7:end)); %#ok<*ST2NM>
            rawData(validFileNum).waterRefractivity=omris(2);
            rawData(validFileNum).particleRefractivity=omris(6);
            rawData(validFileNum).particleAbsorptivity=omris(10);
        elseif contains(tempStr,'AnalyzePIDS=')
            rawData(validFileNum).configInfo=[rawData(validFileNum).configInfo,',',tempStr,',SN= ',serialNumber];
        %elseif strcmpi(tempStr,'LSType= 330')==true
        %    rawData(validFileNum).instrumentId=userSettings.instrumentId;
        elseif contains(tempStr,'SerialNumber=')==true
            serialNumber=strrep(tempStr,'SerialNumber= ','');
        elseif strcmpi(tempStr,'[#Bindiam]')==true
            thisSampleData=zeros(500,2);
            while (~feof(fidIn))
                tempStr=fgetl(fidIn);
                if tempStr(1)=='['
                    break;
                else
                    diamChannelNum=diamChannelNum+1;
                end
                thisSampleData(diamChannelNum,1)=str2double(tempStr);
            end
        elseif (strcmpi(tempStr,'[#Binheight]')==true)
            while (~feof(fidIn))
                tempStr=fgetl(fidIn);
                if tempStr(1)=='['
                    break;
                else
                    hightChannelNum=hightChannelNum+1;
                end
                thisSampleData(hightChannelNum,2)=str2double(tempStr);
            end
            if (hightChannelNum>0)&&(hightChannelNum==diamChannelNum)
                getValidDataFlag=true;
                thisSampleData=thisSampleData(1:hightChannelNum,:);
                thisSampleData(:,2)=thisSampleData(:,2)./sum(thisSampleData(:,2)).*100;
            elseif validFileNum>0
                validFileNum=validFileNum-1;
                getValidDataFlag=false;
            end
        elseif (strcmpi(tempStr,'[#DiffObs]')==true)
            obscuration=0;
            obsNum=0;
            while (~feof(fidIn))
                tempStr=fgetl(fidIn);
                if tempStr(1)=='['
                    break;
                else
                    obsNum=obsNum+1;
                end
                obscuration=obscuration+str2double(tempStr);
            end
            if (obsNum>0)
                obscuration=obscuration/obsNum*100;
                rawData(validFileNum).obscuration=obscuration;
            end
        elseif contains(tempStr,'ALMPumpSpeed= ')
            pwmVal=str2double(strrep(tempStr,'ALMPumpSpeed= ',''));
            rawData(validFileNum).pumpSpeed=0.4757281553 * pwmVal - 21.3106796117;
        end
    end
    fclose(fidIn);

    if getValidDataFlag==true
        rawData(validFileNum).channelDownSize=[userSettings.MIN_CHANNEL_SIZE_UM;thisSampleData(1:end-1,1)];
        rawData(validFileNum).channelUpSize=[thisSampleData(1:end,1)];
        userSettings.MAX_CHANNEL_SIZE_UM=max([userSettings.MAX_CHANNEL_SIZE_UM,max(rawData(validFileNum).channelDownSize)]);
        rawData(validFileNum).channelUpSize(rawData(validFileNum).channelUpSize>userSettings.MAX_CHANNEL_SIZE_UM)=userSettings.MAX_CHANNEL_SIZE_UM;
        thisSampleLogMidSize=(log2(rawData(validFileNum).channelDownSize)+log2(rawData(validFileNum).channelUpSize))./2;
        rawData(validFileNum).channelMidSize=2.^(thisSampleLogMidSize);
        rawData(validFileNum).p3=thisSampleData(:,2);
        % reject the invalid components according to the user-defined "validSizeLim"
        inValidId=(rawData(validFileNum).channelUpSize<rawData(validFileNum).validSizeLim(1))|(rawData(validFileNum).channelDownSize>rawData(validFileNum).validSizeLim(2));
        newP3=rawData(validFileNum).p3;
        newP3(inValidId)=0;
        newP3=newP3./sum(newP3).*100;

        nChannel=length(newP3);
        q3=newP3.*0;
        newQ3=newP3.*0;
        for iChannel=1:nChannel
            q3(iChannel)=sum(rawData(validFileNum).p3(1:iChannel));
            newQ3(iChannel)=sum(newP3(1:iChannel));
        end
        rawData(validFileNum).q3=q3;
        rawData(validFileNum).adjustP3=newP3;
        rawData(validFileNum).adjustQ3=newQ3;
        rawData(validFileNum).haveShapeData=false;

        rawData(validFileNum).SSa=0;  %not available for Coulter
    end
    waitbar(iSample./sampleNum,hidWait);
end
close(hidWait);
if validFileNum<1
    rawData=[];
else
    save([userSettings.dataPath,'rawData.mat'],'rawData');
end