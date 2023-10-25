function [uSpeed,vSpeed]=vd2en(speed,direction)
%----------------------------------------------------------------------------------------------------
% @file name:   vd2en.m
% @description: decomposition speed, direction(0 degrees eastward, increasing clockwise) as U(east) and V(north) component
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 10/21/2023
%----------------------------------------------------------------------------------------------------
% @param:
% speed, speed like current, wind, air ....
% direction, 0 degrees eastward, increasing clockwise, degree
% @return:
% uSpeed, east component
% vSpeed, north component
% @references:
% NONE
%----------------------------------------------------------------------------------------------------
uSpeed=speed.*sin(direction.*pi./180);
vSpeed=speed.*cos(direction.*pi./180);