function exportForAnalySize(statisticalParams,userSettings)
%----------------------------------------------------------------------------------------------------
% @file name:   exportForAnalySize.m
% @description: Outputs data reports that can be imported into AnalySize software for end element analysis.
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.10.05
%----------------------------------------------------------------------------------------------------
% @param:
% statisticalParams.
%           dataPath: full path of the raw data file
%           fileName: file name of the raw data file
%       instrumentId: instrument code
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
%               type: Rules for particle size statistics(string)
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
%      haveShapeData:
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
%  userSettings.
%         outputPath: full path of the output files
%       prefixString: Prefixes for archive file names
%           language: 
%               ='cn'   Particle grading curves are labeled in Chinese
%               ='en'   Particle grading curves are labeled in English
%    userChannelSize: Specify uniform channel boundaries (samples are measured with several types of instruments with 
%                     different channel-size definition), in um, example values [0.1,1,2,10:10:5000].
% @references:
% https://github.com/greigpaterson/AnalySize
%----------------------------------------------------------------------------------------------------
nSample=length(statisticalParams);

if userSettings.userChannelSize(1)<1e-3
    userSettings.userChannelSize(1)=1e-3;
end
midSize_phi=(-log2(userSettings.userChannelSize(1:end-1)./1000)-log2(userSettings.userChannelSize(2:end)./1000))./2;
midSize_um=(2.^(-midSize_phi)).*1000;
nChannel=length(midSize_um);
outputfileName=[userSettings.outputPath,userSettings.prefixString,'_For_Analysize','.dat'];
if strcmpi(userSettings.language,'cn')
    fidout=fopen(outputfileName,"wt","n","GB2312");
else
    fidout=fopen(outputfileName,"wt","n","UTF-8");
end
%
fprintf(fidout,'Grain Size');
for iChannel=1:nChannel
    fprintf(fidout,'\t%.1f',midSize_um(iChannel));
end
fprintf(fidout,'\n');
%
for iSample=1:nSample
    if statisticalParams(iSample).exportToAnalySize>0
        newQ3=interp1(statisticalParams(iSample).channelUpSize,statisticalParams(iSample).adjustQ3,userSettings.userChannelSize);
        newP3=diff(newQ3);
        fprintf(fidout,'%s(%d)',statisticalParams(iSample).sampleName,statisticalParams(iSample).sampleId);
        for iChannel=1:nChannel
            fprintf(fidout,'\t%.3f',newP3(iChannel));
        end
        fprintf(fidout,'\n');
    end
end
fclose(fidout);