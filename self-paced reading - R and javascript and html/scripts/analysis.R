# for Experiment 3 with revised questions and high-low also with which
# Hadas Kotek, July 2013
# Cleaned August 2013
# For rerun, April 2014
# paper Exp3b

# Data acquisition ----
# note, in the raw file: 
# type = {practice, filler, target}; target = {which-did, which-was, every-did, every-was}
# element = {0=SPR element, 1=question}, group = item number
# controller = {NewDashedSentence, Question}
# item = what line in the file the item is (counting consequtively across sections)


# load libraries ----
library(languageR)
library(plotrix)
library(Hmisc)

# Defining a 'Not In' operator
`%ni%`<- Negate(`%in%`)

# Load results file ----

# first run Turk check, once done simply read in clean file
# Note: file locations may have changed; check default path
allData <- read.csv("ibex-Exp3-rerun-cleaned.csv", header = TRUE)

# get basic info
with(subset(allData, Controller == 'NewDashedSentence'), sd(RT, na.rm=TRUE))
with(subset(allData, Controller == 'NewDashedSentence'), mean(RT, na.rm=TRUE))
nrow(allData)

# get info about participants, to be stored in infoKey
Info <- subset(allData, Controller=="Form")
names(Info) <- c("ItemNum", "WorkerId", "Date","IP", "Controller", "Element","Type","Item", "NA", "Question", "Answer")

infoKey <- subset(Info, Question == 'WorkerId')[c('Answer')]
  names(infoKey) <- c('WorkerId')
sexes <- subset(Info, Question == 'sex')[c('WorkerId','Answer')]
  names(sexes) <- c('WorkerId','Sex')
infoKey <- merge(infoKey, sexes)
ages <- subset(Info, Question == 'age')[c('WorkerId','Answer')]
  names(ages) <- c('WorkerId','Age')
infoKey <- merge(infoKey, ages)
englishes <- subset(Info, Question == 'english')[c('WorkerId','Answer')]
  names(englishes) <- c('WorkerId','English')
infoKey <- merge(infoKey, englishes)
foreigns <- subset(Info, Question == 'foreign')[c('WorkerId','Answer')]
  names(foreigns) <- c('WorkerId','Foreign')
infoKey <- merge(infoKey, foreigns)
Comments <- subset(Info, Question == 'comments')[c('WorkerId','Answer')]
  names(Comments) <- c('WorkerId','Comments')

allData <- merge(allData,infoKey,all.x = T)
rm(Info, ages, sexes, englishes, foreigns)

# filter non native speakers, bilinguals
allData <- subset(allData, English == 'yes')
infoKey <- subset(infoKey, English == 'yes')
#allData <- subset(allData, Foreign == 'no')
#infoKey <- subset(infoKey, Foreign == 'no')

# set WorkerId as factor (WorkerId)
allData$WorkerId <- factor(allData$WorkerId)
infoKey$WorkerId <- factor(infoKey$WorkerId)

# results dataframe ----
results <- subset(allData, Type %ni% c('start_practice', 'end_practice','intro', 'consent', 'demo', 'practice', 'contact', 'end'), select=c("WorkerId","Controller","ItemNum", "Type","Item","Word", "RT", "WordNum", "Sentence"))

# add factors ----
verbKey <- unique(subset(results, WordNum == 17 & Type == 'target')[c('ItemNum','Word','Type')])
names(verbKey) <- c('ItemNum','Verb','Type')
results <- merge(results,verbKey,all.x = T)
rm(verbKey)

tmp <- subset(results, Type=='target' & Controller == 'NewDashedSentence')
alsoKey <- tmp[c('WorkerId','Item')]
alsoKey <- cbind(alsoKey, ifelse(grepl('was also', tmp$Sentence),'high', ifelse(grepl('to also', tmp$Sentence),'low',"filler")))
names(alsoKey) <- c('WorkerId','Item','Also')
alsoKey <- unique(alsoKey)
results <- merge(results, alsoKey, by = c('WorkerId','Item'), all.x=T)
rm(alsoKey, tmp)

results$Condition <- ifelse(results$Also == 'high' & results$Verb == 'did', 'high-did', 
                     ifelse(results$Also == 'high' & results$Verb == 'was', 'high-was', 
                     ifelse(results$Also == 'low' & results$Verb == 'did', 'low-did', 
                     ifelse(results$Also == 'low' & results$Verb == 'was', 'low-was', 'filler'))))

# accuracy ----
questions <- subset(results, Controller == 'NewQuestion' & Type != 'practice')
names(questions) <- c("WorkerId", "Item", "ItemNum","Type","Controller","Answer", "Correct", "Question", "NA", "Det", "Verb", "Condition")

# Overall accuracy
acc.rate.subj <- aggregate(questions$Correct, list(WorkerId = questions$WorkerId), mean, na.rm = T) 
names(acc.rate.subj) <- c('WorkerId', 'AccRate')

infoKey <- merge(infoKey, acc.rate.subj, all.x = T)
results <- merge(results, infoKey, all.x = T)

bad.subjects <- subset(acc.rate.subj, AccRate < 0.75)$WorkerId

# filler accuracy 
fillers <- subset(questions, Type == 'filler')

