% Command history:
clear 
addpath('C:/Users/j.castanheira/Documents/PuPl-master/')
pupl_init

subjects=dir('C:\Users\j.castanheira\Desktop\edf_data\data/*.edf');
gaze_x= [];
gaze_y=[];

for s= 1:length(subjects)

    % import data 
    eye_data = pupl_import('eyedata', struct([]), 'loadfunc', @readeyelinkEDF_base, 'filefilt', '*.edf', 'type', 'eye', 'bids', false, 'filepath', {['C:\Users\j.castanheira\Desktop\edf_data\data/' subjects(s).name]}, 'args', {}, 'native', false)
    % convert units to diameter 
    eye_data = pupl_feval(@pupl_trim_gaze, eye_data, 'lims', {'0' '1920' '0' '1080'});
    eye_data = pupl_feval(@pupl_trim_short, eye_data, 'lenthresh', '50ms', 'septhresh', '40ms');
    eye_data = pupl_feval(@pupl_blink_id, eye_data, 'method', 'noise', 'overwrite', true, 'cfg', []);
    eye_data = pupl_feval(@pupl_blink_rm, eye_data, 'trim', {'50ms';'150ms'});
    eye_data = pupl_feval(@pupl_interp, eye_data, 'data', 'gaze', 'interptype', 'spline', 'maxlen', '400ms', 'maxdist', '1`sd');
    % remove unnecessary tags to allow us to epoch more easily 
    eye_data = pupl_feval(@pupl_event_rm, eye_data, 'sel', struct('sel', {'MazeID'}, 'by', {'regexp'}));
    eye_data = pupl_feval(@pupl_event_rm, eye_data, 'sel', struct('sel', {'MazeRT'}, 'by', {'regexp'}));
    % epoch data around Maze trials (i.e., planning phase) 
    eye_data = pupl_feval(@pupl_epoch, eye_data, 'len', 'fixed', 'timelocking', struct('sel', {'Maze'}, 'by', {'regexp'}), 'lims', {'1';'6'}, 'other', struct('when', {'after'}, 'event', {0}), 'overwrite', false, 'name', 'Maze');
    
    events= [eye_data.epoch(:).event];
    
    for ev= 1:length(events)
        % index of event marker 
        index_marker=find([eye_data.times] == eye_data.event(find([eye_data.event.uniqid] == events(ev))).time);
        
        if isempty(index_marker)    % check for aborted trials which would be removed from the time domain
           gaze_x_temp(ev,:)= NaN;
           gaze_y_temp(ev,:)= NaN;
        else
            gaze_x_temp(ev,:)= eye_data.gaze.x((index_marker-1000):(index_marker+6000));
            gaze_y_temp(ev,:)= eye_data.gaze.y((index_marker-1000):(index_marker+6000));
        end
    end

    gaze_x= [gaze_x; gaze_x_temp];
    gaze_y= [gaze_y; gaze_y_temp];

end

%% read in behav data to split trails by lateralized vs non 
% read in behav data and pick out correct lat trials vs non lat trials
alldata=readtable('C:/Users/j.castanheira/Desktop/edf_data/AllDataConcat.csv');
index_lateralized= [alldata.Lateralized(1:6:end)==1];
index_side= [alldata.Side(1:6:end)==2];
index_subject= [alldata.SubjectCode(1:6:end)];
subjectlist=unique(alldata.SubjectCode);

% baseline correction of signals and plot time course of eye movements 
data4plot_x_nonlat= (mean(gaze_x(~index_lateralized, :), 'omitmissing')- mean(mean(gaze_x(~index_lateralized,500:1000), 'omitmissing')));
data4plot_x_lat= (mean(gaze_x(index_lateralized, :), 'omitmissing')- mean(mean(gaze_x(index_lateralized,500:1000), 'omitmissing')));

figure
plot(-500:6000, data4plot_x_nonlat(501:end))
hold on
plot(-500:6000, data4plot_x_lat(501:end) )

% baseline correction of signals and plot time course of eye movements 
data4plot_y_nonlat= (mean(gaze_y(~index_lateralized, :), 'omitmissing')- mean(mean(gaze_y(~index_lateralized,500:1000), 'omitmissing')));
data4plot_y_lat= (mean(gaze_y(index_lateralized, :), 'omitmissing')- mean(mean(gaze_y(index_lateralized,500:1000), 'omitmissing')));

