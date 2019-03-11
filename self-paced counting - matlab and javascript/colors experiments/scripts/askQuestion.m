function [time1,time2,answer] = askQuestion(question,windowPtr,height)

timeStart = Screen('Flip',windowPtr);
timeFirstPress = 0;
answer = [];
while 1
    DrawFormattedText(windowPtr, question, 'center', height / 4);
    DrawFormattedText(windowPtr, answer, 'center', height / 2);    
    Screen('Flip',windowPtr);
    [seconds, keyCode, deltaSec] = KbWait([],2);
    if ~strcmp(class(KbName(keyCode)),'cell')
        A = KbName(keyCode);

        if '0' <= A(1) &  A(1) <= '9'
            if timeFirstPress == 0
                timeFirstPress = GetSecs();
            end
                answer = [answer A(1)];
        end
        
        if strcmp(KbName(keyCode),'DELETE')
            answer = answer(1:length(answer)-1);
        end
        
        if strcmp(KbName(keyCode),'Return')

            %%% if we never pressed a number button (left a blank answer)
            %%% then set timeFirstPress to timeStart so we get sane values
            if timeFirstPress == 0
                timeFirstPress = timeStart;
            end
            
            time1 = timeFirstPress - timeStart;
            time2 = GetSecs() - timeFirstPress;
            break;
        end
        
    end
end


end

