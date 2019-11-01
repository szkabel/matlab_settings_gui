function [ paramTextHandles, paramEditHandles] = generateUIControls( paramarray, parentHandle, heightOfItems, margin, varargin)
% AUTHOR:   Abel Szkalisity
% DATE:     Dec 09, 2016
% NAME:     generateUIControls
%
% To create the 'form' of any method on graphical user interface. The
% margins affect the appearance as described in placeUIControls.
%
%   The most important outcome of the function is that the uicontrols are
%   placed on the parent control in a dinamic way according to paramarray.
%   However for further usage the handles to the uicontrols are also
%   returned.
%
% INPUT:
%   paramarray      a cellarrray where each entry is a structure. Each
%                   structure describes one input parameter. This structure
%                   has the following fields:
%                   .name: a string with the name of the parameter (this
%                   will be printed to the user when asked for the
%                   parameter value on the GUI)
%                   .type: This determines the type of the parameter. It is
%                   a string and should be one of the followings:
%                       - 'int' for numbers [int]
%                       - 'enum'** Possible values listed in .values
%                       cellarray,
%                       .default describes the index in the list. Displays
%                       as a drop-down list [index of the entry] 
%                       - 'str' standing for a text input [string]
%                       - 'slider'** Limits are listed in .lim [double]
%                       - 'checkbox' 0 or 1 and displays a checkbox [int: 0 / 1]
%                       - 'colorPicker' RGB triplet to store [RGB triplet
%                       each entry between 0-1]
%                       - 'multiple-enum'** Displays a list from which
%                       multiple entries can be selected [vector of indices
%                       to be selected]
%                       - 'dir' Displays a browse button or the user may
%                       copy-paste the directory into the field [string]
%                       - 'file'** Displays a browse button or the user may
%                       copy-paste the file path into the field It can be
%                       used to query file name for a new file OR also for
%                       selecting an existing file on the system (see **
%                       for the fileOpenType field)[string]
%                   .default: Optional. A default value to put to the input
%                   in advance. The type of the default field is indicated
%                   in brackets "[]" above.
%
%                   ** There can be additional fields according to the
%                   specified type of the input.
%                   .values: This is a cellarray of strings and required
%                   for 'enum' and 'multiple-enum'. It should contain all
%                   the options to be listed.
%                   .lim: A vector with length of 2 specifying the minimum
%                   and maximum (in this order) values to be allowed for
%                   the slider.                  
%                   .fileOpenType This a string value for file selection.
%                   Use either 'get' or 'put'. Use get if you want to query
%                   for an existing file and put for new files
%                   .filter (Optional) A filter specifying which filetypes
%                   to be able to select via the browser button. Check the
%                   documentation of uigetfile and uiputfile. However this
%                   does not  prevent the user from copying an inproper
%                   file into the text field.
%                       
%   parentHandle    handle to the parent object to which we're going to add
%                   the uicontrols. It must have a position property.
%   heightOfItems   The height of each ui item and the distance between
%                   them as well in pixels. (in the drawing at the top this
%                   is the height of a row). The multiple-enum is an
%                   exemption as it resizes its height according to the
%                   number of options listed there.
%   margins         Array with two values: HM and VM (horizontal and
%                   vertical margin) in this order, and in the unit of
%                   pixels.
%   
%   NAME,VALUE pairs, optional arguments
%   resizeParent    A bool value indicating whether to resize the parent ui
%                   object so that the data fits into it (only height).
%                   Default is false
%
% OUTPUT:
%   paramTextHandles handles to the parameter names.
%   paramEditHandles handles to the input fields.
%
% COPYRIGHT
% Settings Template Toolbox. All Rights Reversed. 
% Copyright (C) 2019 Abel Szkalisity
% BIOMAG, Synthetic and System Biology Unit, Institute of Biochemsitry,
% Biological Research Center, Szeged, Hungary
% Ikonen group Department of Anatomy, Faculty of Medicine, University of
% Helsinki, Helsinki, Finland.

p = inputParser;
addParameter(p,'resizeParent',false,@islogical);
addParameter(p,'lineSpacing',0.5,@isnumeric);
parse(p,varargin{:});
resizeParent = p.Results.resizeParent;
lineSpacing = p.Results.lineSpacing;

nofParams = length(paramarray);

paramTextHandles = cell(1,nofParams);
paramEditHandles = cell(1,nofParams);

sizeOfPanel = get(parentHandle,'Position');   

