load WindData2017
load WindStationData
close all

[numberofstations,~] = size(WindStationData);
stationnames = cellstr(table2array(WindStationData(:,5)));
stationnames(5) = {'DE KOOI'};
stationnames(10) = {'HOORN (TERSCHELLING)'};
stationnames(11) = {'WIJK AAN ZEE'};
stationnames(13) = {'DE BILT'};
stationnames(26) = {'NIEUW BERTA'};
stationnames(32) = {'VLAKTE V.D. RAAN'};
stationnames(38) = {'HOEK VAN HOLLAND'};
maxspeed = 8;
maxgust = 10.8;

for i=1:numberofstations
    if not(isempty(KNMI20171206hourly(KNMI20171206hourly(:,1)==table2array(WindStationData(i,1)),2))) %skip stations with no data
        data.date(:,i) = KNMI20171206hourly(KNMI20171206hourly(:,1)==table2array(WindStationData(i,1)),2);
        data.time(:,i) = KNMI20171206hourly(KNMI20171206hourly(:,1)==table2array(WindStationData(i,1)),3);
        data.direction(:,i) = KNMI20171206hourly(KNMI20171206hourly(:,1)==table2array(WindStationData(i,1)),4);
        data.avHspeed(:,i) = KNMI20171206hourly(KNMI20171206hourly(:,1)==table2array(WindStationData(i,1)),5)*0.1;
        data.highestGust(:,i) = KNMI20171206hourly(KNMI20171206hourly(:,1)==table2array(WindStationData(i,1)),6)*0.1;
        
        percentages(1,i) = numel(data.avHspeed(data.avHspeed(:,i)<maxspeed))/numel(data.avHspeed(:,i))*100;
        percentages(2,i) = numel(data.highestGust(data.highestGust(:,i)<maxgust))/numel(data.highestGust(:,i))*100;
    end
    if i==1
        data.date(:,2:numberofstations) = 0;
        data.time(:,2:numberofstations) = 0;
        data.direction(:,2:numberofstations) = 0;
        data.avHspeed(:,2:numberofstations) = 0;
        data.highestGust(:,2:numberofstations) = 0;
    end
end
percentages(1,i+1) = sum(nonzeros(percentages(1,:)))/nnz(percentages(1,:));
percentages(2,i+1) = sum(nonzeros(percentages(2,:)))/nnz(percentages(2,:));
cat = categorical([stationnames;{'Total'}]);

figure
bar(cat,percentages.')
title('percentage of hrs with winds below maximums')
legend('Max wind speed','Max gust speed')


figure
title('Average wind speed by the hour')
boxplot(data.avHspeed,'Labels',stationnames,'PlotStyle','compact')

figure
title('Highest gust speed by the hour')
boxplot(data.highestGust,'Labels',stationnames,'PlotStyle','compact')