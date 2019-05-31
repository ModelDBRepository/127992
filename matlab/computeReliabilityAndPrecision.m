function [reliability,precision] = computeReliabilityAndPrecision(...
    T,N,stimtime,interval,nSpikes,binWidth,trials,showPlot)
% COMPUTERELIABILITYANDPRECISION computes the reliability and the precision
% (as defined in Mainen & Sejnowski, Science, 1995) of a spike train
% generated by a stochastic neuron.
% 
% [reliability,precision] = computeReliabilityAndPrecision(...
%       T,N,stimtime,interval,nSpikes,binWidth[,trials[,showPlot]]) 
% 
% Arguments:
%   T - an array of cells. Every cell represents a different trial and is
%       a vector containing the times at which the neuron fired.
%   N - a vector with the same number of elements of T. It contains the
%       number of spikes fired in each trial.
%  stimtime - a 2-elements vector containing the starting and ending times
%             of the stimulation.
%  interval - a 2-elements vector containing the time interval to be used
%             for the computation of reliability and precision.
%  nSpikes - the number of spikes to be considered for the computation of
%            reliability and precision.
%  binWidth - the width of the bin (in milliseconds) to be used for
%             computing the peri-stimulus time histogram.
%  trials - the number of trials to be considered for the computation of
%           reliability and precision. If this value is not provided, then
%           all trials are considered.
%  showPlot - whether to show a plot with the results of the computation.
%             If this value is not provided, then no plot is shown.
% 

% 
% Author: Daniele Linaro - May 2010.
% 

if ~ exist('showPlot','var')
    showPlot = 1;
end
    
spikes = zeros(trials,nSpikes);
for k=1:trials
    ndx = find(T{k} > interval(1) & T{k} < interval(2));
    if length(ndx) < nSpikes
        spikes(k,:) = repmat(NaN,[1,nSpikes]);
    else
        spikes(k,:) = T{k}(ndx(1:nSpikes));
    end
end
spikesMean = nanmean(spikes);

[r,c] = find(isnan(spikes));
r = setdiff(1:trials,unique(r));
edges = interval(1) : binWidth : interval(2);
freq = sum(histc(spikes(r,:),edges,2)) / (numel(r)*binWidth/1000);
edges = (edges(1:end-1)+edges(2:end))/2;
freq = freq(1:end-1);
threshold = 2*mean(freq);

cnt = 1;
for k=1:length(freq)-1
    if (freq(k) < threshold && freq(k+1) > threshold) || ...
       (freq(k) > threshold && freq(k+1) < threshold)
        crossings(cnt) = polyval(polyfit(freq(k:k+1),edges(k:k+1),1),threshold);
        cnt = cnt+1;
    end
end

reliability = 0;
total = 0;
times = cell(length(crossings)/2,1);
for k=1:length(crossings)/2
    times{k} = [];
end
for ii=1:trials
    for jj=1:2:length(crossings)-1
        ndx = find(T{ii} > crossings(jj) & T{ii} < crossings(jj+1));
        if ~ isempty(ndx)
            reliability = reliability + length(ndx);
            times{(jj+1)/2} = [times{(jj+1)/2}, T{ii}(ndx)];
        end
    end
    total = total + ...
        length(find(T{ii} > interval(1) & T{ii} < interval(2)));
end
reliability = reliability / total;
precision = 0;
for k=1:length(times)
    precision = precision+std(times{k});
end
precision = precision/length(times);

if showPlot
    figure;
    subplot(2,1,1); hold on;
    rasterplot(T,'k');
    plot(stimtime(1)+[0,0], [0,trials], 'g:');
    axis([interval,0,trials]);
%     for k=1:nSpikes
%         plot(spikesMean(k)+[0,0],[0,trials],'r:');
%     end
    title(['Reliability = ',num2str(reliability,'%.2f'),...
           '  Precision = ',num2str(precision,'%.2f'),' ms']);
    xlabel('t (ms)'); ylabel('Trial');
    box on;

    subplot(2,1,2); hold on;
    plot(edges,freq,'k');
    plot(xlim,threshold+[0,0],'k:');
    plot(stimtime(1)+[0,0], ylim, 'g:');
    axis([interval,ylim]);
%     for k=1:nSpikes
%         plot(spikesMean(k)+[0,0],ylim,'r:');
%     end
    for k=1:length(crossings)
        plot(crossings(k)+[0,0],ylim,'k:');
    end
    xlabel('t (ms)'); ylabel('f (Hz)');
    box on;
end