%Create handles
for i=1:nofParams
    paramTextHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','Text','String',paramarray{i}.name);    
    switch paramarray{i}.type
        case 'int'
            paramEditHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','edit','BackgroundColor','white');
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i},'string',num2str(paramarray{i}.default));
            end            
        case 'str'
            paramEditHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','edit','BackgroundColor','white');
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i},'string',paramarray{i}.default);
            end            
        case 'enum'        
            paramEditHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','popupmenu','BackgroundColor','white');
            set(paramEditHandles{i},'String',paramarray{i}.values);
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i},'value',paramarray{i}.default);
            end            
        case 'slider'
            paramEditHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','slider','BackgroundColor','white');
            set(paramEditHandles{i},'Min',paramarray{i}.lim(1));
            set(paramEditHandles{i},'Max',paramarray{i}.lim(2));
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i},'value',paramarray{i}.default);
            end            
        case 'checkbox'
            paramEditHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','checkbox');
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i},'value',paramarray{i}.default);
            end            
        case 'colorPicker'
            paramEditHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','pushbutton','BackgroundColor','white','Callback',@(hObject,eventdata)colorPickerCallback(hObject,eventdata,guidata(hObject)));
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i},'BackgroundColor',paramarray{i}.default);
            end            
        case 'multiple-enum'
            paramEditHandles{i} = uicontrol('Parent',parentHandle,'Units','pixels','Style','listbox','BackgroundColor','white','String',paramarray{i}.values,'min',0,'max',length(paramarray{i}.values));            
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i},'value',paramarray{i}.default);
            end
        case 'dir'
            paramEditHandles{i}{1} = uicontrol('Parent',parentHandle,'Units','pixels','Style','edit','BackgroundColor','white');
            paramEditHandles{i}{2} = uicontrol('Parent',parentHandle,'Units','pixels','Style','pushbutton','String','browse','UserData',struct('listID',i),'Callback',@(hObject,eventdata)browseCallback(hObject,eventdata,guidata(hObject),'dir'));
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i}{1},'string',paramarray{i}.default);
            end
        case 'file'
            paramEditHandles{i}{1} = uicontrol('Parent',parentHandle,'Units','pixels','Style','edit','BackgroundColor','white');
            paramEditHandles{i}{2} = uicontrol('Parent',parentHandle,'Units','pixels','Style','pushbutton','String','browse','UserData',struct('listID',i),'Callback',@(hObject,eventdata)browseCallback(hObject,eventdata,guidata(hObject),'file'));
            if isfield(paramarray{i},'default')
                set(paramEditHandles{i}{1},'string',paramarray{i}.default);
            end
    end           
end

%Place them dynamically
[sumHeightItems] = placeUIControls( paramarray, paramTextHandles, paramEditHandles, sizeOfPanel, heightOfItems, margin, 'lineSpacing',lineSpacing);

if resizeParent
    parentHandle.Position(4) = sumHeightItems;
    sizeOfPanel(4) = sumHeightItems;
    placeUIControls( paramarray, paramTextHandles, paramEditHandles, sizeOfPanel, heightOfItems, margin,'lineSpacing',lineSpacing);
end

%% Internal functions

function colorPickerCallback(hObject,~,~)
    pickedColor = uisetcolor();
    if length(pickedColor)==3
        set(hObject,'BackgroundColor',pickedColor);
    end      
end

function browseCallback(hObject,~,~,fileType)
%Filytype should be dir or file
    uData = get(hObject,'UserData');
    defPath = get(paramEditHandles{uData.listID}{1},'String');
    if isempty(defPath)
        defPath = pwd;           
    end    
    switch fileType
        case 'dir'
            fileToOpen = uigetdir(defPath,'Please select a folder');
        case 'file'
            if isfield(paramarray{uData.listID},'filter')
                filter = paramarray{uData.listID}.filter;
            else
                filter = '*';
            end
            switch paramarray{uData.listID}.fileOpenType
                case 'get'                    
                    [fileName,filePath] = uigetfile(filter,'Please select a file',defPath);                
                case 'put'
                    [fileName,filePath] = uiputfile(filter,'Please select a file',defPath);
            end
            if ~isnumeric(fileName) && ~isnumeric(filePath)
                fileToOpen = fullfile(filePath,fileName);
            else
                fileToOpen = 0;
            end                
    end        
    if ~isnumeric(fileToOpen)
        set(paramEditHandles{uData.listID}{1},'String',fileToOpen);
    end
    
end


end