# by item
fillerItemAccuracy <- aggregate(fillers$Correct, list(Item = fillers$Item), mean, na.rm = T)
#write.csv(fillerItemAccuracy, 'fillerItemAccuracy.csv')
# choose filler items with low accuracy, to exclude from by subject accuracy later
lowAccFil <- subset(fillerItemAccuracy, x < 0.60)$Item
lowAccFil
# excludes: 41 43 37

# by subject
fillers <- subset(fillers, Item %ni% lowAccFil)
acc.rate.filler <- aggregate(fillers$Correct, list(WorkerId = fillers$WorkerId), mean, na.rm = T)
names(acc.rate.filler) <- c('WorkerId', 'FillerAccRate')

infoKey <- merge(infoKey, acc.rate.filler, all.x = T)
results <- merge(results,infoKey,all.x = T)

bad.filler.subjects <- subset(acc.rate.filler, FillerAccRate < 0.75)$WorkerId

# target accuracy
target <- subset(questions, Type == 'target')

# by item
targetItemAccuracy <- aggregate(target$Correct, list(Item = target$Item), mean, na.rm = T)
#targetItemAccuracyCond <- aggregate(target$Correct, list(Condition = target$Condition, Item = target$Item), mean, na.rm = T)
#write.csv(targetItemAccuracyCond, 'targetItemAccuracyCond.csv')
lowAccTar <- subset(targetItemAccuracy, x < 0.60)$Item
lowAccTar
# excludes: 5 8 4

# by subject
target <- subset(target, Item %ni% lowAccTar)
acc.rate.target <- aggregate(target$Correct, list(WorkerId = target$WorkerId), mean, na.rm = T)
names(acc.rate.target) <- c('WorkerId', 'TargetAccRate')

infoKey <- merge(infoKey, acc.rate.target, all.x = T)
results <- merge(results,infoKey,all.x = T)

bad.target.subjects <- subset(acc.rate.target, TargetAccRate < 0.75)$WorkerId #0.75


# by condition
accuracyByCondition <- aggregate(target$Correct, list(Condition = target$Condition), mean, na.rm = T)
accuracyByCondition
#accuracyByCondition.same <- aggregate(target.same$Correct, list(Condition = target.same$Condition), mean, na.rm = T)
#accuracyByCondition.same

# log isCorrect, use to filter RTs (only look at correctly answered Qs in RT analysis)
rmKey <- unique(target)[c('WorkerId', 'Item', 'ItemNum','Correct')]
names(rmKey) <- c('WorkerId', 'Item', 'ItemNum','Include')

#remove bad subjects:
results <- subset(results, (WorkerId %ni% bad.filler.subjects))  #fillers
results <- subset(results, (WorkerId %ni% bad.target.subjects))  #targets: perhaps!

infoKey <- subset(infoKey, (WorkerId %ni% bad.filler.subjects))
infoKey <- subset(infoKey, (WorkerId %ni% bad.target.subjects))

# set WorkerId as factor (WorkerId)
results$WorkerId <- factor(results$WorkerId)
infoKey$WorkerId <- factor(infoKey$WorkerId)

rm(acc.rate.subj, acc.rate.filler, acc.rate.target, bad.subjects, bad.filler.subjects, bad.target.subjects)
rm(questions, fillers, target)
rm(targetItemAccuracy, fillerItemAccuracy, accuracyByCondition)
#rm(target.same, accuracyByCondition, targetItemAccuracyCond, accuracyByCondition.same, bad.filler.subjects.75, bad.target.subjects.70, bad.subjects.65, diffCorrect)

# calculate RRTs ----
results <- subset(results, Controller == 'NewDashedSentence')
results <- subset(results, Item %ni% lowAccFil & Item %ni% lowAccTar)
rm(lowAccFil, lowAccTar)

results$Length <- nchar(as.character(results$Word))
results$WordNum <- factor(results$WordNum)

# trimming RTs above/below certain threshhold
nrow(subset(results, (RT>2000 | RT<90)))
# trims < 1%
# todo: maybe make these NAs instead?
results <- subset(results, (RT<2000 & RT>90))

# do not include first and last letter (RTs always long and not representative)
results$RT <- ifelse(results$WordNum == 1, NA, results$RT)
results$RT <- ifelse(grepl('[.]', results$Word)==T, NA, results$RT)


# RRTs with linear model
RT.lm <- lm(RT ~ Length, data=results, na.action=na.exclude)
RRT <- residuals(RT.lm, na.rm=T)
results$RRT <- RRT
rm(RT.lm, RRT)

results$logRT <- log(results$RT)
with(subset(results, !(is.na(results$RT))), plot(density(RT)))
with(subset(results, !(is.na(results$logRT))), plot(density(logRT)))

#with(subset(results, !(is.na(results$RT))), qqnorm(results$RT, main = "QQ plot: raw RTs"))
#with(subset(results, !(is.na(results$RT))), qqline(results$RT))
#with(subset(results, !(is.na(results$logRT))), qqnorm(results$logRT, main = "QQ plot: logRTs"))
#with(subset(results, !(is.na(results$logRT))), qqline(results$logRT))

