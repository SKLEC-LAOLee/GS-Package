function figureId=plotcomulativeCurve(sampleData,outputConfig)
%----------------------------------------------------------------------------------------------------
% @file name:   plotcomulativeCurve.m
% @description: Sediment particle size cumulative frequency and differential frequency curves
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.10.22
%----------------------------------------------------------------------------------------------------
% @param:
% sampleData.
%           dataPath: full path of the data file
%           fileName: file name of the xle/xld file
%       instrumentId: instrument code
%                     = 1, coulter LS 13320
%                     =11, camsizer X2
%                     =21, malvern
%                     =99, unknown
%          groupName: sample group
%            groupId: unique numeric id of the group
%         sampleName: sample name
%           sampleId: unique numeric id of the sample
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
%  outputConfig.
%         outputPath: full path of the output files
% GradationCurveFigWidth: figure width of gradation curve, in unit of cm
%GradationCurveFigHeight: figure height of gradation curve, in unit of cm
%           language: 
%               ='cn'   Particle gradation curves are labeled in Chinese
%               ='en'   Particle gradation curves are labeled in English
% @return: 
% figureId, figure handle
% @references:
%  NONE
%----------------------------------------------------------------------------------------------------
figureId=figure(999);
try
    clf(figureId);
catch
    figure(figureId);
end
set(figureId, 'Units', 'centimeters', 'Position', [5 5 outputConfig.GradationCurveFigWidth outputConfig.GradationCurveFigHeight]);
axisId=axes(figureId);
%differential frequency bar
yyaxis(axisId,'left');
bar(axisId,log2(sampleData.channelMidSize./1000),sampleData.adjustP3,'b');
hold(axisId,'on');
lineId=plot(axisId,log2(sampleData.channelMidSize./1000),sampleData.adjustP3,'-b');
set(lineId,'linewidth',1);
ylmDiff=get(axisId,'ylim');
ylmDiff(1)=0;
ytickDiff=(ylmDiff(1):(ylmDiff(2)/10):ylmDiff(2))';
yticklabelDiff=num2str(ytickDiff,'%0.1f');
set(axisId,'ycolor','b','ylim',ylmDiff,'ytick',ytickDiff,'yticklabel',yticklabelDiff);
if strcmpi(language,'cn')
    ylabel(axisId,'微分频率(%)');
else
    ylabel(axisId,'volume percent (%)');
end

%cumulative frequency curve
yyaxis(axisId,'right');
pai=13:-1:-3;
paiChannelUp=1000*2.^(-pai);
paiStr={'0.1','0.2','0.5','1.0','2.0','3.9','7.8','15.6','31.3','62.5','125','250','500','1000','2000','4000','8000'};

minId=find(abs(sampleData.adjustQ3)<0.01);
maxId=find(abs(sampleData.adjustQ3)>99.9999999);
if isempty(minId)
    minId=1;
else
    minId=minId(end);
end
if isempty(maxId)
    maxId=length(sampleData.channelUpSize);
else
    maxId=maxId(1);
end

xlimMinId=find(paiChannelUp<=sampleData.channelUpSize(minId));
xlimMaxId=find(paiChannelUp>=sampleData.channelUpSize(maxId));
if isempty(xlimMinId)
    xlimMinId=1;
else
    xlimMinId=xlimMinId(end);
end
if isempty(xlimMaxId)
    xlimMaxId=length(paiChannelUp);
else
    xlimMaxId=xlimMaxId(1);
end
xtickVal=paiChannelUp(xlimMinId:xlimMaxId);
xtickStr=paiStr(xlimMinId:xlimMaxId);
ylimCumu=[0 100];
ytickCumu=(0:10:100)';
yticklabelComu=num2str(ytickCumu);
lineId=plot(axisId,log2(sampleData.channelUpSize./1000),sampleData.adjustQ3,'-r');
set(lineId,'linewidth',1.5,'color','r');
set(axisId,'ycolor','r','ylim',ylimCumu,'ytick',ytickCumu,'yticklabel',yticklabelComu,'xtick',sort(log2(xtickVal./1000)),'xlim',sort(log2(xtickVal([1,end])./1000)),'xticklabel',xtickStr);
if strcmpi(language,'cn')
    xlabel('粒径(\mum)');
    ylabel('累积频率(%)');
else
    xlabel('Grain size (\mum)');
    ylabel('Percent passing (%)');
end
% label
if sampleData.haveShapeData
    annotation(figureId,'textbox',[0.15 0.6 0.3 0.3],'String',{['ID=',sampleData.sampleName],['D50=',num2str(sampleData.d50,'%.0fμm')],['SPHT50=',num2str(sampleData.spht_50,'%.3f')]},'FitBoxToText','on','linestyle','none','fontsize',8);
else
    annotation(figureId,'textbox',[0.15 0.6 0.3 0.3],'String',{['ID=',sampleData.sampleName],['D10=',num2str(sampleData.d10,'%.0fμm')],['D50=',num2str(sampleData.d50,'%.0fμm')],['D90=',num2str(sampleData.d90,'%.0fμm')]},'FitBoxToText','on','linestyle','none','fontsize',8);
end
% save
print(figureId,'-dpng',[outputConfig.outputPath,'figures\',num2str(sampleData.sampleId),'-',sampleData.sampleName,'.png'], '-loose', '-r600');
savefig(figureId,[outputConfig.outputPath,'figures\',num2str(sampleData.sampleId),'-',sampleData.sampleName,'.fig']);
%close(figureId);