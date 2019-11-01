function [sumHeightItems] = placeUIControls( paramarray, paramTextHandles, paramEditHandles, sizeOfPanel, heightOfItems, margin, varargin)
% AUTHOR:   Abel Szkalisity
% DATE:     Oct 20, 2019
% NAME:     placeUIControls
%
% This function calculates how to place the already created graphical
% objects onto the parent panel.
%
%   | ^VM
%   | <- HM -> PARAMETER1 <- HM ->/2 || <- HM ->/2 INPUT_FIELD1 <- HM -> |
%   | lineSpacing
%   | <- HM -> PARAMETER2 <- HM ->/2 || <- HM ->/2 INPUT_FIELD2 <- HM -> |
%   | ?VM
%
%   VM and HM stands for Vertical and Horizontal Margin and come as input.
%
% INPUTS:
%   paramarray      See in generateUIControls. This is required as some
%                   inputs height is dependent on the inner data.
%   paramTextHandles,paramEditHandles Cellarrays of handle structures as
%                   created by generateUIControls.
%   sizeOfPanel     The size property of the parent handle.
%   heightOfItems   The height of each ui item and the double of distance
%                   between them as well in pixels. (in the drawing at the
%                   top this is the height of a row). The multiple-enum is
%                   an exemption as it resizes its height according to the
%                   number of options listed there.
%   margins         Array with two values: HM and VM (horizontal and
%                   vertical margin) in this order, and in the unit of
%                   pixels.
%   NAME,VALUE pairs, optional arguments
%   lineSpacing     A double value for the size of line spacing
%
% OUTPUT:
%   sumHeightItems  The total sum of the height of the placed items in
%                   pixels
%
% COPYRIGHT
% Settings Template Toolbox. All Rights Reversed. 
% Copyright (C) 2019 Abel Szkalisity
% BIOMAG, Synthetic and System Biology Unit, Institute of Biochemsitry,
% Biological Research Center, Szeged, Hungary
% Ikonen group Department of Anatomy, Faculty of Medicine, University of
% Helsinki, Helsinki, Finland.


p = inputParser;
addParameter(p,'lineSpacing',0.5,@isnumeric);
parse(p,varargin{:});
lineSpacing = p.Results.lineSpacing;

nofParams = length(paramarray);

sumHeightItems = 0;
maxMultipleEnumHeight = 200;

singleItemHeights = zeros(nofParams,1);

%Set here if some field needs to be greater than standard (i.e. multiple list input)
for i=1:nofParams
    currentHeight = heightOfItems;   
    switch paramarray{i}.type
        case 'int'            
        case 'str'            
        case 'enum'
        case 'slider'
        case 'checkbox'
        case 'colorPicker'
        case 'multiple-enum'
            currentHeight = min(maxMultipleEnumHeight,heightOfItems*length(paramarray{i}.values));            
    end
    
    singleItemHeights(i) = currentHeight;
    sumHeightItems = sumHeightItems + currentHeight;
    
    editColWidth = sizeOfPanel(3)/2-margin(1)*1.5;
    if strcmp(paramarray{i}.type,'dir') || strcmp(paramarray{i}.type,'file')        
        editPositionLeft =  [sizeOfPanel(3)/2+margin(1)/2, sizeOfPanel(4)-margin(2)-sumHeightItems-(i-1)*heightOfItems*lineSpacing, editColWidth*2/3 currentHeight];
        editPositionRight = [sizeOfPanel(3)/2+margin(1)/2+editColWidth*2/3, sizeOfPanel(4)-margin(2)-sumHeightItems-(i-1)*heightOfItems*lineSpacing, editColWidth*1/3 currentHeight];
        set(paramEditHandles{i}{1},'Position',editPositionLeft);
        set(paramEditHandles{i}{2},'Position',editPositionRight);
    else
        editPosition = [sizeOfPanel(3)/2+margin(1)/2, sizeOfPanel(4)-margin(2)-sumHeightItems-(i-1)*heightOfItems*lineSpacing, editColWidth currentHeight];    
        set(paramEditHandles{i},'Position',editPosition);
    end
    
    set(paramTextHandles{i},'Position',[margin(1), sizeOfPanel(4)-margin(2)-sumHeightItems-(i-1)*heightOfItems*lineSpacing, sizeOfPanel(3)/2-margin(1)*1.5 currentHeight]);    
        
end

sumHeightItems = sumHeightItems + 2*margin(2) + (nofParams-1)*heightOfItems*lineSpacing;
