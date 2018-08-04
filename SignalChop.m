function [Trial] = SignalChop(n,time,TrialStart,TrialEnd,adjust)


%% chop signal from each trial
for i = 1:n
    temp{i,:} = time(time > TrialStart & time < TrialEnd);
end

%% if no change to trial length
if adjust == 0;
    for i = 1:length(temp)
    Trial{i,:} = linspace(temp{i,:}(1,1),temp{i,:}(1,end),sigleng);
    end
%% if down sample
elseif adjust == 1;
sigleng = length(temp{i,:});
for i = 1:length(temp)
    if length(temp{i,:}) < sigleng
        sigleng = length(temp{i,:});
    end
end
for i = 1:length(temp)
    Trial{i,:} = linspace(temp{i,:}(1,1),temp{i,:}(1,end),sigleng);
end

%% if up sample
elseif adjust == 2
sigleng = 0;
for i = 1:length(temp)
    if length(temp{i,:}) > sigleng
        sigleng = length(temp{i,:});
    end
end
for i = 1:length(temp)
    Trial{i,:} = linspace(temp{i,:}(1,1),temp{i,:}(1,end),sigleng);
end
clear temp adjust i sigleng;
end 
end