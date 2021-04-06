function [bands, locs] = bandInterpolate(condition)

nChan = 45;

doPlot = 0;

analysisCFs = {[120 235 384 580 836 1175 1624 2222 3020 4084 5507 7410];
                     [257 618 994 1342 1792 2368 3116 4110 5056 5869 6814 7911];
                     [502 716 986 1341 1790 2365 3111 4104 5452 7366];
                     [502 716 986 1331 1781 2350 3080 4094 5056 5869 6814 7911]};
analysisBands = {[70 170 300 469 690 982 1368 1881 2564 3475 4693 6321;
                    170 300 469 690 982 1368 1881 2564 3475 4693 6321 8500]';
                 
                     [120 394 842 1146 1539 2046 2691 3540 4679 5432 6306 7322;
                      394 842 1146 1539 2046 2691 3540 4679 5432 6306 7322 8500]';
    
                     [401 603 828 1145 1537 2043 2687 3535 4672 6232;
                     603 828 1145 1537 2043 2687 3535 4672 6232 8500]';
                 
                     [401 603 829 1148 1514 2048 2653 3508 4679 5432 6306 7322;
                     603 829 1148 1514 2048 2653 3508 4679 5432 6306 7322 8500]'};
                 
    switch condition
        case {1, 2}
            neuralCFs = [352 540 784 1109 1533 2099 2866 3877 5255 7284 10209 13732];
        case {3, 4}
            neuralCFs = [502 717 988 1330 1781 2350 3082 4066 5384 7234 9953 13286];           
    end               

    
    
    
analysisCFs = analysisCFs{condition};                 
analysisBands = analysisBands{condition};
bandwidths = analysisBands(:,2)-analysisBands(:,1);

nElec = length(analysisCFs);
stepSize = (nElec-1)/(nChan-1);

x = 1:nElec;
xq = 1:stepSize:nElec;

interpolatedCFs = 10.^(interp1(x,log10(analysisCFs),xq));
interpolatedWidths = 10.^(interp1(x,log10(bandwidths),xq))/(1/stepSize);

interpolatedBandsHi = interpolatedCFs(1)-interpolatedWidths(1)/2+cumsum(interpolatedWidths);
interpolatedBandsLo = interpolatedBandsHi-interpolatedWidths;


% add additional bands to cover min/max freq.
interpolatedBandsLo = [analysisBands(1,1) interpolatedBandsLo interpolatedBandsHi(end)];
interpolatedBandsHi = [interpolatedBandsLo(2) interpolatedBandsHi analysisBands(end,2)];

xq = [xq(1)-stepSize xq xq(end)+stepSize];
locs = 10.^interp1(x,log10(neuralCFs(1:length(x))),xq,'linear','extrap');



bands = [interpolatedBandsLo' interpolatedBandsHi'];


if doPlot
p1 = plot(x,analysisBands(:,1),'bv','LineWidth',1.5);
hold on
p2 =  plot(x,analysisBands(:,2),'r^','LineWidth',1.5);
p6 = plot(xq,interpolatedBandsLo,'.','Color',[.5 .5 .9],'LineStyle','none');
p7 = plot(xq,interpolatedBandsHi,'.','Color',[.9 .5 .5],'LineStyle','none');

p3 = plot(x,mean(analysisBands,2),'Marker','o','LineStyle','none','LineWidth',2,'Color',[0 .8 .5]);

p4 = plot(xq,mean(bands,2),'Marker','*','LineStyle','none','Color',[.5 .5 .5]);
p8 = plot(xq,locs,'d','Color',[.3 .3 .3]);
p5 = plot(x,neuralCFs,'Marker','s','LineStyle','none','LineWidth',2,'Color','k');

plot(xq,locs-mean(bands,2)','x')
plot(x,neuralCFs-analysisCFs,'p','Color',[.9 .6 0],'LineWidth',2)
hold off

legend([p2 p3 p1 p4 p5],{'HCO_{Original}','CF_{Original}','LCO_{Original}','CF_{Interpolated}','Neural CF'},'Location','southeast')
legend('boxoff')
set(gca,'XLim',[0 13],'YLim',[50 16000],'LineWidth',2,'FontSize',16,'FontWeight','bold','YScale','log')
title(['Condition: ' num2str(condition)])
xlabel('Electrode #')
ylabel('Frequency [Hz]')
end