#raw
#results$RRT <- results$RTs

#with NO linear model
#AvgRTPerLength <- tapply(results$RT, results$Length, mean, na.rm=T)[results$Length]
#results$RRT <- results$RT - AvgRTPerLength

# first 28 fillers are structured like targets. ----
# filler item numbers are 29- because ibex can't handle double numbering and 1-28 are targets.
fillers <- subset(results, Type == 'filler' & Controller == 'NewDashedSentence' & Item %in% c(29:56))

sd(fillers$RT, na.rm=TRUE)
mean(fillers$RT, na.rm=TRUE)

infoKey$MeanFilRT <- tapply(fillers$RT, fillers$WorkerId, FUN=mean, na.rm=TRUE)
infoKey$sdFilRT <- tapply(fillers$RT, fillers$WorkerId, FUN=sd, na.rm=TRUE)
fillers <- merge(fillers,infoKey,all.x = T)

# create targets data frame, trimming ----
targets <- subset(results, Type == 'target' & Controller == 'NewDashedSentence')
targets <- merge(targets,rmKey,all.x = T)
rm(rmKey)

sd(targets$RT, na.rm=TRUE)
mean(targets$RT, na.rm=TRUE)

infoKey$MeanRT <- tapply(targets$RT, targets$WorkerId, FUN=mean, na.rm=TRUE)
infoKey$sdRT <- tapply(targets$RT, targets$WorkerId, FUN=sd, na.rm=TRUE)
targets <- merge(targets,infoKey,all.x = T)


# criterion trimming ----
trimmed <- subset(targets, Include == 1)
# trimmed sanity check: number of observations, after trimming, by condition
with(with(trimmed,aggregate(Item,by=list(WordNum,Condition,WorkerId),length)), aggregate(x,by=list(Group.2),sum))

ctrimmed <- trimmed[c('WorkerId','Item', 'Condition', 'Also', 'Verb', 'RT', 'logRT', 'RRT', 'WordNum', 'Sentence')]

tmp <- with(ctrimmed, aggregate(RT, by=list(WordNum, Condition, WorkerId), FUN=mean, na.rm=T))
tmp <- cbind(tmp, with(ctrimmed, aggregate(RRT, by=list(WordNum, Condition, WorkerId), FUN=mean, na.rm=T))[,4])
tmp <- cbind(tmp, with(ctrimmed, aggregate(logRT, by=list(WordNum, Condition, WorkerId), FUN=mean, na.rm=T))[,4])
tmp <- cbind(tmp, with(ctrimmed, aggregate(RT, by=list(WordNum, Condition, WorkerId), FUN=sd, na.rm=T))[,4])
tmp <- cbind(tmp, with(ctrimmed, aggregate(RRT, by=list(WordNum, Condition, WorkerId), FUN=sd, na.rm=T))[,4])
tmp <- cbind(tmp, with(ctrimmed, aggregate(logRT, by=list(WordNum, Condition, WorkerId), FUN=sd, na.rm=T))[,4])
tmp <- cbind(tmp, with(ctrimmed, aggregate(Item, by=list(WordNum, Condition, WorkerId), length))[,4])
names(tmp) <- c('WordNum', 'Condition', 'WorkerId', "RT.mean", "RRT.mean", "logRT.mean", "RT.sd", "RRT.sd", "logRT.sd", "observations")

ctrimmed <- merge(ctrimmed, tmp, all.x=T)

SD.factor <- 2

RT.outofbounds <- with(ctrimmed, RT > RT.mean + SD.factor * RT.sd |
                         RT < RT.mean - SD.factor * RT.sd)
table(RT.outofbounds)
ctrimmed$RT <- ifelse(RT.outofbounds, NA, ctrimmed$RT)

RRT.outofbounds <- with(ctrimmed, RRT > RRT.mean + SD.factor * RRT.sd |
                          RRT < RRT.mean - SD.factor * RRT.sd)
table(RRT.outofbounds)
ctrimmed$RRT <- ifelse(RRT.outofbounds, NA, ctrimmed$RRT)

logRT.outofbounds <- with(ctrimmed, logRT > logRT.mean + SD.factor * logRT.sd |
                            logRT < logRT.mean - SD.factor * logRT.sd)
table(logRT.outofbounds)
ctrimmed$logRT <- ifelse(logRT.outofbounds, NA, ctrimmed$logRT)

rm(tmp, SD.factor, RT.outofbounds, RRT.outofbounds, logRT.outofbounds)

# ---- SAVED FILE ----
write.csv(targets, 'trimmedExp3.csv')
write.csv(fillers, 'trimmedExp3-fillers.csv')
write.csv(results, 'trimmedExp3-results.csv')
write.csv(ctrimmed, 'trimmedExp3-ctrimmed.csv')

# --- reload saved file to skip the trimming and preparation process ---
targets <- read.csv('trimmedExp3.csv', header = TRUE)
fillers <- read.csv('trimmedExp3-fillers.csv', header = TRUE)
results <- read.csv('trimmedExp3-results.csv', header = TRUE)
ctrimmed <- read.csv('trimmedExp3-ctrimmed.csv', header = TRUE)

`%ni%` <- Negate(`%in%`)

