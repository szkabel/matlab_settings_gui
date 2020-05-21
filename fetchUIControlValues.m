function [ paramcell ] = fetchUIControlValues( paramarray , paramEditHandles, checkHandle)
% AUTHOR:   Abel Szkalisity
% DATE:     June 30, 2017
% NAME:     createClassImage
%
% This function extracts the parameters from uicontrol elements and returns
% them in a cellarray. If the given parameter in the control field does not
% fulfil the condition implied by the corresponding paramarray type
% (currently we only check that the 'int' typed input field must be a
% number and that directories are valid existing directories) then we show
% a warning message to the user. In that case the paramcell output is
% unreliable.
%
% INPUT:
%   paramarray      See the documentation of generateUIControls.
%   paramEditHandles A cellarray of handles to the uicontrol objects. We
%                   suppose that the GUI was generated with the
%                   generateUIControl function from the paramarray
%                   specification therefore paramarray and paramEditHandles
%                   has equal length. The type of the ith entry of the
%                   paramEditHandles is determined by the ith entry of the
%                   paramarray. (e.g. for enum type parameter there is a
%                   popuplist graphical object)
%   checkHandle     A handle to a function (which can be the string with
%                   the function name), that is going to be called with one
%                   parameter: the potential paramcell output. This
%                   parameter is OPTIONAL. If it is provided then the int
%                   typed parameters are not checked to be number the only
%                   parameter check that is run is the given function. The
%                   function must return a boolean value and a message
%                   (string) to display that describes the problem if the
%                   boolean is not 1.
%
% OUTPUT:
%   paramcell       A cellarray with the fetched parameters. The type of
%                   the ith entry of this is determined by the type of the
%                   corresponding paramarray entry. The length
%                   is equal to paramarray's length. Types given back:
%                       - int -> numeric value (can be matrix)
%                       - slider -> numberic value,
%                       - checkbox -> 0/1 (numeric)
%                       - colorPicker -> array (RGB)
%                       - enum -> string
%                       - multiple-enum -> cellarray of strings
%                       - string -> string
%                       - dir -> string
%
% COPYRIGHT
% Settings Template Toolbox. All Rights Reversed. 
% Copyright (C) 2019 Abel Szkalisity
% BIOMAG, Synthetic and System Biology Unit, Institute of Biochemsitry,
% Biological Research Center, Szeged, Hungary
% Ikonen group Department of Anatomy, Faculty of Medicine, University of
% Helsinki, Helsinki, Finland.

nofParams = length(paramarray);
paramcell = cell(1,nofParams);
ok = 1;

for i=1:length(paramEditHandles)
    if strcmp(paramarray{i}.type,'str')
        paramcell{i} = get(paramEditHandles{i},'string');
    elseif strcmp(paramarray{i}.type,'int')
        paramcell{i} = str2num(get(paramEditHandles{i},'string')); %#ok<ST2NM> It can happen that we need convert into array.        
        %check for number, not for int.
        if ~isfield(paramarray{i},'numSpecs')
            numSpecs = struct('integer',0,'scalar',0,'limits',[-Inf,Inf]);
        else
            numSpecs = paramarray{i}.numSpecs;
        end                
        if nargin<3
            [ok,msg] = checkNumber(paramcell{i},numSpecs.integer,numSpecs.scalar,numSpecs.limits,paramarray{i}.name);
            if ~ok               
                break;
            end
        end
    elseif strcmp(paramarray{i}.type,'enum') 
        paramcell{i} = paramarray{i}.values{(get(paramEditHandles{i},'value'))};
    elseif strcmp(paramarray{i}.type,'multiple-enum')
        paramcell{i} = paramarray{i}.values(get(paramEditHandles{i},'value'));
    elseif strcmp(paramarray{i}.type,'slider') || strcmp(paramarray{i}.type,'checkbox')        
        paramcell{i} = get(paramEditHandles{i},'Value');
    elseif strcmp(paramarray{i}.type,'colorPicker')
        paramcell{i} = get(paramEditHandles{i},'BackgroundColor');
    elseif strcmp(paramarray{i}.type,'dir')
        paramcell{i} = get(paramEditHandles{i}{1},'String');        
        if nargin<3 && ~exist(paramcell{i},'dir')
            msg = ['Parameter ''' paramarray{i}.name ''' has to be a directory!'];
            ok = 0;
            break;
        end
    elseif strcmp(paramarray{i}.type,'file')
        paramcell{i} = get(paramEditHandles{i}{1},'String');        
    end    
end

if nargin>=3
    [ok,msg] = feval(checkHandle,paramcell);
end

if ~ok
    errordlg(msg,'Parameter error');
    %throw error unreliable output
    error('Settings_GUI:errorConstraintFault',msg);
end

end