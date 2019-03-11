function AprimeMTH(subjNo)
    RunExperimentWithInstructionsAndPractice(...
     'aprimeinstructions',...
     '../input/AprimeMTH/practice.txt',...
     ['../output/AprimeMTH/practice' num2str(subjNo) '.csv'],...
     '../input/AprimeMTH/mth.txt',...
     ['../output/AprimeMTH/' num2str(subjNo) '.csv'],...
     42,... % break interval
     0 ); % final 1 = debug
end