# just the correctly answered trials. Include came from rmKey above.
trimmed <- subset(targets, Include == 1)

# global plotting settings ----
x_lab=c("1:The", "2:conductor", "3:asked", "4:which"  ,"5:soloist", "6:was", "7:also/willing", "8:willing/to", "9:to/also", "10:perform", "11:which" ,"12:concerto" ,"13:that" ,"14:the", "15:brilliant" ,"16:protege", "17:did/was", "18:and" ,"19:restructured", "20:the" ,"21:rehearsal" ,"22:accordingly")
expname <- "Exp3"
#legend <- c("low-did", "low-was", "high-did", "high-was", "fillers")
legend <- c("low-did", "low-was", "high-did", "high-was")

# filterdata for plots
fildata <- fillers
FilGrandMean <- aggregate(fildata$RRT, by=list(fildata$WordNum), mean, na.rm=T)
FilGrandMean <- cbind(FilGrandMean, aggregate(fildata$RRT, by=list(fildata$WordNum), std.error, na.rm=T)[,2])
FilGrandMean <- cbind(FilGrandMean, aggregate(fildata$RT, by=list(fildata$WordNum), mean, na.rm=T)[,2])
FilGrandMean <- cbind(FilGrandMean, aggregate(fildata$RT, by=list(fildata$WordNum), std.error, na.rm=T)[,2])
names(FilGrandMean) <- c('WordNum', 'RRT', 'RRT-std', 'RT', 'RT-std')
FilGrandMean <- FilGrandMean[order(as.integer(as.vector(FilGrandMean$WordNum))),]
FilGrandMean <- FilGrandMean[0:21,]

