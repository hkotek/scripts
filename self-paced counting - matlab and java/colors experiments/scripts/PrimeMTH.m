function PrimeMTH(subjNo)
    RunExperimentWithInstructionsAndPractice(...
     'primeinstructions',...
     '../input/PrimeMTH/practice.txt',...
     ['../output/Prime/practice/practice' num2str(subjNo) '.csv'],...
     '../input/PrimeMTH/mth.txt',...
     ['../output/Prime/' num2str(subjNo) '.csv'],...
     60,... % break interval
     0 ); % final 1 = debug
end