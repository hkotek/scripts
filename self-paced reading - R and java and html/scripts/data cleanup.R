###################################################################################
#####  Results cleanup script for Mechanical Turk experiment                  #####
#####  Kotek Dissertation Experiment 3 (which high-low also)                  #####
#####  April 2014                                                             #####
#####  Hadas Kotek                                                            #####
###################################################################################

# Note: file locations may have changed; check default path


`%ni%`<- Negate(`%in%`)

# read in Turk file
mydata <- read.csv("turk-submissions.csv",header=TRUE) 

# read in ibex file
names <- c("Date","IP","Controller","ItemNum", "Element","Type","Item","WordNum", "Word", "RT", "newLine", "Sentence")
allData <- read.csv("ibex-results.csv", header=FALSE, sep=",", fill=TRUE, col.names=names, blank.lines.skip=TRUE, comment.char= "#", strip.white=TRUE)

# collect info
Info <- subset(allData, Controller=="Form")
names(Info) <- c("Date","IP","Controller","ItemNum", "Element","Type","Item","Question", "Answer")

infoKey <- subset(Info, Question == 'WorkerId')[c('Date','IP','Answer')]
names(infoKey) <- c('Date','IP','WorkerId')

allData <- merge(allData,infoKey,all.x=T)

Code <- aggregate(mydata$WorkerId, by = list(Code = mydata$Answer.Code, WorkerId = mydata$WorkerId), FUN=length)
allData <- merge(allData, Code, all.x=T)

workTime <- aggregate(mydata$WorkerId, by = list(WorkerId = mydata$WorkerId, workTime = mydata$WorkTimeInSeconds), FUN=length)
allData <- merge(allData, workTime, all.x=T)

mydata <- merge(mydata, allData, all.x=T)

#Code check: should divide by 53051 ----
Code <- aggregate(mydata$WorkerId, by = list(Code = mydata$Code, WorkerId = mydata$WorkerId), FUN=length) 
nocode <- subset(Code, x == NA)$WorkerId
  

# filter people who did more than one experiment ----
# manually code: how many items in this experiment? 
surveyLength <- 1894 #verify!
notEnough <- surveyLength*0.8

didTooMany <- subset(Code, x > surveyLength)$WorkerId
didntDoEnough <- subset(Code, x < notEnough)$WorkerId


# find and discard too workers who were too fast ----
mydata$RT <- as.integer(as.character(mydata$RT))
mydata.temp <- subset(mydata, RT > 1) # 0,1 are T/F responses

howFast <- with(subset(mydata.temp, Controller == 'NewDashedSentence'), aggregate(RT, by=list(WorkerId = WorkerId), FUN=mean, na.rm = T))
howFast$OK <- ifelse(howFast$x < 100, 0,1) #exclude if average RT is too fast for deep reading

# good data: 90-2000ms; discard workers if we lose more than 20% of their data.
mydata.temp$OK <- ifelse(mydata.temp$RT < 90 | mydata.temp$RT > 2000, 1,0)
howMuchLost <- with(subset(mydata.temp, Controller == 'NewDashedSentence'), aggregate(OK, by=list(WorkerId = WorkerId), FUN=sum, na.rm = T)) 
howMuchLost$Percent <- howMuchLost$x / 1894
howMuchLost$OK <- ifelse(howMuchLost$Percent > 0.2, 0,1)

slow <- subset(howFast, x > 700)$WorkerId
slow
# [1] A34CCFG96Z3RO8 A3K6NI3B84FUVP

tooFast <- subset(howFast, OK == 0)$WorkerId
tooMuchLost <- subset(howMuchLost, OK == 0)$WorkerId
tooMuchLost
tooFast
# [1] A1XDXU43RJY8X7 A2806UPBR5FJJ2 A2R92N7OXVYYHK A38R7SIVV118KT

turkFast <- unique(subset(mydata.temp, workTime < 600)$WorkerId)
turkFast

# look at suspicious workers' data to make sure they didn't do work correctly before rejecting
subset(mydata.temp, mydata.temp$WorkerId == 'A38R7SIVV118KT')$RT

# filter ----
mydata <- subset(mydata, (WorkerId %ni% nocode))
mydata <- subset(mydata, (WorkerId %ni% cheaters))
mydata <- subset(mydata, (WorkerId %ni% didTooMany))
mydata <- subset(mydata, (WorkerId %ni% didntDoEnough))
mydata <- subset(mydata, (WorkerId %ni% tooFast))
mydata <- subset(mydata, (WorkerId %ni% tooMuchLost))
mydata <- subset(mydata, (WorkerId %ni% turkFast))
mydata <- subset(mydata, (WorkerId %ni% slow))

mydata <- mydata[,c("WorkerId", "Date","IP","Controller","ItemNum", "Element","Type","Item","WordNum", "Word", "RT", "newLine", "Sentence")]

# save filtered file ----
write.csv(mydata, 'ibex-Exp3-rerun-cleaned.csv')