# set up all data ----
data <- targets
GrandMean <- aggregate(data$RRT, by=list(data$WordNum, data$Condition), mean, na.rm=T)
GrandMean <- cbind(GrandMean, aggregate(data$RRT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), mean, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
names(GrandMean) <- c('WordNum', 'Condition', 'RRT', 'RRT.std', 'RT', 'RT.std')
GrandMean <- GrandMean[order(as.integer(as.vector(GrandMean$WordNum))),]

par(mfrow=c(1,1), mar=c(5,4,3,3))
ed <- subset(GrandMean, Condition=="high-did") #names carried over from other experiments; used to be: e=every, w-which
ew <- subset(GrandMean, Condition=="high-was")
wd <- subset(GrandMean, Condition=="low-did")
ww <- subset(GrandMean, Condition=="low-was")

# NELS trimming:
ed <- ed[0:22,]
ew <- ew[0:22,]
wd <- wd[0:22,]
ww <- ww[0:22,]

# plot RRTs all data ----
plot(as.vector(ed$WordNum), ed$RRT, xlim=c(2,22), ylim=c(-50,90), type="l", col='white', pch=1, ylab="RRTs", xlab="", xaxt='n')
points(as.vector(ed$WordNum), ed$RRT, col="red", type="b", lty = "solid", pch=1)
points(as.vector(ew$WordNum), ew$RRT, col="red", type="b", lty = "dotted", pch=3)
points(as.vector(wd$WordNum), wd$RRT, col="blue", type="b", lty = "solid", pch=1)
points(as.vector(ww$WordNum), ww$RRT, col="blue", type="b", lty = "dotted", pch=3)
points(as.vector(FilGrandMean$WordNum), FilGrandMean$RRT, col="black", type="b", lty = "solid", pch=4)

errbar(x=1:21, y=ed$RRT, yplus=ed$RRT+ed$RRT.std, yminus=ed$RRT-ed$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=ew$RRT, yplus=ew$RRT+ew$RRT.std, yminus=ew$RRT-ew$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=wd$RRT, yplus=wd$RRT+wd$RRT.std, yminus=wd$RRT-wd$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
errbar(x=1:21, y=ww$RRT, yplus=ww$RRT+ww$RRT.std, yminus=ww$RRT-ww$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
#errbar(x=as.vector(FilGrandMean$WordNum), y=FilGrandMean$RRT, yplus=FilGrandMean$RRT+FilGrandMean$RRT.std, yminus=FilGrandMean$RRT-FilGrandMean$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'purple')

legend("topleft",y.intersp=0.6,text.width=4, pch=c(1,3,1,3,4), legend=legend, col=c("red", "red", "blue", "blue", "black"), lty=c("solid", "dotted", "solid", "solid"), bty='n')
text(seq(1,22,by=1),par("usr")[3]-10,srt=45,adj=1,labels=x_lab,xpd=T,cex=0.8)
title(main=paste(sep="", expname, " RRTs, all targets (n=", length(unique(data$WorkerId)),")"))

# plot raw RTs all data ----
plot(as.vector(ed$WordNum), ed$RT, xlim=c(2,22), ylim=c(320,500), type="l", col='white', pch=1, ylab="raw RTs", xlab="", xaxt='n')
points(as.vector(ed$WordNum), ed$RT, col="red", type="b", lty = "solid", pch=1)
points(as.vector(ew$WordNum), ew$RT, col="red", type="b", lty = "dotted", pch=3)
points(as.vector(wd$WordNum), wd$RT, col="blue", type="b", lty = "solid", pch=1)
points(as.vector(ww$WordNum), ww$RT, col="blue", type="b", lty = "dotted", pch=3)
#points(as.vector(FilGrandMean$WordNum), FilGrandMean$RT, col="black", type="b", lty = "solid", pch=4)

errbar(x=1:21, y=ed$RT, yplus=ed$RT+ed$RT.std, yminus=ed$RT-ed$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=ew$RT, yplus=ew$RT+ew$RT.std, yminus=ew$RT-ew$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=wd$RT, yplus=wd$RT+wd$RT.std, yminus=wd$RT-wd$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
errbar(x=1:21, y=ww$RT, yplus=ww$RT+ww$RT.std, yminus=ww$RT-ww$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
#errbar(x=as.vector(FilGrandMean$WordNum), y=FilGrandMean$RRT, yplus=FilGrandMean$RRT+FilGrandMean$RRT.std, yminus=FilGrandMean$RRT-FilGrandMean$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'black')

legend("topleft",y.intersp=0.6,text.width=4, pch=c(1,3,1,3,4), legend=legend, col=c("red", "red", "blue", "blue", "black"), lty=c("solid", "dotted", "solid", "solid"), bty='n')
text(seq(1,22,by=1),par("usr")[3]-10,srt=45,adj=1,labels=x_lab,xpd=T,cex=0.8)
title(main=paste(sep="",expname, " RTs, all targets (n=", length(unique(data$WorkerId)),")"))

# set up correctly answered trials ----
data <- trimmed
GrandMean <- aggregate(data$RRT, by=list(data$WordNum, data$Condition), mean, na.rm=T)
GrandMean <- cbind(GrandMean, aggregate(data$RRT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), mean, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
names(GrandMean) <- c('WordNum', 'Condition', 'RRT', 'RRT.std', 'RT', 'RT.std')
GrandMean <- GrandMean[order(as.integer(as.vector(GrandMean$WordNum))),]

par(mfrow=c(1,1), mar=c(5,4,3,3))
ed <- subset(GrandMean, Condition=="high-did") #names carried over from other experiments; used to be: e=every, w-which
ew <- subset(GrandMean, Condition=="high-was")
wd <- subset(GrandMean, Condition=="low-did")
ww <- subset(GrandMean, Condition=="low-was")

# NELS trimming:
ed <- ed[0:22,]
ew <- ew[0:22,]
wd <- wd[0:22,]
ww <- ww[0:22,]

# plot RRTs for correctly answered trials ----
plot(as.vector(ed$WordNum), ed$RRT, xlim=c(2,22), ylim=c(-50,90), type="l", col='white', pch=1, ylab="RRTs", xlab="", xaxt='n')
points(as.vector(ed$WordNum), ed$RRT, col="red", type="b", lty = "solid", pch=1)
points(as.vector(ew$WordNum), ew$RRT, col="red", type="b", lty = "dotted", pch=3)
points(as.vector(wd$WordNum), wd$RRT, col="blue", type="b", lty = "solid", pch=1)
points(as.vector(ww$WordNum), ww$RRT, col="blue", type="b", lty = "dotted", pch=3)
#points(as.vector(FilGrandMean$WordNum), FilGrandMean$RRT, col="black", type="b", lty = "solid", pch=4)

errbar(x=1:21, y=ed$RRT, yplus=ed$RRT+ed$RRT.std, yminus=ed$RRT-ed$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=ew$RRT, yplus=ew$RRT+ew$RRT.std, yminus=ew$RRT-ew$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=wd$RRT, yplus=wd$RRT+wd$RRT.std, yminus=wd$RRT-wd$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
errbar(x=1:21, y=ww$RRT, yplus=ww$RRT+ww$RRT.std, yminus=ww$RRT-ww$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
#errbar(x=as.vector(FilGrandMean$WordNum), y=FilGrandMean$RRT, yplus=FilGrandMean$RRT+FilGrandMean$RRT.std, yminus=FilGrandMean$RRT-FilGrandMean$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'purple')

legend("topleft",y.intersp=0.6,text.width=4, pch=c(1,3,1,3,4), legend=legend, col=c("red", "red", "blue", "blue", "black"), lty=c("solid", "dotted", "solid", "solid"), bty='n')
text(seq(1,22,by=1),par("usr")[3]-10,srt=45,adj=1,labels=x_lab,xpd=T,cex=0.8)
title(main=paste(sep="", expname, " RRTs correctly answered trials (n=", length(unique(data$WorkerId)),")"))

# plot raw RTs correctly answered trials ----
plot(as.vector(ed$WordNum), ed$RT, xlim=c(2,22), ylim=c(320,500), type="l", col='white', pch=1, ylab="raw RTs", xlab="", xaxt='n')
points(as.vector(ed$WordNum), ed$RT, col="red", type="b", lty = "solid", pch=1)
points(as.vector(ew$WordNum), ew$RT, col="red", type="b", lty = "dotted", pch=3)
points(as.vector(wd$WordNum), wd$RT, col="blue", type="b", lty = "solid", pch=1)
points(as.vector(ww$WordNum), ww$RT, col="blue", type="b", lty = "dotted", pch=3)
#points(as.vector(FilGrandMean$WordNum), FilGrandMean$RT, col="black", type="b", lty = "solid", pch=4)

errbar(x=1:21, y=ed$RT, yplus=ed$RT+ed$RT.std, yminus=ed$RT-ed$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=ew$RT, yplus=ew$RT+ew$RT.std, yminus=ew$RT-ew$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=wd$RT, yplus=wd$RT+wd$RT.std, yminus=wd$RT-wd$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
errbar(x=1:21, y=ww$RT, yplus=ww$RT+ww$RT.std, yminus=ww$RT-ww$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
#errbar(x=as.vector(FilGrandMean$WordNum), y=FilGrandMean$RRT, yplus=FilGrandMean$RRT+FilGrandMean$RRT.std, yminus=FilGrandMean$RRT-FilGrandMean$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'black')

legend("topleft",y.intersp=0.6,text.width=4, pch=c(1,3,1,3,4), legend=legend, col=c("red", "red", "blue", "blue", "black"), lty=c("solid", "dotted", "solid", "solid"), bty='n')
text(seq(1,22,by=1),par("usr")[3]-10,srt=45,adj=1,labels=x_lab,xpd=T,cex=0.8)
title(main=paste(sep="", expname, " RTs correctly answered trials (n=", length(unique(data$WorkerId)),")"))

# setting up for plotting criterion trimming ----
data <- ctrimmed

GrandMean <- aggregate(data$RRT, by=list(data$WordNum, data$Condition), mean, na.rm=T)
GrandMean <- cbind(GrandMean, aggregate(data$RRT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), mean, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
names(GrandMean) <- c('WordNum', 'Condition', 'RRT', 'RRT.std', 'RT', 'RT.std')
GrandMean <- GrandMean[order(as.integer(as.vector(GrandMean$WordNum))),]

par(mfrow=c(1,1), mar=c(5,4,3,3))
ed <- subset(GrandMean, Condition=="high-did") #names carried over from other experiments; used to be: e=every, w-which
ew <- subset(GrandMean, Condition=="high-was")
wd <- subset(GrandMean, Condition=="low-did")
ww <- subset(GrandMean, Condition=="low-was")

# NELS trimming:
ed <- ed[0:22,]
ew <- ew[0:22,]
wd <- wd[0:22,]
ww <- ww[0:22,]

# plot RRTs criterion trimming ----
plot(as.vector(ed$WordNum), ed$RRT, xlim=c(2,22), ylim=c(-50,60), type="l", col='white', pch=1, ylab="RRTs", xlab="", xaxt='n')
points(as.vector(ed$WordNum), ed$RRT, col="red", type="b", lty = "solid", pch=1)
points(as.vector(ew$WordNum), ew$RRT, col="red", type="b", lty = "dotted", pch=3)
points(as.vector(wd$WordNum), wd$RRT, col="blue", type="b", lty = "solid", pch=1)
points(as.vector(ww$WordNum), ww$RRT, col="blue", type="b", lty = "dotted", pch=3)
#points(as.vector(FilGrandMean$WordNum), FilGrandMean$RRT, col="black", type="b", lty = "solid", pch=4)

errbar(x=1:21, y=ed$RRT, yplus=ed$RRT+ed$RRT.std, yminus=ed$RRT-ed$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=ew$RRT, yplus=ew$RRT+ew$RRT.std, yminus=ew$RRT-ew$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:21, y=wd$RRT, yplus=wd$RRT+wd$RRT.std, yminus=wd$RRT-wd$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
errbar(x=1:21, y=ww$RRT, yplus=ww$RRT+ww$RRT.std, yminus=ww$RRT-ww$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
#errbar(x=as.vector(FilGrandMean$WordNum), y=FilGrandMean$RRT, yplus=FilGrandMean$RRT+FilGrandMean$RRT.std, yminus=FilGrandMean$RRT-FilGrandMean$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'purple')

legend("topleft",y.intersp=0.6,text.width=4, pch=c(1,3,1,3,4), legend=legend, col=c("red", "red", "blue", "blue", "black"), lty=c("solid", "dotted", "solid", "solid"), bty='n')
text(seq(1,22,by=1),par("usr")[3]-10,srt=45,adj=1,labels=x_lab,xpd=T,cex=0.8)
title(main=paste(sep="", expname, " RRTs, criterion trimming (n=", length(unique(data$WorkerId)),")"))

# plot raw RTs criterion trimming ----
plot(as.vector(ed$WordNum), ed$RT, xlim=c(2,22), ylim=c(320,450), type="l", col='white', pch=1, ylab="raw RTs", xlab="", xaxt='n')
points(as.vector(ed$WordNum), ed$RT, col="red", type="b", lty = "solid", pch=1)
points(as.vector(ew$WordNum), ew$RT, col="red", type="b", lty = "dotted", pch=3)
points(as.vector(wd$WordNum), wd$RT, col="blue", type="b", lty = "solid", pch=1)
points(as.vector(ww$WordNum), ww$RT, col="blue", type="b", lty = "dotted", pch=3)
#points(as.vector(FilGrandMean$WordNum), FilGrandMean$RT, col="black", type="b", lty = "solid", pch=4)

errbar(x=1:22, y=ed$RT, yplus=ed$RT+ed$RT.std, yminus=ed$RT-ed$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:22, y=ew$RT, yplus=ew$RT+ew$RT.std, yminus=ew$RT-ew$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'red')
errbar(x=1:22, y=wd$RT, yplus=wd$RT+wd$RT.std, yminus=wd$RT-wd$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
errbar(x=1:22, y=ww$RT, yplus=ww$RT+ww$RT.std, yminus=ww$RT-ww$RT.std, add=TRUE, pch="", lwd=1, errbar.col = 'blue')
#errbar(x=as.vector(FilGrandMean$WordNum), y=FilGrandMean$RRT, yplus=FilGrandMean$RRT+FilGrandMean$RRT.std, yminus=FilGrandMean$RRT-FilGrandMean$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'black')

legend("topleft",y.intersp=0.6,text.width=4, pch=c(1,3,1,3,4), legend=legend, col=c("red", "red", "blue", "blue", "black"), lty=c("solid", "dotted", "solid", "solid"), bty='n')
text(seq(1,22,by=1),par("usr")[3]-10,srt=45,adj=1,labels=x_lab,xpd=T,cex=0.8)
title(main=paste(sep="", expname, " RTs, criterion trimming (n=", length(unique(data$WorkerId)),")"))

#rm(GrandMean, data, ed, ew, wd, ww, x_lab, FilGrandMean, fildata, legend)

# setting up for plotting criterion trimming, region of interest only ----
data <- ctrimmed

GrandMean <- aggregate(data$RRT, by=list(data$WordNum, data$Condition), mean, na.rm=T)
GrandMean <- cbind(GrandMean, aggregate(data$RRT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), mean, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
names(GrandMean) <- c('WordNum', 'Condition', 'RRT', 'RRT.std', 'RT', 'RT.std')
GrandMean <- GrandMean[order(as.integer(as.vector(GrandMean$WordNum))),]

par(mfrow=c(1,1), mar=c(5,4,3,3))
ed <- subset(GrandMean, Condition=="high-did") #names carried over from other experiments; used to be: e=every, w-which
ew <- subset(GrandMean, Condition=="high-was")
wd <- subset(GrandMean, Condition=="low-did")
ww <- subset(GrandMean, Condition=="low-was")

# PAPER trimming:
ed <- ed[6:22,]
ew <- ew[6:22,]
wd <- wd[6:22,]
ww <- ww[6:22,]

# plot RRTs criterion trimming ----
plot(as.vector(ed$WordNum), ed$RRT, xlim=c(6,22), ylim=c(-60,60), type="l", col='white', pch=1, ylab="RRTs", xlab="", xaxt='n')
points(as.vector(ed$WordNum), ed$RRT, col="red", type="b", lty = "solid", pch=1)
points(as.vector(ew$WordNum), ew$RRT, col="red", type="b", lty = "dotted", pch=3)
points(as.vector(wd$WordNum), wd$RRT, col="blue", type="b", lty = "solid", pch=1)
points(as.vector(ww$WordNum), ww$RRT, col="blue", type="b", lty = "dotted", pch=3)
points(as.vector(FilGrandMean$WordNum), FilGrandMean$RRT, col="black", type="b", lty = "solid", pch=4)

errbar(x=6:22, y=ed$RRT, yplus=ed$RRT+ed$RRT.std, yminus=ed$RRT-ed$RRT.std, add=TRUE, pch="", lwd=0.9, errbar.col = 'grey')
errbar(x=6:22, y=ew$RRT, yplus=ew$RRT+ew$RRT.std, yminus=ew$RRT-ew$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'grey')
errbar(x=6:22, y=wd$RRT, yplus=wd$RRT+wd$RRT.std, yminus=wd$RRT-wd$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'grey')
errbar(x=6:22, y=ww$RRT, yplus=ww$RRT+ww$RRT.std, yminus=ww$RRT-ww$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'grey')
#errbar(x=as.vector(FilGrandMean$WordNum), y=FilGrandMean$RRT, yplus=FilGrandMean$RRT+FilGrandMean$RRT.std, yminus=FilGrandMean$RRT-FilGrandMean$RRT.std, add=TRUE, pch="", lwd=1, errbar.col = 'purple')

legend <- c("high-did", "high-was", "low-did", "low-was")
legend("topleft",y.intersp=0.6,text.width=4, pch=c(1,3,1,3,4), legend=legend, col=c("red", "red", "blue", "blue", "black"), lty=c("solid", "dotted", "solid", "dotted"), bty="n")
x_lab=c("was", "also/willing", "willing/to", "to/also", "perform", "which" ,"concerto" ,"that" ,"the", "brilliant" ,"protege", "did/was", "and" ,"restructured", "the" ,"rehearsal" ,"accordingly")

text(seq(6,22,by=1),par("usr")[3]-10,srt=45,adj=1,labels=x_lab,xpd=T,cex=0.9)
#title(main=paste(sep="", "Residual reading times in Experiment 1 (n=", length(unique(data$WorkerId)),")"))
highlightColor <- rgb(0,0.5,0.5,0.1)
rect(18.5,-100,20.5,100, col=highlightColor, border=NA)
rect(7.5,-100,8.5,100, col=highlightColor, border=NA)
rect(9.5,-100,10.5,100, col=highlightColor, border=NA)
#par(xaxp=c(10,25,3))
grid()


# boxplots ----
boxplot(subset(ctrimmed, WordNum == 19 & Condition == 'low-did')$RT, 
        subset(ctrimmed, WordNum == 19 & Condition == 'high-did')$RT,
        subset(ctrimmed, WordNum == 19 & Condition == 'low-was')$RT,
        subset(ctrimmed, WordNum == 19 & Condition == 'high-was')$RT,
        xlab="", xaxt='n', outline=FALSE) #, notch=TRUE
text(1:4, y=50, labels=c('low-did', 'high-did', 'low-was', 'high-was'),xpd=T, cex=1.2)
title(main=paste(sep="", expname, " RTs, word 19"))

boxplot(subset(ctrimmed, WordNum == 19 & Condition == 'low-did')$RRT, 
        subset(ctrimmed, WordNum == 19 & Condition == 'high-did')$RRT,
        subset(ctrimmed, WordNum == 19 & Condition == 'low-was')$RRT,
        subset(ctrimmed, WordNum == 19 & Condition == 'high-was')$RRT,
        xlab="", xaxt='n', outline=FALSE)
text(1:4, y=-370, labels=c('low-did', 'high-did', 'low-was', 'high-was'),xpd=T, cex=1.2)
title(main=paste(sep="", expname, " RRTs, word 19"))

boxplot(subset(ctrimmed, WordNum == 19 & Condition == 'low-did')$logRT, 
        subset(ctrimmed, WordNum == 19 & Condition == 'high-did')$logRT,
        subset(ctrimmed, WordNum == 19 & Condition == 'low-was')$logRT,
        subset(ctrimmed, WordNum == 19 & Condition == 'high-was')$logRT,
        xlab="", xaxt='n', outline=FALSE)
text(1:4, y=4.6, labels=c('low-did', 'high-did', 'low-was', 'high-was'),xpd=T, cex=1.2)
title(main=paste(sep="", expname, " logRTs, word 19"))


# save data for graphing in excel ----
data <- subset(ctrimmed, WordNum == 19)
GrandMean <- aggregate(data$logRT, by=list(data$WordNum, data$Condition), mean, na.rm=T)
GrandMean <- cbind(GrandMean, aggregate(data$logRT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RRT, by=list(data$WordNum, data$Condition), mean, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RRT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), mean, na.rm=T)[,3])
GrandMean <- cbind(GrandMean, aggregate(data$RT, by=list(data$WordNum, data$Condition), std.error, na.rm=T)[,3])
names(GrandMean) <- c('WordNum', 'Condition', 'logRT', 'logRT.std', 'RRT', 'RRT.std', 'RT', 'RT.std')
write.csv(GrandMean, 'graphingExp3-Word19.csv')


# Stats ----
#linear model
library(lme4)
data <- trimmed
data <- targets
data <- ctrimmed

# look at word 19:
Word <- subset(data, WordNum == 19)

model <- lmer(logRT ~ Also*Verb + (1|WorkerId)+(1|Item),data=Word,na.action=na.exclude, verbose = TRUE)
summary(model)
null <- lmer(logRT ~ Also + (1|WorkerId)+(1|Item),data=Word,na.action=na.exclude, verbose = TRUE)
anova(model, null)

model <- lmer(RRT ~ Also*Verb + (1|WorkerId)+(1|Item),data=Word,na.action=na.exclude, verbose = TRUE)
summary(model)
null <- lmer(RRT ~ Also + (1|WorkerId)+(1|Item),data=Word,na.action=na.exclude, verbose = TRUE)
anova(model, null)

lmer(RT ~ Also*Verb + (1|WorkerId)+(1|Item),data=Word,na.action=na.exclude, verbose = TRUE)
lmer(RT ~ Also + (1|WorkerId)+(1|Item),data=Word,na.action=na.exclude, verbose = TRUE)

# would have been nice to have better random effects, but those don't converge atm

# anovas, as per reviewer request
data <- trimmed
data <- targets
data <- ctrimmed

Word <- subset(data, WordNum == 19)  
Word <- subset(data, WordNum %in% c(18:20))
pooled <- aggregate(Word$RT, by=list(WorkerId = Word$WorkerId, Item = Word$Item, Also = Word$Also, Verb = Word$Verb), FUN = sum)
pooled <- cbind(pooled, aggregate(Word$RRT, by=list(WorkerId = Word$WorkerId, Item = Word$Item, Also = Word$Also, Verb = Word$Verb), FUN = sum)$x)
pooled <- cbind(pooled, aggregate(Word$logRT, by=list(WorkerId = Word$WorkerId, Item = Word$Item, Also = Word$Also, Verb = Word$Verb), FUN = sum)$x)
names(pooled) <- c('WorkerId', 'Item', 'Also', 'Verb', 'RT', 'RRT', 'logRT')
Word <- pooled

# this makes interaction significant; seems legit. but no intercepts:
anova(lm(logRT ~ Also*Verb, data=Word))