figure
plot(-500:6000, data4plot_y_nonlat(501:end))
hold on
plot(-500:6000, data4plot_y_lat(501:end) )



%% find trials to remove where fixation was poor 

% look at first 500ms are they fixating within 30 pixels of the fixation
% (range of two squares either side) 
xind=find(mean(gaze_x(:,1000:1500), 2, 'omitnan') > 1005 |  mean(gaze_x(:,1000:500), 2, 'omitnan') < 915); % 990 930
yind=find(mean(gaze_y(:,1000:1500), 2, 'omitnan') < 475 |  mean(gaze_y(:,1000:500), 2, 'omitnan') > 565); % 490 550

% trials to remove with too much movemnt 
to_remove= unique([xind; yind]);

% what percentage of trials removed are lateralized ? 
sum(index_lateralized(to_remove))/length(to_remove) % (51.49 percent)

data4plot_x_bad= (mean(gaze_x(to_remove, :), 'omitmissing')- mean(mean(gaze_x(~index_lateralized,500:1000), 'omitmissing')));
data4plot_y_bad= (mean(gaze_y(to_remove, :), 'omitmissing')- mean(mean(gaze_y(~index_lateralized,500:1000), 'omitmissing')));

error_x_bad = std(gaze_x(to_remove, :), 'omitmissing')/ sqrt(length(gaze_x(to_remove,1)));
error_y_bad = std(gaze_y(to_remove, :), 'omitmissing')/ sqrt(length(gaze_y(to_remove,1)));

low_x= data4plot_x_bad(501:end)- error_x_bad(501:end);
hi_x= data4plot_x_bad(501:end)+ error_x_bad(501:end);

low_y= data4plot_y_bad(501:end)- error_y_bad(501:end);
hi_y= data4plot_y_bad(501:end)+ error_y_bad(501:end);

time= -500:6000;

