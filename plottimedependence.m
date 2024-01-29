clear all
clc 
close all
%%

for file={'673_timedependence'}%'672_timedependence',
    load(append(file{1},'.mat'),'Data')
    f1=figure(1);
    f2=figure(2);
    area={};
    distance={};
    for hif=1:length(Data.Frame)
        figure(f1)
        Data.Frame{hif}.Area=[];
        Data.Frame{hif}.longestDistance=[];
        Data.Frame{hif}.Width=[];
        splittext=split(Data.Frame{hif}.Filename,file{1}(1:3));
        Data.Frame{hif}.Step=str2num(splittext{3}(1:end-4));
        for cryst=1:length(Data.Frame{hif}.Positions)
            Data.Frame{hif}.Area(cryst)=polyarea(Data.Frame{hif}.Positions{cryst}(:,1),Data.Frame{hif}.Positions{cryst}(:,2));
            distances=pdist(Data.Frame{hif}.Positions{cryst});
            if isempty(distances)
                distances=0;
            end
            Data.Frame{hif}.longestDistance(cryst)=max(distances);
            if hif==1
                figure(f1)
                area{cryst}=plot(Data.Frame{hif}.Step,Data.Frame{hif}.Area(cryst),'o');
                hold all
                pause(1)
                figure(f2)
                distance{cryst}=plot(Data.Frame{hif}.Step,Data.Frame{hif}.longestDistance(cryst),'o');
                hold all
            else
                area{cryst}.XData(end+1)=Data.Frame{hif}.Step;
                area{cryst}.YData(end+1)=Data.Frame{hif}.Area(cryst);
                distance{cryst}.XData(end+1)=Data.Frame{hif}.Step;
                distance{cryst}.YData(end+1)=Data.Frame{hif}.longestDistance(cryst);
            end
        end
    end
    figure(f1)
    title(file{1})
    xlabel('time [arb.units]')
    ylabel('area [pixel$^2$]','Interpreter','latex')
    savefig(f1, append(file{1},'area.fig'))
    figure(f2)
    title(file{1})
    xlabel('time [arb.units]')
    ylabel('maximum distance [pixel]')
    savefig(f2, append(file{1},'maxdist.fig'))
    x=[];
    y=[];
    for hi=1:length(area)
        area{hi}.YData=area{hi}.YData/area{hi}.YData(1);
        y=[y,area{hi}.YData];
        x=[x,area{hi}.XData];
    end
    fo = fitoptions('Method','NonlinearLeastSquares',...
        'Lower',[0,0,0],...
               'Upper',[Inf,Inf,Inf],...
               'StartPoint',[1 1 50]);
    
    figure(f1)
    F=fit(x',y','a/(1+exp(-b*(x-c)))','Lower',[0,0,0],...
    'Upper',[Inf,Inf,Inf],...
    'StartPoint',[1 0.01 50]);
    plot(linspace(0,190),F(linspace(0,190)))
    ylabel('normalized area')
    savefig(f1, append(file{1},'normalizedarea.fig'))
    close all
    save(append(file{1},'_analysis.mat'),'Data','F')
end
