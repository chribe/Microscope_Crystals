clc
close all
clear all
%% set file directory
path=uigetdir('./','Choose Data Set');
if ispc
    separator='\';
else
    separator='/';
end
folder=split(path,separator);
folder=folder{end};
N=10;% stepsize
%% determine if analysis has started and if there is a corresponding .mat file
files=dir('.');
disp(append('analyzed_figures_',folder))
mkdir(append('analyzed_figures_',folder))
imagefiles=dir(folder);
if sum(strcmp(strcat(folder,'.mat'),{files.name}))==0
    % no mat file found. open last image to identify crystals
    Image = imread(strcat(folder,separator, imagefiles(end).name));
    imshow(Image)
    disp('mark all crystals; when done, finish with enter')
    positions=ginput;
    Data.N=size(positions,1);
    Data.Frame={};
    Frame.Filename=imagefiles(end).name;
    Frame.Positions={};
    for hi=1:Data.N
        hold on
        marker=plot(positions(hi,1),positions(hi,2),'bo');
        alpha(marker,0.5)
        disp('mark edges of crystal');
        while true
            Crystalpositions=ginput;
            cshape=plot([Crystalpositions(:,1);Crystalpositions(1,1)],[Crystalpositions(:,2);Crystalpositions(1,2)]);
            textinput=input('good=1;bad=0: ','s');
            if strcmp(textinput,'1')
                Frame.Positions{end+1}=Crystalpositions;
                break
            end
            delete(cshape)
        end
        delete(marker)
    end
    Data.Frame{end+1}=Frame;
    savefig(gcf, append('analyzed_figures_',folder,separator,imagefiles(end).name,'.fig'))
    save(strcat(folder,'.mat'),'Data')
    close all
end
%% now open other images
load(strcat(folder,'.mat'),'Data')
for hi=length(imagefiles):-N:1
    disp(hi)
    analyzed=0;
    for hif=1:length(Data.Frame)
        if strcmp(imagefiles(hi).name,Data.Frame{hif}.Filename)
            analyzed=1;
        end
    end
    if analyzed==1
        disp(append(imagefiles(hi).name,' already analyzed, loading next!'))
    else
        Image = imread(strcat(folder,separator, imagefiles(hi).name));
        imshow(Image)
        Frame.Filename=imagefiles(hi).name;
        Frame.Positions={};
        for hin=1:Data.N
            hold on
            finalcrystal=scatter(Data.Frame{end}.Positions{hin}(:,1),Data.Frame{end}.Positions{hin}(:,2),'filled');
            alpha(finalcrystal,0.4)
            while true
                firstpoint=ginput(1);
                fp=plot(firstpoint(1),firstpoint(2),'bo');
                Crystalpositions=ginput;
                Crystalpositions=[firstpoint;Crystalpositions];
                cshape=plot([Crystalpositions(:,1);Crystalpositions(1,1)],[Crystalpositions(:,2);Crystalpositions(1,2)]);
                textinput=input('good=1;bad=0: ','s');
                if strcmp(textinput,'1')
                    Frame.Positions{end+1}=Crystalpositions;
                    break
                end
                delete(cshape)
            end
            delete(fp)
            delete(finalcrystal)
        end
        Data.Frame{end+1}=Frame;
        savefig(gcf, append('analyzed_figures_',folder,separator,imagefiles(hi).name,'.fig'))
        save(strcat(folder,'.mat'),'Data')
        close all
    end
end