% plot figure of removed trials
f=figure( 'Renderer','painters', 'Position', [10, 10, 1010, 510])
p1=patch([time'; time(end:-1:1)'; time(1)], [low_x'; hi_x(end:-1:1)'; low_x(1)], 'b')
hold on
plot(time, data4plot_x_bad(501:end))
p2=patch([time'; time(end:-1:1)'; time(1)], [low_y'; hi_y(end:-1:1)'; low_y(1)], 'r')
plot(time, data4plot_y_bad(501:end) )
set(p1, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none')
set(p2, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none')
xlabel('time (ms)')
ylabel('delta gaze position (pixels)')
legend({'', 'x coordinates','', 'y coordinates'})
ax= gca;
ax.FontSize =13;
legend boxoff

set(f,'Units','Inches');
pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/timeseries_eyeposition_badtrials.pdf')



%% explore the SD of the time series 
index_lateralized_clean= index_lateralized(setdiff(1:length(gaze_x(:,1)), to_remove));
index_side_clean= index_side(setdiff(1:length(gaze_x(:,1)), to_remove));
cleanX= gaze_x(setdiff(1:length(gaze_x(:,1)), to_remove),:);
cleanY= gaze_y(setdiff(1:length(gaze_y(:,1)), to_remove),:);

% baseline correction of signals and plot time course of eye movements 
data4plot_x_nonlat= cleanX(~index_lateralized_clean, :)- mean(mean(cleanX(~index_lateralized_clean,500:1000), 'omitmissing'));
data4plot_x_lat_left= cleanX(index_lateralized_clean & index_side_clean, :)- mean(mean(cleanX(index_lateralized_clean & index_side_clean,500:1000), 'omitmissing'));
data4plot_x_lat_right= cleanX(index_lateralized_clean & ~index_side_clean, :)- mean(mean(cleanX(index_lateralized_clean & ~index_side_clean,500:1000), 'omitmissing'));


non_lat_std=std(data4plot_x_nonlat(:, 1001:end),0 ,2, 'omitmissing');
lat_std= [std(data4plot_x_lat_left(:, 1001:end),0 ,2, 'omitmissing'); std(data4plot_x_lat_right(:, 1001:end),0 ,2, 'omitmissing')];
[h,p,ci,stats]= ttest2(non_lat_std, lat_std);

% p value 0.66
% t= -0.438, df= 2916, sd= 18.57
% non lat = 20.517, lat = 20.8189


non_lat_std_clean =non_lat_std(non_lat_std < mean(non_lat_std, 'omitmissing')+ 3*std(non_lat_std, 'omitmissing'));
lat_std_clean=lat_std(lat_std < mean(lat_std, 'omitmissing')+ 3*std(lat_std, 'omitmissing'));

binWidth= 5; % horizontal bin widths
hgapGrp= 0.2; % horizontal gap between each element (boxplot and hist)
hgap= 0.05; % horizontal gap between boxplot and hist

y= {non_lat_std_clean, lat_std_clean};
hcounts = cell(2,2); % number of conditions by 2
for i = 1:2 % number of conditions of interest
    [hcounts{i, 1}, hcounts{i,2}] = histcounts(y{i}, 'BinWidth', binWidth);

end
maxCount = max([hcounts{:,1}]);

fig = figure();
ax = axes(fig);
hold(ax, 'on')

xInterval = 0.5;
normwidth = (1-hgapGrp- hgap)/2;
boxplotwidth= xInterval*normwidth;
grouping = [repelem(0, size(non_lat_std,1)), repelem(0.5, size(lat_std,1))];
boxplot(ax,[non_lat_std; lat_std],grouping, 'Widths', boxplotwidth, 'symbol', '', 'Labels', {'non-lateralized', 'lateralized'}, 'Colors', 'k')

histx0 =2* [0, 0.5] + (6*boxplotwidth) + hgap; % where to draw the bottom/ base of hist
maxHeight = xInterval*normwidth; % upper x limit of histogram
patchHandles = gobjects(1, 2);

for i= 1:2 % number of conditions

        height = hcounts{i,1}/maxCount*maxHeight;

        xm= [zeros(1, numel(height)); repelem(height,2,1); zeros(2,numel(height))] + histx0(i);
        yidx = [0 0 1 1 0]' + (1:numel(height));
        ym= hcounts{i,2}(yidx);
        patchHandles(i) = patch(xm(:), ym(:), [0 0.75, 1], 'FaceAlpha', 0.4)

end
xlim([0.75,2.5])
ylim([-1,60])

colors= {[0 1 1]; [1 0 0]};

H = findobj(gca, 'Tag', 'Box');
for j= 1:2
    patch(get(H(j), 'XData'), get(H(j), 'YData'), colors{j}, 'FaceAlpha', 0.4)
end

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/boxplots_of_sd_across_trials.pdf')



%% plot time series of gaze of good data 
index_lateralized_clean= index_lateralized(setdiff(1:length(gaze_x(:,1)), to_remove));
index_side_clean= index_side(setdiff(1:length(gaze_x(:,1)), to_remove));
cleanX= gaze_x(setdiff(1:length(gaze_x(:,1)), to_remove),:);
cleanY= gaze_y(setdiff(1:length(gaze_y(:,1)), to_remove),:);

% baseline correction of signals and plot time course of eye movements 
data4plot_x_nonlat= (mean(cleanX(~index_lateralized_clean, :), 'omitmissing')- mean(mean(cleanX(~index_lateralized_clean,500:1000), 'omitmissing')));
data4plot_x_lat_left= (mean(cleanX(index_lateralized_clean & index_side_clean, :), 'omitmissing')- mean(mean(cleanX(index_lateralized_clean & index_side_clean,500:1000), 'omitmissing')));
data4plot_x_lat_right= (mean(cleanX(index_lateralized_clean & ~index_side_clean, :), 'omitmissing')- mean(mean(cleanX(index_lateralized_clean & ~index_side_clean,500:1000), 'omitmissing')));


error_x_nonlat = std(cleanX(~index_lateralized_clean, :), 'omitmissing')/ sqrt(length(cleanX(~index_lateralized_clean,1)));
error_x_lat_left = std(cleanX(index_lateralized_clean & index_side_clean, :), 'omitmissing')/ sqrt(length(cleanX(index_lateralized_clean & index_side_clean,1)));
error_x_lat_right = std(cleanX(index_lateralized_clean & ~index_side_clean, :), 'omitmissing')/ sqrt(length(cleanX(index_lateralized_clean & ~index_side_clean,1)));


low_xn= data4plot_x_nonlat(501:end)- error_x_nonlat(501:end);
hi_xn= data4plot_x_nonlat(501:end)+ error_x_nonlat(501:end);

low_xll= data4plot_x_lat_left(501:end)- error_x_lat_left(501:end);
hi_xll= data4plot_x_lat_left(501:end)+ error_x_lat_left(501:end);

low_xlr= data4plot_x_lat_right(501:end)- error_x_lat_right(501:end);
hi_xlr= data4plot_x_lat_right(501:end)+ error_x_lat_right(501:end);

time= -500:6000;

% plot figure of removed trials
f=figure( 'Renderer','painters', 'Position', [10, 10, 1010, 510])
p0=patch([time'; time(end:-1:1)'; time(1)], [low_xn'; hi_xn(end:-1:1)'; low_xn(1)], 'k')
hold on
plot(time, data4plot_x_nonlat(501:end), 'k')
p1=patch([time'; time(end:-1:1)'; time(1)], [low_xll'; hi_xll(end:-1:1)'; low_xll(1)], 'b')
plot(time, data4plot_x_lat_left(501:end), 'b')
p2=patch([time'; time(end:-1:1)'; time(1)], [low_xlr'; hi_xlr(end:-1:1)'; low_xlr(1)], 'r')
plot(time, data4plot_x_lat_right(501:end), 'r')
set(p0, 'facecolor', [0.8 0.8 0.8], 'edgecolor', 'none')
set(p1, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none')
set(p2, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none')
xlabel('time (ms)')
ylabel('delta gaze position (pixels)')
legend({"non-lateralized",'',"lateralized left",'', 'lateralized right'})
ax= gca;
ax.FontSize =13;
legend boxoff

set(f,'Units','Inches');
pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/timeseries_eyeposition_x_coordinates.pdf')


% baseline correction of signals and plot time course of eye movements 
data4plot_x_nonlat= (mean(cleanX(~index_lateralized_clean, :), 'omitmissing'));
data4plot_x_lat_left= (mean(cleanX(index_lateralized_clean & index_side_clean, :), 'omitmissing'));
data4plot_x_lat_right= (mean(cleanX(index_lateralized_clean & ~index_side_clean, :), 'omitmissing'));

error_x_nonlat = std(cleanX(~index_lateralized_clean, :), 'omitmissing')/ sqrt(length(cleanX(~index_lateralized_clean,1)));
error_x_lat_left = std(cleanX(index_lateralized_clean & index_side_clean, :), 'omitmissing')/ sqrt(length(cleanX(index_lateralized_clean & index_side_clean,1)));
error_x_lat_right = std(cleanX(index_lateralized_clean & ~index_side_clean, :), 'omitmissing')/ sqrt(length(cleanX(index_lateralized_clean & ~index_side_clean,1)));


low_xn= data4plot_x_nonlat(501:end)- error_x_nonlat(501:end);
hi_xn= data4plot_x_nonlat(501:end)+ error_x_nonlat(501:end);

low_xll= data4plot_x_lat_left(501:end)- error_x_lat_left(501:end);
hi_xll= data4plot_x_lat_left(501:end)+ error_x_lat_left(501:end);

low_xlr= data4plot_x_lat_right(501:end)- error_x_lat_right(501:end);
hi_xlr= data4plot_x_lat_right(501:end)+ error_x_lat_right(501:end);

time= -500:6000;

% plot figure of removed trials
f=figure( 'Renderer','painters', 'Position', [10, 10, 1010, 510])
p0=patch([time'; time(end:-1:1)'; time(1)], [low_xn'; hi_xn(end:-1:1)'; low_xn(1)], 'k')
hold on
plot(time, data4plot_x_nonlat(501:end), 'k')
p1=patch([time'; time(end:-1:1)'; time(1)], [low_xll'; hi_xll(end:-1:1)'; low_xll(1)], 'b')
plot(time, data4plot_x_lat_left(501:end), 'b')
p2=patch([time'; time(end:-1:1)'; time(1)], [low_xlr'; hi_xlr(end:-1:1)'; low_xlr(1)], 'r')
plot(time, data4plot_x_lat_right(501:end), 'r')
set(p0, 'facecolor', [0.8 0.8 0.8], 'edgecolor', 'none')
set(p1, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none')
set(p2, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none')
xlabel('time (ms)')
ylabel('gaze position (pixels)')
legend({"non-lateralized",'',"lateralized left",'', 'lateralized right'})
ax= gca;
ax.FontSize =13;
legend boxoff

set(f,'Units','Inches');
pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/timeseries_eyeposition_x_coordinates_absolute.pdf')



% baseline correction of signals and plot time course of eye movements 
data4plot_y_nonlat= (mean(cleanY(~index_lateralized_clean, :), 'omitmissing')- mean(mean(cleanY(~index_lateralized_clean,500:1000), 'omitmissing')));
data4plot_y_lat_left= (mean(cleanY(index_lateralized_clean & index_side_clean, :), 'omitmissing')- mean(mean(cleanY(index_lateralized_clean & index_side_clean,500:1000), 'omitmissing')));
data4plot_y_lat_right= (mean(cleanY(index_lateralized_clean & ~index_side_clean, :), 'omitmissing')- mean(mean(cleanY(index_lateralized_clean & ~index_side_clean,500:1000), 'omitmissing')));


error_y_nonlat = std(cleanY(~index_lateralized_clean, :), 'omitmissing')/ sqrt(length(cleanY(~index_lateralized_clean,1)));
error_y_lat_left = std(cleanY(index_lateralized_clean & index_side_clean, :), 'omitmissing')/ sqrt(length(cleanY(index_lateralized_clean & index_side_clean,1)));
error_y_lat_right = std(cleanY(index_lateralized_clean & ~index_side_clean, :), 'omitmissing')/ sqrt(length(cleanY(index_lateralized_clean & ~index_side_clean,1)));


low_yn= data4plot_y_nonlat(501:end)- error_y_nonlat(501:end);
hi_yn= data4plot_y_nonlat(501:end)+ error_y_nonlat(501:end);

low_yll= data4plot_y_lat_left(501:end)- error_y_lat_left(501:end);
hi_yll= data4plot_y_lat_left(501:end)+ error_y_lat_left(501:end);

low_ylr= data4plot_y_lat_right(501:end)- error_y_lat_right(501:end);
hi_ylr= data4plot_y_lat_right(501:end)+ error_y_lat_right(501:end);

time= -500:6000;

% plot figure of removed trials
f=figure( 'Renderer','painters', 'Position', [10, 10, 1010, 510])
p0=patch([time'; time(end:-1:1)'; time(1)], [low_yn'; hi_yn(end:-1:1)'; low_yn(1)], 'k')
hold on
plot(time, data4plot_y_nonlat(501:end), 'k')
p1=patch([time'; time(end:-1:1)'; time(1)], [low_yll'; hi_yll(end:-1:1)'; low_yll(1)], 'b')
plot(time, data4plot_y_lat_left(501:end), 'b')
p2=patch([time'; time(end:-1:1)'; time(1)], [low_ylr'; hi_ylr(end:-1:1)'; low_ylr(1)], 'r')
plot(time, data4plot_y_lat_right(501:end), 'r')
set(p0, 'facecolor', [0.8 0.8 0.8], 'edgecolor', 'none')
set(p1, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none')
set(p2, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none')
xlabel('time (ms)')
ylabel('delta gaze position (pixels)')
legend({"non-lateralized",'',"lateralized left",'', 'lateralized right'})
ax= gca;
ax.FontSize =13;
legend boxoff


set(f,'Units','Inches');
pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/timeseries_eyeposition_y_coordinates.pdf')


% baseline correction of signals and plot time course of eye movements 
data4plot_y_nonlat= (mean(cleanY(~index_lateralized_clean, :), 'omitmissing'));
data4plot_y_lat_left= (mean(cleanY(index_lateralized_clean & index_side_clean, :), 'omitmissing'));
data4plot_y_lat_right= (mean(cleanY(index_lateralized_clean & ~index_side_clean, :), 'omitmissing'));


error_y_nonlat = std(cleanY(~index_lateralized_clean, :), 'omitmissing')/ sqrt(length(cleanY(~index_lateralized_clean,1)));
error_y_lat_left = std(cleanY(index_lateralized_clean & index_side_clean, :), 'omitmissing')/ sqrt(length(cleanY(index_lateralized_clean & index_side_clean,1)));
error_y_lat_right = std(cleanY(index_lateralized_clean & ~index_side_clean, :), 'omitmissing')/ sqrt(length(cleanY(index_lateralized_clean & ~index_side_clean,1)));


low_yn= data4plot_y_nonlat(501:end)- error_y_nonlat(501:end);
hi_yn= data4plot_y_nonlat(501:end)+ error_y_nonlat(501:end);

low_yll= data4plot_y_lat_left(501:end)- error_y_lat_left(501:end);
hi_yll= data4plot_y_lat_left(501:end)+ error_y_lat_left(501:end);

low_ylr= data4plot_y_lat_right(501:end)- error_y_lat_right(501:end);
hi_ylr= data4plot_y_lat_right(501:end)+ error_y_lat_right(501:end);

time= -500:6000;

% plot figure of removed trials
f=figure( 'Renderer','painters', 'Position', [10, 10, 1010, 510])
p0=patch([time'; time(end:-1:1)'; time(1)], [low_yn'; hi_yn(end:-1:1)'; low_yn(1)], 'k')
hold on
plot(time, data4plot_y_nonlat(501:end), 'k')
p1=patch([time'; time(end:-1:1)'; time(1)], [low_yll'; hi_yll(end:-1:1)'; low_yll(1)], 'b')
plot(time, data4plot_y_lat_left(501:end), 'b')
p2=patch([time'; time(end:-1:1)'; time(1)], [low_ylr'; hi_ylr(end:-1:1)'; low_ylr(1)], 'r')
plot(time, data4plot_y_lat_right(501:end), 'r')
set(p0, 'facecolor', [0.8 0.8 0.8], 'edgecolor', 'none')
set(p1, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none')
set(p2, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none')
xlabel('time (ms)')
ylabel('delta gaze position (pixels)')
legend({"non-lateralized",'',"lateralized left",'', 'lateralized right'})
ax= gca;
ax.FontSize =13;
legend boxoff


set(f,'Units','Inches');
pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/timeseries_eyeposition_y_coordinates_absolute.pdf')





%% plot time series of gaze of good data but first average within subject 
index_lateralized_clean= index_lateralized(setdiff(1:length(gaze_x(:,1)), to_remove));
index_side_clean= index_side(setdiff(1:length(gaze_x(:,1)), to_remove));
cleanX= gaze_x(setdiff(1:length(gaze_x(:,1)), to_remove),:);
cleanY= gaze_y(setdiff(1:length(gaze_y(:,1)), to_remove),:);
index_subject_clean= index_subject(setdiff(1:length(gaze_y(:,1)), to_remove));

for  s= 1:length(subjects)

    subji= subjectlist(s);
    subindex=strcmp(index_subject_clean,subji);

    data4plot_x_nonlat(s,:)= (mean(cleanX(~index_lateralized_clean & subindex, :), 'omitmissing'));
    data4plot_x_lat_left(s,:)= (mean(cleanX(index_lateralized_clean & index_side_clean & subindex, :), 'omitmissing'));
    data4plot_x_lat_right(s,:)= (mean(cleanX(index_lateralized_clean & ~index_side_clean & subindex, :), 'omitmissing'));

    data4plot_y_nonlat(s,:)= (mean(cleanY(~index_lateralized_clean & subindex, :), 'omitmissing'));
    data4plot_y_lat_left(s,:)= (mean(cleanY(index_lateralized_clean & index_side_clean & subindex, :), 'omitmissing'));
    data4plot_y_lat_right(s,:)= (mean(cleanY(index_lateralized_clean & ~index_side_clean & subindex, :), 'omitmissing'));


end


error_x_nonlat = std(data4plot_x_nonlat)/ sqrt(size(data4plot_x_nonlat,1));
error_x_lat_left = std(data4plot_x_lat_left)/ sqrt(size(data4plot_x_nonlat,1));
error_x_lat_right = std(data4plot_x_lat_right)/ sqrt(size(data4plot_x_nonlat,1));

data4plot_x_nonlat= mean(data4plot_x_nonlat);
data4plot_x_lat_left= mean(data4plot_x_lat_left);
data4plot_x_lat_right= mean(data4plot_x_lat_right);

low_xn= data4plot_x_nonlat(501:end)- error_x_nonlat(501:end);
hi_xn= data4plot_x_nonlat(501:end)+ error_x_nonlat(501:end);

low_xll= data4plot_x_lat_left(501:end)- error_x_lat_left(501:end);
hi_xll= data4plot_x_lat_left(501:end)+ error_x_lat_left(501:end);

low_xlr= data4plot_x_lat_right(501:end)- error_x_lat_right(501:end);
hi_xlr= data4plot_x_lat_right(501:end)+ error_x_lat_right(501:end);

time= -500:6000;

% plot figure of removed trials
f=figure( 'Renderer','painters', 'Position', [10, 10, 1010, 510])
p0=patch([time'; time(end:-1:1)'; time(1)], [low_xn'; hi_xn(end:-1:1)'; low_xn(1)], 'k')
hold on
plot(time, data4plot_x_nonlat(501:end), 'k')
p1=patch([time'; time(end:-1:1)'; time(1)], [low_xll'; hi_xll(end:-1:1)'; low_xll(1)], 'b')
plot(time, data4plot_x_lat_left(501:end), 'b')
p2=patch([time'; time(end:-1:1)'; time(1)], [low_xlr'; hi_xlr(end:-1:1)'; low_xlr(1)], 'r')
plot(time, data4plot_x_lat_right(501:end), 'r')
set(p0, 'facecolor', [0.8 0.8 0.8], 'edgecolor', 'none')
set(p1, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none')
set(p2, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none')
xlabel('time (ms)')
ylabel('delta gaze position (pixels)')
legend({"non-lateralized",'',"lateralized left",'', 'lateralized right'})
ax= gca;
ax.FontSize =13;
legend boxoff

set(f,'Units','Inches');
pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/timeseries_eyeposition_x_coordinates_withinsubject.pdf')



error_y_nonlat = std(data4plot_y_nonlat)/ sqrt(size(data4plot_y_nonlat,1));
error_y_lat_left = std(data4plot_y_lat_left)/ sqrt(size(data4plot_y_nonlat,1));
error_y_lat_right = std(data4plot_y_lat_right)/ sqrt(size(data4plot_y_nonlat,1));

data4plot_y_nonlat= mean(data4plot_y_nonlat);
data4plot_y_lat_left= mean(data4plot_y_lat_left);
data4plot_y_lat_right= mean(data4plot_y_lat_right);

low_yn= data4plot_y_nonlat(501:end)- error_y_nonlat(501:end);
hi_yn= data4plot_y_nonlat(501:end)+ error_y_nonlat(501:end);

low_yll= data4plot_y_lat_left(501:end)- error_y_lat_left(501:end);
hi_yll= data4plot_y_lat_left(501:end)+ error_y_lat_left(501:end);

low_ylr= data4plot_y_lat_right(501:end)- error_y_lat_right(501:end);
hi_ylr= data4plot_y_lat_right(501:end)+ error_y_lat_right(501:end);

time= -500:6000;

% plot figure of removed trials
f=figure( 'Renderer','painters', 'Position', [10, 10, 1010, 510])
p0=patch([time'; time(end:-1:1)'; time(1)], [low_yn'; hi_yn(end:-1:1)'; low_yn(1)], 'k')
hold on
plot(time, data4plot_y_nonlat(501:end), 'k')
p1=patch([time'; time(end:-1:1)'; time(1)], [low_yll'; hi_yll(end:-1:1)'; low_yll(1)], 'b')
plot(time, data4plot_y_lat_left(501:end), 'b')
p2=patch([time'; time(end:-1:1)'; time(1)], [low_ylr'; hi_ylr(end:-1:1)'; low_ylr(1)], 'r')
plot(time, data4plot_y_lat_right(501:end), 'r')
set(p0, 'facecolor', [0.8 0.8 0.8], 'edgecolor', 'none')
set(p1, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none')
set(p2, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none')
xlabel('time (ms)')
ylabel('delta gaze position (pixels)')
legend({"non-lateralized",'',"lateralized left",'', 'lateralized right'})
ax= gca;
ax.FontSize =13;
legend boxoff

set(f,'Units','Inches');
pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/timeseries_eyeposition_y_coordinates_withinsubject.pdf')


%% Plot heatmaps of where people are looking during planning 

% read in Maze image to overlay 
I = im2double( imread('C:/Users/j.castanheira/Desktop/edf_data/Toy_example_plot.jpg') );
%I = rgb2gray(I);
I = I(:, 2:695);
J = imresize(I, 0.4755); %
figure
% non lateralized
h=histogram2(cleanX(~index_lateralized_clean,:),cleanY(~index_lateralized_clean,:),'Normalization','pdf','DisplayStyle','tile','ShowEmptyBins','on', 'XBinLimits', [795, 1125], 'YBinLimits', [360, 690], 'BinWidth',[1 1]);
histogramData=h.Values;

h=figure
%Create two axes
ax1 = axes;
MazeImg = imagesc(J); 
set(MazeImg, 'AlphaData', 1);
hold on
ax2 = axes;
hisImg=imagesc(imgaussfilt(histogramData,2));
set(hisImg, 'AlphaData', 0.8);
%Link them together
linkaxes([ax1,ax2]);
%Hide the top axes
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
%Give each one its own colormap
colormap(ax1,'gray')
colormap(ax2,'parula')
caxis([0,2.5000e-04])
%Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
cb1 = colorbar(ax1,'Position',[.05 .11 .03 .815]);
cb1.Label.String = '';
cb2 = colorbar(ax2,'Position',[.88 .11 .03 .815]);
cb2.Label.String = 'eye position (%)';

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/eyeposition_nonlateralized_trials.pdf')

% lateralized left
h=histogram2(cleanX(index_lateralized_clean & index_side_clean,:),cleanY(index_lateralized_clean & index_side_clean,:), 'Normalization','pdf','DisplayStyle','tile','ShowEmptyBins','on', 'XBinLimits', [795, 1125], 'YBinLimits', [360, 690], 'BinWidth',[1 1]);
histogramData=h.Values;

h=figure
%Create two axes
ax1 = axes;
MazeImg = imagesc(J); 
set(MazeImg, 'AlphaData', 1);
hold on
ax2 = axes;
hisImg=imagesc(imgaussfilt(histogramData,2));
set(hisImg, 'AlphaData', 0.8);
%Link them together
linkaxes([ax1,ax2]);
%Hide the top axes
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
%Give each one its own colormap
colormap(ax1,'gray')
colormap(ax2,'parula')
caxis([0,2.5000e-04])
%Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
cb1 = colorbar(ax1,'Position',[.05 .11 .03 .815]);
cb1.Label.String = '';
cb2 = colorbar(ax2,'Position',[.88 .11 .03 .815]);
cb2.Label.String = 'eye position (%)';

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/eyeposition_lateralized_left_trials.pdf')

% lateralized right
h=histogram2(cleanX(index_lateralized_clean & ~index_side_clean,:),cleanY(index_lateralized_clean & ~index_side_clean,:),'Normalization','pdf','DisplayStyle','tile','ShowEmptyBins','on', 'XBinLimits', [795, 1125], 'YBinLimits', [360, 690], 'BinWidth',[1 1]);
histogramData=h.Values;
h=figure
%Create two axes
ax1 = axes;
MazeImg = imagesc(J); 
set(MazeImg, 'AlphaData', 1);
hold on
ax2 = axes;
hisImg=imagesc(imgaussfilt(histogramData,2));
set(hisImg, 'AlphaData', 0.8);
%Link them together
linkaxes([ax1,ax2]);
%Hide the top axes
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
%Give each one its own colormap
colormap(ax1,'gray')
colormap(ax2,'parula')
caxis([0,2.5000e-04])
%Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
cb1 = colorbar(ax1,'Position',[.05 .11 .03 .815]);
cb1.Label.String = '';
cb2 = colorbar(ax2,'Position',[.88 .11 .03 .815]);
cb2.Label.String = 'eye position (%)';

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

saveas(gcf,'C:/Users/j.castanheira/Desktop/edf_data/results_eyetracking/eyeposition_lateralized_right_trials.pdf')

%% make on big matrix to save the outputs of the data 

index_remove= repelem( false, size(gaze_x,1));
index_remove(to_remove)= true;
index_remove=repelem(index_remove',6);
alldata.toremove=index_remove;

writetable(alldata,'C:/Users/j.castanheira/Desktop/edf_data/AllDataWithEyeTracking.csv' )

save('C:/Users/j.castanheira/Desktop/edf_data/trials-to_remove.mat','to_remove')

