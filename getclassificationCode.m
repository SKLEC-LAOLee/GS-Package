function [classificationCode,classificationMethod]=getclassificationCode(gravel,sand,silt,clay)
%----------------------------------------------------------------------------------------------------
% @file name:   getclassificationCode.m
% @description: Triangular classification of a single sample
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.10.17
%----------------------------------------------------------------------------------------------------
% @param:
% gravel, (2mm,inf] volume percentage(%)
% sand, (63um,2mm] volume percentage(%)
% silt, (3.9um,63um] volume percentage(%)
% clay, (0,3.9um] volume percentage(%)
% @return:
% classificationCode,
%             have gravel: following Folk(1954) method, see folk1954.fig
%             no gravel: following Blair-McPherson(1999) method, see BlairMcPherson1999.fig
% classificationMethod,
%             ='Blair-McPherson1999', have gravel
%             ='Folk1954'  , no gravel
% @references:
% Folk, R.L. and Ward, W.C. (1957) A Study in the Significance of Grain-Size Parameters. Journal of Sedimentary Petrology, 27, 3-26.
%                                  https://doi.org/10.1306/74D70646-2B21-11D7-8648000102C1865D
% Terence C. Blair, John G. McPherson; Grain-size and textural classification of coarse sedimentary particles. Journal of Sedimentary Research 1999;; 69 (1): 6–19.
%                                  https://doi.org/10.2110/jsr.69.6
%----------------------------------------------------------------------------------------------------
if gravel<1e-4
    classificationMethod='Folk1954';
    switch true
        case (sand>=90)
            classificationCode='S';
        case (sand<90)&&(sand>=50)&&((silt/clay)<=0.5)
            classificationCode='CS';
        case (sand<90)&&(sand>=50)&&((silt/clay)>0.5)&&((silt/clay)<2)
            classificationCode='MS';
        case (sand<90)&&(sand>=50)&&((silt/clay)>=2)
            classificationCode='StS';
        case (sand<50)&&(sand>=10)&&((silt/clay)<=0.5)
            classificationCode='SC';
        case (sand<50)&&(sand>=10)&&((silt/clay)>0.5)&&((silt/clay)<2)
            classificationCode='SM';
        case (sand<50)&&(sand>=10)&&((silt/clay)>=2)
            classificationCode='SSt';
        case (sand<10)&&((silt/clay)<=0.5)
            classificationCode='C';
        case (sand<10)&&((silt/clay)>0.5)&&((silt/clay)<2)
            classificationCode='M';
        case (sand<10)&&((silt/clay)>=2)
            classificationCode='St';
    end
else
    classificationMethod='Blair-McPherson1999';
    mud=silt+clay;
    switch true
        case (gravel>=90)
            classificationCode=G;
        case (gravel>=80)&&(gravel<90)&&((mud/sand)>1)
            classificationCode='(m)G';
        case (gravel>=80)&&(gravel<90)&&((mud/sand)<=1)
            classificationCode='(s)G';
        case (gravel>=30)&&(gravel<80)&&((mud/sand)>=9)
            classificationCode='MG';
        case (gravel>=30)&&(gravel<80)&&((mud/sand)<9)&&((mud/sand)>=1)
            classificationCode='SMG';
        case (gravel>=30)&&(gravel<80)&&((mud/sand)>(1/9))&&((mud/sand)<1)
            classificationCode='MSG';
        case (gravel>=30)&&(gravel<80)&&((mud/sand)<=(1/9))
            classificationCode='SG';
        case (gravel>5)&&(gravel<30)&&((mud/sand)>=9)
            classificationCode='GM';
        case (gravel>5)&&(gravel<30)&&((mud/sand)<9)&&((mud/sand)>=1)
            classificationCode='GSM';
        case (gravel>5)&&(gravel<30)&&((mud/sand)>(1/9))&&((mud/sand)<1)
            classificationCode='GMS';
        case (gravel>5)&&(gravel<30)&&((mud/sand)<=(1/9))
            classificationCode='GS';
        case (gravel<=5)&&((mud/sand)>=9)
            classificationCode='(g)M';
        case (gravel<=5)&&((mud/sand)<9)&&((mud/sand)>=1)
            classificationCode='(g)SM';
        case (gravel<=5)&&((mud/sand)>(1/9))&&((mud/sand)<1)
            classificationCode='(g)MS';
        case (gravel<=5)&&((mud/sand)<=(1/9))
            classificationCode='(g)S';
    end
end