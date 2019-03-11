###################################################################################
#####  Analysis Script for the Mechanical Turk Experiment                     #####
#####  On the Y-N Gradient experiment (2C vs. 3C mild, balanced, unbalanced)  #####
#####  September 2012                                                         #####
#####  Hadas Kotek, modified and expanded from Yasutada Sudo 2010 code        #####
###################################################################################

### ----   TO SKIP INITIALIZATION GO TO LINE 480, LOAD INITIALIZED FILE THERE      ---- ###
### ----   INITIALIZED FILE BUILT WITH 75% ACCURACY ON MTN, INCLUDES 2ND LANGUAGE  ---- ###

### ---- Read in results files ----

file1 <- read.csv("C:/Users/Hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch1.csv",header=TRUE) # read in the first results file
file1 <- read.csv("C:/Users/Hadas desktop/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch1.csv",header=TRUE) 
file1 <- read.csv("/Users/hadas/Dropbox/Academic/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch1.csv",header=TRUE) # read in the first results file

file2 <- read.csv("C:/Users/Hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch2.csv",header=TRUE) # read in the second results file (with counter)
file2 <- read.csv("C:/Users/Hadas desktop/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch2.csv",header=TRUE) 
file2 <- read.csv("/Users/hadas/Dropbox/Academic/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch2.csv",header=TRUE) 

file2 <- file2[, !colnames(file2) %in% "Answer.practice"] #Get rid of answer to practice question since it was not logged in the previous batch

file3 <- read.csv("C:/Users/Hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch3.csv",header=TRUE) # read in the second results file (with counter)
file3 <- read.csv("C:/Users/Hadas desktop/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch3.csv",header=TRUE) 
file3 <- read.csv("/Users/hadas/Dropbox/Academic/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN batch3.csv",header=TRUE) # read in the second results file (with counter)

file3 <- file3[, !colnames(file3) %in% "Answer.practice"] #Get rid of answer to practice question since it was not logged in the previous batch

file <- rbind(file1, file2)
file$Answer.numanswered <- 108 #manually add this column for batches created before we added a counter
file$Answer.useragent <- "" #manually add this column for batches created before we added a counter

file <- rbind(file, file3)

## ---- Duplication Check -----

ids <- as.character(file$WorkerId) # Obtain the IDs
dup <- data.frame(WorkerId=ids, Duplicated=duplicated(ids)) # Mark the duplicated subjects
RejectDups <- NULL  #List of people to be rejected for doing more than one survey
RejectDid <- NULL #List of people to be rejected for not doing all the questions in a survey

for (did in subset(dup, Duplicated==TRUE)$WorkerId) { # For all duplicated subjects
  for (c in is.na(subset(file, WorkerId==did)$RejectionTime)) { # for each non-rejected row
    if (c==TRUE) {
      RejectDups <- rbind(RejectDups, did)
    }
  }
  file <- subset(file, WorkerId!=did) # Exclude the duplicated subjects from the analysis
}

rm(c, dup, did, ids, file1, file2, file3)

## ---- Initialization -----

cut.off.rate <- 75  # Accuracy cutoff
xenophobia <- 0   # Reject non mono-lingual English speakers
use.mtn <- 1  # Use accuracy of mtn items only 
 
targets <- names(file)[grep("Answer.2C", names(file),fixed=TRUE)] #target condition names: 2C-1, .. 2C-8
targets <- append(targets, names(file)[grep("Answer.3C",names(file),fixed=TRUE)]) #3C_Unbal-1, 3C_Bal-3, 3C_Mild-8 ..
fillers <- names(file)[grep("Answer.M", names(file),fixed=TRUE)] #filler condition names: Many, Mth, Prop
fillers <- append(fillers, names(file)[grep("Answer.Prop",names(file),fixed=TRUE)])

answers.f <- NULL  #Data frame for fillers
answers.t <- NULL  #Data frame for targets

## ---- Loop through subjects 

for (r in 1:nrow(file)) {
  
  id <- NULL
  exp <- NULL
  
  ## Get the WorkerId and display it
  id <- as.character(file[r,"WorkerId"])
  cat(id);cat("\n")
  
  ## Check the experiment type (is.element only works when the dataframe is transposed)
  most.flag <- 0
  if (is.element("Most of the dots are blue.",t(file[r,])[,1]) == TRUE) {exp <- "most";most.flag <- 1} else {exp <- "mth"}
  cat("\tDid ", exp, "\n", sep="")
  
  ## Check native language and second language
  non.native.flag <- 0
  foreign.flag <- 0
  
  if (is.na(file[r,"Answer.english"])) {
    cat("\tDid not answer native language question!\n")
    non.native.flag <- 1 }
  else if (file[r,"Answer.english"] == "no") {
    cat("\tNot a native speaker of English\n")
    non.native.flag <- 1 }
  
  if (is.na(file[r,"Answer.foreignlang"])) {
    cat("\tDid not answer foreign language question!\n")
    foreign.flag <- 1 }
  else if (file[r,"Answer.foreignlang"] == "yes") {
    cat("\tSpeaks another language\n")
    foreign.flag <- 1 }
  
  ## Check the answers
  tmp.ans.f <- data.frame(ID=id, Item=fillers, Answer=NA, NotAns=0, Truth=NA, NonNative=non.native.flag, ForeignLang=foreign.flag, Most=most.flag)
  tmp.ans.t <- data.frame(ID=id, Item=targets, Answer=NA, NotAns=0, Cat=NA, Col=NA, NonNative=non.native.flag, ForeignLang=foreign.flag, Most=most.flag)
  
  for (fil in fillers) {
    det <- strsplit(fil, split=".",fixed=TRUE)[[1]][2]
    truth <- as.character(substr(strsplit(fil, split=".",fixed=TRUE)[[1]][3], 1, 1))
    num <- as.numeric(substr(strsplit(fil, split=".",fixed=TRUE)[[1]][3], 2, nchar(strsplit(fil, split=".",fixed=TRUE)[[1]][3])))
    
    tmp.ans.f[tmp.ans.f$Item==fil,"Determiner"] <- det
    tmp.ans.f[tmp.ans.f$Item==fil,"Number"] <- num
    tmp.ans.f[tmp.ans.f$Item==fil,"Truth"] <- truth
    
    ## Record the answers for the fillers
    if (is.na(file[r,fil])) {
      tmp.ans.f[tmp.ans.f$Item==fil,"NotAns"] <- 1 }
    else {
      tmp.ans.f[tmp.ans.f$Item==fil,"Answer"] <- file[r,fil] }
  }
  
  for (tar in targets) {
    num <- as.numeric(strsplit(tar, split=".",fixed=TRUE)[[1]][3])
    tmp.ans.t[tmp.ans.t$Item==tar,"Number"] <- num
    cat <- as.character(strsplit(tar, split=".",fixed=TRUE)[[1]][2])
    tmp.ans.t[tmp.ans.t$Item==tar,"Cat"] <- cat
    
    if (substr(cat,1,1) == "2") {tmp.ans.t[tmp.ans.t$Item==tar,"Col"] <- "2"} else {if (substr(cat,1,1) == "3") {tmp.ans.t[tmp.ans.t$Item==tar,"Col"] <- "3"}}
    
    if (is.na(file[r,tar])) {
      tmp.ans.t[tmp.ans.t$Item==tar,"NotAns"] <- 1 }
    else {
      tmp.ans.t[tmp.ans.t$Item==tar,"Answer"]	<- file[r,tar] }
  }
  
  ## If there is an unanswered item, reject
  not.all.flag <- 0  
  if (sum(tmp.ans.f$NotAns) > 0|sum(tmp.ans.t$NotAns) > 0) {
    cat(paste("\tDid not answer all items: ", sum(tmp.ans.t$NotAns), "targets and ",sum(tmp.ans.f$NotAns), "fillers not answered\n"))
    not.all.flag <- 1
    not.yet.autoapproved <- difftime(as.POSIXlt(Sys.time(),"GMT"),strptime(paste(strsplit(as.character(file[r, "AutoApprovalTime"]),split=" ")[[1]][-5], collapse=" "), "%a %b %d %X %Y")) < 0
    if (file[r,"AssignmentStatus"]!="Rejected" & not.yet.autoapproved) {cat("\t*Needs to be rejected*\n"); RejectDid <- rbind(RejectDid, id)} else {cat("\tHas been rejected\n")}
  }
  
  ## Accuracy check for fillers 
  accuracy.f <- round(sum(nrow(subset(tmp.ans.f, Truth=="t"& Answer=="TRUE")), nrow(subset(tmp.ans.f, Truth=="f" & Answer == "FALSE")))/length(fillers),digits=3)*100
  low.acc.flag <- 0
  
  if (accuracy.f < cut.off.rate) {
    cat(paste("\tLow overall accuracy: ", accuracy.f, "%\n", sep=""))
    low.acc.flag <- 1 }
  else {
    cat(paste("\tOverall accuracy: ", accuracy.f, "%\n", sep="")) }
  
  ## Accuracy check for mtn items 
  mtn <- subset(tmp.ans.f, Determiner == "Mtn")
  accuracy.mtn <- round(sum(nrow(subset(mtn, Truth=="t" & Answer == "TRUE")), nrow(subset(mtn, Truth=="f" & Answer == "FALSE")))/nrow(mtn),digits=3)*100
  low.mtn.flag <- 0
  
  if (accuracy.mtn < cut.off.rate) {
    cat(paste("\tLow mtn accuracy: ", accuracy.mtn, "%\n", sep=""))
    low.mtn.flag <- 1 }
  else {
    cat(paste("\tMTN accuracy: ", accuracy.mtn, "%\n", sep="")) }
  
  ## Transform TRUE/FALSE into 1/0
  for (row in 1:nrow(tmp.ans.f)) {
    if (is.na(tmp.ans.f$Answer[row])) {next}
    else {
      if (tmp.ans.f$Answer[row]=="TRUE"){tmp.ans.f$Yes[row] <- 1}
      if (tmp.ans.f$Answer[row]=="FALSE"){tmp.ans.f$Yes[row] <- 0} }
  }

  for (row in 1:nrow(tmp.ans.t)) {
    if (is.na(tmp.ans.t$Answer[row])) {next}
    else {
      if (tmp.ans.t$Answer[row]=="TRUE"){tmp.ans.t$Yes[row] <- 1}
      if (tmp.ans.t$Answer[row]=="FALSE"){tmp.ans.t$Yes[row] <- 0} }
  }
  
  ## Log results 
  tmp.ans.f$Acc.Fil <- accuracy.f
  tmp.ans.t$Acc.Fil <- accuracy.f
  tmp.ans.f$Acc.Mtn <- accuracy.mtn
  tmp.ans.t$Acc.Mtn <- accuracy.mtn
  tmp.ans.f$NotAll <- not.all.flag
  tmp.ans.t$NotAll <- not.all.flag
  tmp.ans.f$LowAcc <- low.acc.flag
  tmp.ans.t$LowAcc <- low.acc.flag
  tmp.ans.f$LowMtn <- low.mtn.flag
  tmp.ans.t$LowMtn <- low.mtn.flag

  # Record the answers
  answers.f <- rbind(answers.f,tmp.ans.f)
  answers.t <- rbind(answers.t,tmp.ans.t)
}

rm(r, tmp.ans.t, tmp.ans.f, det, exp, fil, cat, id, not.all.flag, low.acc.flag, most.flag, non.native.flag, low.mtn.flag, foreign.flag, targets, fillers, num, tar, accuracy.f, accuracy.mtn, truth, not.yet.autoapproved, mtn, row)

## ---- Reject subjects in Turk ---- 

for (i in 1:nrow(RejectDups)){  #Reject for doing more than one survey
  cat(paste(RejectDups[i], " did more than one survey \n"))  
}
for (i in 1:nrow(RejectDid)){
  if (file[file$WorkerId == RejectDid[i],]$Answer.numanswered != "108"|is.na(file[file$WorkerId == RejectDid[i],]$Answer.numanswered)){  ##check that counter did not miss
    cat(paste(RejectDid[i], " did not answer all questions \n")) }
}

rm(RejectDups, RejectDid, i, file)

## ---- Exclude bad subjects from analysis, get numbers -----

#Get non-initialized numbers
length(unique(answers.t$ID))
length(unique(answers.t[answers.t$NotAll==1, "ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==1,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$ForeignLang==1,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Acc.Fil<cut.off.rate,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Acc.Mtn<cut.off.rate,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Most==1,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Most==0,"ID"]))

#Exclude non-native speakers & subjects who did not answer all questions
answers.t <- subset(answers.t, NonNative==0&NotAll==0)
answers.f <- subset(answers.f, NonNative==0&NotAll==0)                    

xenophobia <- 0

#Exclude 2nd language speakers
if (xenophobia == 1) {answers.t <- subset(answers.t, ForeignLang==0) 
                      answers.f <- subset(answers.f, ForeignLang==0)} 


#Exclude based on low accuracy
if (use.mtn == 1) {answers.t <- subset(answers.t, LowMtn==0)
                   answers.f <- subset(answers.f, LowMtn==0) }  #Use mtn accuracy
if (use.mtn == 0) {answers.t <- subset(answers.t, LowAcc==0) 
                   answers.f <- subset(answers.f, LowAcc==0) }  #use overall accuracy

#Get initialized numbers
length(unique(answers.t$ID))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$ForeignLang==1,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Acc.Fil<cut.off.rate,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Acc.Mtn<cut.off.rate,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Most==1,"ID"]))
length(unique(answers.t[answers.t$NotAll==0&answers.t$NonNative==0 & answers.t$Most==0,"ID"]))

rm(use.mtn, xenophobia, cut.off.rate)

## ---- Put Weber Fractions ---- (see table in paper)

answers.t$C2.Weber <- 0
answers.t$C3.Weber <- 0
answers.t$RedRatio <- 0
answers.t$Blue <- 0
answers.t$Non.Blue <- 0
answers.t$Yellow <- 0
answers.t$Red <- 0

answers.t[answers.t$Number==1, "C2.Weber"] <- 0.67
answers.t[answers.t$Number==1, "Blue"] <- 8
answers.t[answers.t$Number==1, "Non.Blue"] <- 12
answers.t[answers.t$Number==1, "Yellow"] <- 12

answers.t[answers.t$Number==2, "C2.Weber"] <- 0.75
answers.t[answers.t$Number==2, "Blue"] <- 9
answers.t[answers.t$Number==2, "Non.Blue"] <- 12
answers.t[answers.t$Number==2, "Yellow"] <- 12

answers.t[answers.t$Number==3, "C2.Weber"] <- 0.82
answers.t[answers.t$Number==3, "Blue"] <- 9
answers.t[answers.t$Number==3, "Non.Blue"] <- 11
answers.t[answers.t$Number==3, "Yellow"] <- 11

answers.t[answers.t$Number==4, "C2.Weber"] <- 0.91
answers.t[answers.t$Number==4, "Blue"] <- 10
answers.t[answers.t$Number==4, "Non.Blue"] <- 11
answers.t[answers.t$Number==4, "Yellow"] <- 11

answers.t[answers.t$Number==5, "C2.Weber"] <- 1
answers.t[answers.t$Number==5, "Blue"] <- 10
answers.t[answers.t$Number==5, "Non.Blue"] <- 10
answers.t[answers.t$Number==5, "Yellow"] <- 10

answers.t[answers.t$Number==6, "C2.Weber"] <- 1.1
answers.t[answers.t$Number==6, "Blue"] <- 11
answers.t[answers.t$Number==6, "Non.Blue"] <- 10
answers.t[answers.t$Number==6, "Yellow"] <- 10

answers.t[answers.t$Number==7, "C2.Weber"] <- 1.22
answers.t[answers.t$Number==7, "Blue"] <- 11
answers.t[answers.t$Number==7, "Non.Blue"] <- 9
answers.t[answers.t$Number==7, "Yellow"] <- 9

answers.t[answers.t$Number==8, "C2.Weber"] <- 1.33
answers.t[answers.t$Number==8, "Blue"] <- 12
answers.t[answers.t$Number==8, "Non.Blue"] <- 9
answers.t[answers.t$Number==8, "Yellow"] <- 9

answers.t[answers.t$Number==9, "C2.Weber"] <- 1.5
answers.t[answers.t$Number==9, "Blue"] <- 12
answers.t[answers.t$Number==9, "Non.Blue"] <- 8
answers.t[answers.t$Number==9, "Yellow"] <- 8


answers.t[answers.t$Number==1&answers.t$Cat=="2C", "C3.Weber"] <- 0.67
answers.t[answers.t$Number==2&answers.t$Cat=="2C", "C3.Weber"] <- 0.75
answers.t[answers.t$Number==3&answers.t$Cat=="2C", "C3.Weber"] <- 0.82
answers.t[answers.t$Number==4&answers.t$Cat=="2C", "C3.Weber"] <- 0.91
answers.t[answers.t$Number==5&answers.t$Cat=="2C", "C3.Weber"] <- 1
answers.t[answers.t$Number==6&answers.t$Cat=="2C", "C3.Weber"] <- 1.1
answers.t[answers.t$Number==7&answers.t$Cat=="2C", "C3.Weber"] <- 1.22
answers.t[answers.t$Number==8&answers.t$Cat=="2C", "C3.Weber"] <- 1.33
answers.t[answers.t$Number==9&answers.t$Cat=="2C", "C3.Weber"] <- 1.5


answers.t[answers.t$Number==1&answers.t$Cat=="2C", "RedRatio"] <- 0.67
answers.t[answers.t$Number==2&answers.t$Cat=="2C", "RedRatio"] <- 0.75
answers.t[answers.t$Number==3&answers.t$Cat=="2C", "RedRatio"] <- 0.82
answers.t[answers.t$Number==4&answers.t$Cat=="2C", "RedRatio"] <- 0.91
answers.t[answers.t$Number==5&answers.t$Cat=="2C", "RedRatio"] <- 1
answers.t[answers.t$Number==6&answers.t$Cat=="2C", "RedRatio"] <- 1.1
answers.t[answers.t$Number==7&answers.t$Cat=="2C", "RedRatio"] <- 1.22
answers.t[answers.t$Number==8&answers.t$Cat=="2C", "RedRatio"] <- 1.33
answers.t[answers.t$Number==9&answers.t$Cat=="2C", "RedRatio"] <- 1.5


answers.t[answers.t$Number==1&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 1.33
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Bal", "Yellow"] <- 6
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Bal", "RedRatio"] <- 1.33
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Bal", "Red"] <- 6

answers.t[answers.t$Number==2&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 1.5
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Bal", "Yellow"] <- 6
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Bal", "RedRatio"] <- 1.5
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Bal", "Red"] <- 6

answers.t[answers.t$Number==3&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 1.5
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Bal", "Yellow"] <- 6
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Bal", "RedRatio"] <- 2
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Bal", "Red"] <- 5

answers.t[answers.t$Number==4&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 1.67
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Bal", "Yellow"] <- 6
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Bal", "RedRatio"] <- 2
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Bal", "Red"] <- 5

answers.t[answers.t$Number==5&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 1.67
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Bal", "Yellow"] <- 6
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Bal", "RedRatio"] <- 2.5
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Bal", "Red"] <- 4

answers.t[answers.t$Number==6&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 2.2
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Bal", "Yellow"] <- 5
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Bal", "RedRatio"] <- 2.2
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Bal", "Red"] <- 5

answers.t[answers.t$Number==7&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 2.2
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Bal", "Yellow"] <- 5
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Bal", "RedRatio"] <- 2.75
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Bal", "Red"] <- 5

answers.t[answers.t$Number==8&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 2.4
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Bal", "Yellow"] <- 5
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Bal", "RedRatio"] <- 3
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Bal", "Red"] <- 4

answers.t[answers.t$Number==9&answers.t$Cat=="3C_Bal", "C3.Weber"] <- 3
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Bal", "Yellow"] <- 4
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Bal", "RedRatio"] <- 3
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Bal", "Red"] <- 4


answers.t[answers.t$Number==1&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 0.73
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Unbal", "Yellow"] <- 11
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 8
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==2&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 0.86
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Unbal", "Yellow"] <- 11
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 9
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==3&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 0.9
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Unbal", "Yellow"] <- 10
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 9
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==4&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 1
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Unbal", "Yellow"] <- 10
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 10
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==5&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 1.11
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Unbal", "Yellow"] <- 9
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 10
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==6&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 1.22
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Unbal", "Yellow"] <- 9
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 11
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==7&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 1.38
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Unbal", "Yellow"] <- 8
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 11
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==8&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 1.5
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Unbal", "Yellow"] <- 8
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 12
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Unbal", "Red"] <- 1

answers.t[answers.t$Number==9&answers.t$Cat=="3C_Unbal", "C3.Weber"] <- 1.71
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Unbal", "Yellow"] <- 7
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Unbal", "RedRatio"] <- 12
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Unbal", "Red"] <- 1


answers.t[answers.t$Number==1&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 0.89
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Mild", "Yellow"] <- 9
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Mild", "RedRatio"] <- 2.66
answers.t[answers.t$Number==1&answers.t$Cat=="3C_Mild", "Red"] <- 3

answers.t[answers.t$Number==2&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 1
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Mild", "Yellow"] <- 9
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Mild", "RedRatio"] <- 3
answers.t[answers.t$Number==2&answers.t$Cat=="3C_Mild", "Red"] <- 3

answers.t[answers.t$Number==3&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 1.13
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Mild", "Yellow"] <- 8
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Mild", "RedRatio"] <- 3
answers.t[answers.t$Number==3&answers.t$Cat=="3C_Mild", "Red"] <- 3

answers.t[answers.t$Number==4&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 1.25
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Mild", "Yellow"] <- 8
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Mild", "RedRatio"] <- 3.33
answers.t[answers.t$Number==4&answers.t$Cat=="3C_Mild", "Red"] <- 3

answers.t[answers.t$Number==5&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 1.42
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Mild", "Yellow"] <- 7
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Mild", "RedRatio"] <- 3.33
answers.t[answers.t$Number==5&answers.t$Cat=="3C_Mild", "Red"] <- 3

answers.t[answers.t$Number==6&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 1.57
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Mild", "Yellow"] <- 7
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Mild", "RedRatio"] <- 3.66
answers.t[answers.t$Number==6&answers.t$Cat=="3C_Mild", "Red"] <- 3

answers.t[answers.t$Number==7&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 1.83
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Mild", "Yellow"] <- 6
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Mild", "RedRatio"] <- 3.66
answers.t[answers.t$Number==7&answers.t$Cat=="3C_Mild", "Red"] <- 3

answers.t[answers.t$Number==8&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 1.71
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Mild", "Yellow"] <- 7
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Mild", "RedRatio"] <- 6
answers.t[answers.t$Number==8&answers.t$Cat=="3C_Mild", "Red"] <- 2

answers.t[answers.t$Number==9&answers.t$Cat=="3C_Mild", "C3.Weber"] <- 2
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Mild", "Yellow"] <- 6
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Mild", "RedRatio"] <- 6
answers.t[answers.t$Number==9&answers.t$Cat=="3C_Mild", "Red"] <- 2

## ---- Add Proportional and Superlative TC ---- 

answers.t$PropTC <- NA
answers.t$SupTC <- NA

for (r in 1:nrow(answers.t)){
  if (answers.t$C2.Weber[r] > 1){answers.t$PropTC[r] <- 1}
  if (answers.t$C2.Weber[r] <= 1){answers.t$PropTC[r] <- 0}
  if (answers.t$C3.Weber[r] > 1){answers.t$SupTC[r] <- 1}
  if (answers.t$C3.Weber[r] <= 1){answers.t$SupTC[r] <- 0}
}

## ---- save initialized file ----
#write.csv(answers.t, file = "C:/Users/Hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-t-initialized.csv", row.names=T)
#write.csv(answers.t, file = "C:/Users/Hadas desktop/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-t-initialized.csv", row.names=T)
#
#write.csv(answers.f, file = "C:/Users/Hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-f-initialized.csv", row.names=T)
#write.csv(answers.f, file = "C:/Users/Hadas desktop/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-f-initialized.csv", row.names=T)

## ---- Shortcut: load pre-initialized file (75% on MTN, includes 2 ----

answers.t <- read.csv("C:/Users/Hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-t-initialized.csv", header=TRUE)
answers.t <- read.csv("C:/Users/Hadas desktop/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-t-initialized.csv",header=TRUE) 
answers.t <- read.csv("/Users/hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-t-initialized.csv",header=TRUE) 
answers.t <- read.csv("GradientYN-t-initialized.csv",header=TRUE) 

answers.f <- read.csv("C:/Users/Hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-f-initialized.csv", header=TRUE)
answers.f <- read.csv("C:/Users/Hadas desktop/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-f-initialized.csv",header=TRUE)
answers.f <- read.csv("/Users/hadas/Dropbox/MIT/3 Hackl lab/1 Counting studies/SharedExperiments/MTurk experiments/Rating Experiments/Experiment 3 (Gradient-3C)/Gradient Y-N/Results/GradientYN-f-initialized.csv", header=TRUE)
answers.f <- read.csv("GradientYN-f-initialized.csv",header=TRUE)

## ---- create most and more than half data frames ----

mosts <- subset(answers.t, Most==1)
mths <- subset(answers.t, Most==0)

## ---- Sort subjects (use bal vs. unbal Numbers 1-4) ----

sup.subj <- NULL
prop.subj <- NULL
mosts$PropSub <- NA

for (sub in unique(mosts$ID)) {
  tmp <- subset(mosts, ID==sub)
  num.f.Bal <- nrow(subset(tmp, tmp$Cat=="3C_Bal" & tmp$Number<=5 & tmp$Answer=="FALSE"))
  num.f.Unbal <- nrow(subset(tmp, tmp$Cat=="3C_Unbal" & tmp$Number<=5 & tmp$Answer=="FALSE"))
  
  if (num.f.Bal < num.f.Unbal) {
    sup.subj <- append(sup.subj, sub) 
    mosts[mosts$ID == sub,]$PropSub <- 0 }
  else {
    prop.subj <- append(prop.subj, sub) 
    mosts[mosts$ID == sub,]$PropSub <- 1 }
  }

num.sup <- length(sup.subj) 
num.prop <- length(prop.subj) 

sup <- mosts[is.element(mosts$ID, sup.subj),]
prop <- mosts[is.element(mosts$ID, prop.subj),]


rm(tmp, sub, num.f.Bal, num.f.Unbal, prop.subj, sup.subj, num.prop, num.sup)

## ---- sanity check: create sup vs. prop participants for mth

mth.sup.subj <- NULL
mth.prop.subj <- NULL
mths$PropSub <- NA

for (sub in unique(mths$ID)) {
  tmp <- subset(mths, ID==sub)
  num.f.Bal <- nrow(subset(tmp, tmp$Cat=="3C_Bal" & tmp$Number<=5 & tmp$Answer=="FALSE"))
  num.f.Unbal <- nrow(subset(tmp, tmp$Cat=="3C_Unbal" & tmp$Number<=5 & tmp$Answer=="FALSE"))
  
  if (num.f.Bal < num.f.Unbal) {
    mth.sup.subj <- append(mth.sup.subj, sub) 
    mths[mths$ID == sub,]$PropSub <- 0 }
  else {
    mth.prop.subj <- append(mth.prop.subj, sub) 
    mths[mths$ID == sub,]$PropSub <- 1 }
}

num.sup <- length(mth.sup.subj) 
num.prop <- length(mth.prop.subj) 

mth.sup <- mths[is.element(mths$ID, mth.sup.subj),]
mth.prop <- mths[is.element(mths$ID, mth.prop.subj),]


rm(tmp, sub, num.f.Bal, num.f.Unbal, prop.subj, sup.subj, num.prop, num.sup)

## ---- load plotting packages ----

library(plotrix)
library(Hmisc)
library(scatterplot3d)
library(hexbin)

## ---- Create aggregate data for most and more than half ----

most.mu <- aggregate(mosts$Yes, by=list(mosts$C2.Weber, mosts$C3.Weber, mosts$Cat), mean)
most.se <- aggregate(mosts$Yes, by=list(mosts$C2.Weber, mosts$C3.Weber, mosts$Cat), std.error)  
most.mu <- most.mu[order(most.mu$Group.1),]
most.se <- most.se[order(most.se$Group.1),]

names(most.mu) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")
names(most.se) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")

most.mu <- most.mu[order(most.mu$C2.Weber, most.mu$C3.Weber),]
most.se <- most.se[order(most.mu$C2.Weber, most.mu$C3.Weber),]


mth.mu <- aggregate(mths$Yes, by=list(mths$C2.Weber, mths$C3.Weber, mths$Cat), mean)
mth.se <- aggregate(mths$Yes, by=list(mths$C2.Weber, mths$C3.Weber, mths$Cat), std.error)
mth.mu <- mth.mu[order(mth.mu$Group.1),]
mth.se <- mth.se[order(mth.se$Group.1),]

names(mth.mu) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")
names(mth.se) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")

mth.mu <- mth.mu[order(mth.mu$C2.Weber, mth.mu$C3.Weber),]
mth.se <- mth.se[order(mth.mu$C2.Weber, mth.mu$C3.Weber),]

## ---- Create aggregate data for superlative vs. proportional most ---- 

sup.mu <- aggregate(sup$Yes, by=list(sup$C2.Weber, sup$C3.Weber, sup$Cat), mean)
sup.se <- aggregate(sup$Yes, by=list(sup$C2.Weber, sup$C3.Weber, sup$Cat), std.error)
sup.mu <- sup.mu[order(sup.mu$Group.1),]
sup.se <- sup.se[order(sup.se$Group.1),]

names(sup.mu) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")
names(sup.se) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")

sup.mu <- sup.mu[order(sup.mu$C2.Weber, sup.mu$C3.Weber),]
sup.se <- sup.se[order(sup.mu$C2.Weber, sup.mu$C3.Weber),]


prop.mu <- aggregate(prop$Yes, by=list(prop$C2.Weber, prop$C3.Weber, prop$Cat), mean)
prop.se <- aggregate(prop$Yes, by=list(prop$C2.Weber, prop$C3.Weber, prop$Cat), std.error)
prop.mu <- prop.mu[order(prop.mu$Group.1),]
prop.se <- prop.se[order(prop.se$Group.1),]

names(prop.mu) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")
names(prop.se) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")

prop.mu <- prop.mu[order(prop.mu$C2.Weber, prop.mu$C3.Weber),]
prop.se <- prop.se[order(prop.mu$C2.Weber, prop.mu$C3.Weber),]

## ---- test: Create aggregate data for superlative vs. proportional mth ---- 

mth.sup.mu <- aggregate(mth.sup$Yes, by=list(mth.sup$C2.Weber, mth.sup$C3.Weber, mth.sup$Cat), mean)
mth.sup.se <- aggregate(mth.sup$Yes, by=list(mth.sup$C2.Weber, mth.sup$C3.Weber, mth.sup$Cat), std.error)
mth.sup.mu <- mth.sup.mu[order(mth.sup.mu$Group.1),]
mth.sup.se <- mth.sup.se[order(mth.sup.se$Group.1),]

names(mth.sup.mu) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")
names(mth.sup.se) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")

mth.sup.mu <- mth.sup.mu[order(mth.sup.mu$C2.Weber, mth.sup.mu$C3.Weber),]
mth.sup.se <- mth.sup.se[order(mth.sup.mu$C2.Weber, mth.sup.mu$C3.Weber),]

mth.prop.mu <- aggregate(mth.prop$Yes, by=list(mth.prop$C2.Weber, mth.prop$C3.Weber, mth.prop$Cat), mean)
mth.prop.se <- aggregate(mth.prop$Yes, by=list(mth.prop$C2.Weber, mth.prop$C3.Weber, mth.prop$Cat), std.error)
mth.prop.mu <- mth.prop.mu[order(mth.prop.mu$Group.1),]
mth.prop.se <- mth.prop.se[order(mth.prop.se$Group.1),]

names(mth.prop.mu) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")
names(mth.prop.se) <- c("C2.Weber", "C3.Weber", "Cat", "Yes")

mth.prop.mu <- mth.prop.mu[order(mth.prop.mu$C2.Weber, mth.prop.mu$C3.Weber),]
mth.prop.se <- mth.prop.se[order(mth.prop.mu$C2.Weber, mth.prop.mu$C3.Weber),]

##---- creating tables for excel/word plots ----
excel.prop.mu <- subset(prop.mu, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.prop.mu) <- c('type','2C')
excel.prop.mu$"3C-Unbal" <- subset(prop.mu, Cat == '3C_Unbal')$Yes
excel.prop.mu$"3C-Mild" <- subset(prop.mu, Cat == '3C_Mild')$Yes
excel.prop.mu$"3C-Bal" <- subset(prop.mu, Cat == '3C_Bal')$Yes
write.csv(excel.prop.mu, 'prop.mu.csv')

excel.prop.se <- subset(prop.se, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.prop.se) <- c('type','2C')
excel.prop.se$"3C-Unbal" <- subset(prop.se, Cat == '3C_Unbal')$Yes
excel.prop.se$"3C-Mild" <- subset(prop.se, Cat == '3C_Mild')$Yes
excel.prop.se$"3C-Bal" <- subset(prop.se, Cat == '3C_Bal')$Yes
write.csv(excel.prop.se, 'prop.se.csv')

excel.sup.mu <- subset(sup.mu, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.sup.mu) <- c('type','2C')
excel.sup.mu$"3C-Unbal" <- subset(sup.mu, Cat == '3C_Unbal')$Yes
excel.sup.mu$"3C-Mild" <- subset(sup.mu, Cat == '3C_Mild')$Yes
excel.sup.mu$"3C-Bal" <- subset(sup.mu, Cat == '3C_Bal')$Yes
write.csv(excel.sup.mu, 'sup.mu.csv')

excel.sup.se <- subset(sup.se, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.sup.se) <- c('type','2C')
excel.sup.se$"3C-Unbal" <- subset(sup.se, Cat == '3C_Unbal')$Yes
excel.sup.se$"3C-Mild" <- subset(sup.se, Cat == '3C_Mild')$Yes
excel.sup.se$"3C-Bal" <- subset(sup.se, Cat == '3C_Bal')$Yes
write.csv(excel.sup.se, 'sup.se.csv')

##---- test: creating tables for excel/word plots mth sup vs. prop ----

excel.mth.prop.mu <- subset(mth.prop.mu, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.mth.prop.mu) <- c('type','2C')
excel.mth.prop.mu$"3C-Unbal" <- subset(mth.prop.mu, Cat == '3C_Unbal')$Yes
excel.mth.prop.mu$"3C-Mild" <- subset(mth.prop.mu, Cat == '3C_Mild')$Yes
excel.mth.prop.mu$"3C-Bal" <- subset(mth.prop.mu, Cat == '3C_Bal')$Yes
write.csv(excel.mth.prop.mu, 'mth.prop.mu.csv')

excel.mth.prop.se <- subset(mth.prop.se, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.mth.prop.se) <- c('type','2C')
excel.mth.prop.se$"3C-Unbal" <- subset(mth.prop.se, Cat == '3C_Unbal')$Yes
excel.mth.prop.se$"3C-Mild" <- subset(mth.prop.se, Cat == '3C_Mild')$Yes
excel.mth.prop.se$"3C-Bal" <- subset(mth.prop.se, Cat == '3C_Bal')$Yes
write.csv(excel.mth.prop.se, 'mth.prop.se.csv')

excel.mth.sup.mu <- subset(mth.sup.mu, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.mth.sup.mu) <- c('type','2C')
excel.mth.sup.mu$"3C-Unbal" <- subset(mth.sup.mu, Cat == '3C_Unbal')$Yes
excel.mth.sup.mu$"3C-Mild" <- subset(mth.sup.mu, Cat == '3C_Mild')$Yes
excel.mth.sup.mu$"3C-Bal" <- subset(mth.sup.mu, Cat == '3C_Bal')$Yes
write.csv(excel.mth.sup.mu, 'mth.sup.mu.csv')

excel.mth.sup.se <- subset(mth.sup.se, Cat == '2C')[c("C2.Weber", "Yes")]
names(excel.mth.sup.se) <- c('type','2C')
excel.mth.sup.se$"3C-Unbal" <- subset(mth.sup.se, Cat == '3C_Unbal')$Yes
excel.mth.sup.se$"3C-Mild" <- subset(mth.sup.se, Cat == '3C_Mild')$Yes
excel.mth.sup.se$"3C-Bal" <- subset(mth.sup.se, Cat == '3C_Bal')$Yes
write.csv(excel.mth.sup.se, 'mth.sup.se.csv')

## ---- Plot most vs. mth ----

par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(most.mu, Cat=="2C")$C2.Weber, subset(most.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(most.mu, Cat=="2C")$C2.Weber, subset(most.mu, Cat=="2C")$Yes, labels=subset(most.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(most.mu, Cat=="3C_Bal")$C2.Weber, subset(most.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch="")
text(subset(most.mu, Cat=="3C_Bal")$C2.Weber, subset(most.mu, Cat=="3C_Bal")$Yes, labels=subset(most.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(most.mu, Cat=="3C_Unbal")$C2.Weber, subset(most.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch="")
text(subset(most.mu, Cat=="3C_Unbal")$C2.Weber, subset(most.mu, Cat=="3C_Unbal")$Yes, labels=subset(most.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(most.mu, Cat=="3C_Mild")$C2.Weber, subset(most.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch="")
text(subset(most.mu, Cat=="3C_Mild")$C2.Weber, subset(most.mu, Cat=="3C_Mild")$Yes, labels=subset(most.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col=4)

errbar(x=subset(most.mu, Cat=="2C")$C2.Weber, y=subset(most.mu, Cat=="2C")$Yes, yplus=subset(most.se, Cat=="2C")$Yes+subset(most.mu, Cat=="2C")$Yes, yminus=subset(most.mu, Cat=="2C")$Yes-subset(most.se, Cat=="2C")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(most.mu, Cat=="3C_Bal")$C2.Weber, y=subset(most.mu, Cat=="3C_Bal")$Yes, yplus=subset(most.se, Cat=="3C_Bal")$Yes+subset(most.mu, Cat=="3C_Bal")$Yes, yminus=subset(most.mu, Cat=="3C_Bal")$Yes-subset(most.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(most.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(most.mu, Cat=="3C_Unbal")$Yes, yplus=subset(most.se, Cat=="3C_Unbal")$Yes+subset(most.mu, Cat=="3C_Unbal")$Yes, yminus=subset(most.mu, Cat=="3C_Unbal")$Yes-subset(most.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(most.mu, Cat=="3C_Mild")$C2.Weber, y=subset(most.mu, Cat=="3C_Mild")$Yes, yplus=subset(most.se, Cat=="3C_Mild")$Yes+subset(most.mu, Cat=="3C_Mild")$Yes, yminus=subset(most.mu, Cat=="3C_Mild")$Yes-subset(most.se, Cat=="3C_Mild")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("2C", "3C_Unbal", "3C_Mild", "3C_Bal"), col=c(1,3,4,2), pch=c("2", "u", "m", "b"), lty=1)
title(main=paste(sep="","Most (n=", length(unique(mosts$ID)),")"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(mth.mu, Cat=="2C")$C2.Weber, subset(mth.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="2C")$C2.Weber, subset(mth.mu, Cat=="2C")$Yes, labels=subset(mth.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(mth.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch="")
text(subset(mth.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.mu, Cat=="3C_Bal")$Yes, labels=subset(mth.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch="")
text(subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.mu, Cat=="3C_Unbal")$Yes, labels=subset(mth.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(mth.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch="")
text(subset(mth.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.mu, Cat=="3C_Mild")$Yes, labels=subset(mth.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col=4)

errbar(x=subset(mth.mu, Cat=="2C")$C2.Weber, y=subset(mth.mu, Cat=="2C")$Yes, yplus=subset(mth.se, Cat=="2C")$Yes+subset(mth.mu, Cat=="2C")$Yes, yminus=subset(mth.mu, Cat=="2C")$Yes-subset(mth.se, Cat=="2C")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(mth.mu, Cat=="3C_Bal")$C2.Weber, y=subset(mth.mu, Cat=="3C_Bal")$Yes, yplus=subset(mth.se, Cat=="3C_Bal")$Yes+subset(mth.mu, Cat=="3C_Bal")$Yes, yminus=subset(mth.mu, Cat=="3C_Bal")$Yes-subset(mth.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(mth.mu, Cat=="3C_Unbal")$Yes, yplus=subset(mth.se, Cat=="3C_Unbal")$Yes+subset(mth.mu, Cat=="3C_Unbal")$Yes, yminus=subset(mth.mu, Cat=="3C_Unbal")$Yes-subset(mth.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(mth.mu, Cat=="3C_Mild")$C2.Weber, y=subset(mth.mu, Cat=="3C_Mild")$Yes, yplus=subset(mth.se, Cat=="3C_Mild")$Yes+subset(mth.mu, Cat=="3C_Mild")$Yes, yminus=subset(mth.mu, Cat=="3C_Mild")$Yes-subset(mth.se, Cat=="3C_Mild")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("2C", "3C_Unbal", "3C_Mild", "3C_Bal"), col=c(1,3,4,2), pch=c("2", "u", "m", "b"), lty=1)
title(main=paste("More Than Half (N=", length(unique(mths$ID)), ")",sep=""))

## ---- plot most: sup vs. prop ----

par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(prop.mu, Cat=="2C")$C2.Weber, subset(prop.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="2C")$C2.Weber, subset(prop.mu, Cat=="2C")$Yes, labels=subset(prop.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(prop.mu, Cat=="3C_Bal")$C2.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch="")
text(subset(prop.mu, Cat=="3C_Bal")$C2.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, labels=subset(prop.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch="")
text(subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, labels=subset(prop.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(prop.mu, Cat=="3C_Mild")$C2.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch="")
text(subset(prop.mu, Cat=="3C_Mild")$C2.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, labels=subset(prop.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col=4)

errbar(x=subset(prop.mu, Cat=="2C")$C2.Weber, y=subset(prop.mu, Cat=="2C")$Yes, yplus=subset(prop.se, Cat=="2C")$Yes+subset(prop.mu, Cat=="2C")$Yes, yminus=subset(prop.mu, Cat=="2C")$Yes-subset(prop.se, Cat=="2C")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Bal")$C2.Weber, y=subset(prop.mu, Cat=="3C_Bal")$Yes, yplus=subset(prop.se, Cat=="3C_Bal")$Yes+subset(prop.mu, Cat=="3C_Bal")$Yes, yminus=subset(prop.mu, Cat=="3C_Bal")$Yes-subset(prop.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(prop.mu, Cat=="3C_Unbal")$Yes, yplus=subset(prop.se, Cat=="3C_Unbal")$Yes+subset(prop.mu, Cat=="3C_Unbal")$Yes, yminus=subset(prop.mu, Cat=="3C_Unbal")$Yes-subset(prop.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Mild")$C2.Weber, y=subset(prop.mu, Cat=="3C_Mild")$Yes, yplus=subset(prop.se, Cat=="3C_Mild")$Yes+subset(prop.mu, Cat=="3C_Mild")$Yes, yminus=subset(prop.mu, Cat=="3C_Mild")$Yes-subset(prop.se, Cat=="3C_Mild")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("bottomright", legend=c("2C", "3C_Unbal", "3C_Mild", "3C_Bal"), col=c(1,3,4,2), pch=c("2", "u", "m", "b"), lty=1)
title(main=paste(sep="","Most-prop (n=", length(unique(prop$ID)),")"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(sup.mu, Cat=="2C")$C2.Weber, subset(sup.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(sup.mu, Cat=="2C")$C2.Weber, subset(sup.mu, Cat=="2C")$Yes, labels=subset(sup.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(sup.mu, Cat=="3C_Bal")$C2.Weber, subset(sup.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch="")
text(subset(sup.mu, Cat=="3C_Bal")$C2.Weber, subset(sup.mu, Cat=="3C_Bal")$Yes, labels=subset(sup.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(sup.mu, Cat=="3C_Unbal")$C2.Weber, subset(sup.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch="")
text(subset(sup.mu, Cat=="3C_Unbal")$C2.Weber, subset(sup.mu, Cat=="3C_Unbal")$Yes, labels=subset(sup.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(sup.mu, Cat=="3C_Mild")$C2.Weber, subset(sup.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch="")
text(subset(sup.mu, Cat=="3C_Mild")$C2.Weber, subset(sup.mu, Cat=="3C_Mild")$Yes, labels=subset(sup.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col=4)

errbar(x=subset(sup.mu, Cat=="2C")$C2.Weber, y=subset(sup.mu, Cat=="2C")$Yes, yplus=subset(sup.se, Cat=="2C")$Yes+subset(sup.mu, Cat=="2C")$Yes, yminus=subset(sup.mu, Cat=="2C")$Yes-subset(sup.se, Cat=="2C")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(sup.mu, Cat=="3C_Bal")$C2.Weber, y=subset(sup.mu, Cat=="3C_Bal")$Yes, yplus=subset(sup.se, Cat=="3C_Bal")$Yes+subset(sup.mu, Cat=="3C_Bal")$Yes, yminus=subset(sup.mu, Cat=="3C_Bal")$Yes-subset(sup.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(sup.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(sup.mu, Cat=="3C_Unbal")$Yes, yplus=subset(sup.se, Cat=="3C_Unbal")$Yes+subset(sup.mu, Cat=="3C_Unbal")$Yes, yminus=subset(sup.mu, Cat=="3C_Unbal")$Yes-subset(sup.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(sup.mu, Cat=="3C_Mild")$C2.Weber, y=subset(sup.mu, Cat=="3C_Mild")$Yes, yplus=subset(sup.se, Cat=="3C_Mild")$Yes+subset(sup.mu, Cat=="3C_Mild")$Yes, yminus=subset(sup.mu, Cat=="3C_Mild")$Yes-subset(sup.se, Cat=="3C_Mild")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("bottomright", legend=c("2C", "3C_Unbal", "3C_Mild", "3C_Bal"), col=c(1,3,4,2), pch=c("2", "u", "m", "b"), lty=1)
title(main=paste("Most-sup (N=", length(unique(sup$ID)), ")",sep=""))

## ---- test: plot most: sup vs. prop mth ----

par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(mth.prop.mu, Cat=="2C")$C2.Weber, subset(mth.prop.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.prop.mu, Cat=="2C")$C2.Weber, subset(mth.prop.mu, Cat=="2C")$Yes, labels=subset(mth.prop.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(mth.prop.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.prop.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch="")
text(subset(mth.prop.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.prop.mu, Cat=="3C_Bal")$Yes, labels=subset(mth.prop.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(mth.prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.prop.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch="")
text(subset(mth.prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.prop.mu, Cat=="3C_Unbal")$Yes, labels=subset(mth.prop.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(mth.prop.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.prop.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch="")
text(subset(mth.prop.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.prop.mu, Cat=="3C_Mild")$Yes, labels=subset(mth.prop.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col=4)

errbar(x=subset(mth.prop.mu, Cat=="2C")$C2.Weber, y=subset(mth.prop.mu, Cat=="2C")$Yes, yplus=subset(mth.prop.se, Cat=="2C")$Yes+subset(mth.prop.mu, Cat=="2C")$Yes, yminus=subset(mth.prop.mu, Cat=="2C")$Yes-subset(mth.prop.se, Cat=="2C")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(mth.prop.mu, Cat=="3C_Bal")$C2.Weber, y=subset(mth.prop.mu, Cat=="3C_Bal")$Yes, yplus=subset(mth.prop.se, Cat=="3C_Bal")$Yes+subset(mth.prop.mu, Cat=="3C_Bal")$Yes, yminus=subset(prop.mu, Cat=="3C_Bal")$Yes-subset(mth.prop.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(prop.mu, Cat=="3C_Unbal")$Yes, yplus=subset(mth.prop.se, Cat=="3C_Unbal")$Yes+subset(prop.mu, Cat=="3C_Unbal")$Yes, yminus=subset(prop.mu, Cat=="3C_Unbal")$Yes-subset(mth.prop.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Mild")$C2.Weber, y=subset(prop.mu, Cat=="3C_Mild")$Yes, yplus=subset(mth.prop.se, Cat=="3C_Mild")$Yes+subset(prop.mu, Cat=="3C_Mild")$Yes, yminus=subset(prop.mu, Cat=="3C_Mild")$Yes-subset(mth.prop.se, Cat=="3C_Mild")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("bottomright", legend=c("2C", "3C_Unbal", "3C_Mild", "3C_Bal"), col=c(1,3,4,2), pch=c("2", "u", "m", "b"), lty=1)
title(main=paste(sep="","MTH-prop (n=", length(unique(mth.prop$ID)),")"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(mth.sup.mu, Cat=="2C")$C2.Weber, subset(mth.sup.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.sup.mu, Cat=="2C")$C2.Weber, subset(mth.sup.mu, Cat=="2C")$Yes, labels=subset(mth.sup.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(mth.sup.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.sup.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch="")
text(subset(mth.sup.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.sup.mu, Cat=="3C_Bal")$Yes, labels=subset(mth.sup.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(mth.sup.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.sup.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch="")
text(subset(mth.sup.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.sup.mu, Cat=="3C_Unbal")$Yes, labels=subset(mth.sup.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(mth.sup.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.sup.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch="")
text(subset(mth.sup.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.sup.mu, Cat=="3C_Mild")$Yes, labels=subset(mth.sup.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col=4)

errbar(x=subset(mth.sup.mu, Cat=="2C")$C2.Weber, y=subset(mth.sup.mu, Cat=="2C")$Yes, yplus=subset(mth.sup.se, Cat=="2C")$Yes+subset(mth.sup.mu, Cat=="2C")$Yes, yminus=subset(mth.sup.mu, Cat=="2C")$Yes-subset(mth.sup.se, Cat=="2C")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(mth.sup.mu, Cat=="3C_Bal")$C2.Weber, y=subset(mth.sup.mu, Cat=="3C_Bal")$Yes, yplus=subset(mth.sup.se, Cat=="3C_Bal")$Yes+subset(mth.sup.mu, Cat=="3C_Bal")$Yes, yminus=subset(mth.sup.mu, Cat=="3C_Bal")$Yes-subset(mth.sup.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(mth.sup.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(mth.sup.mu, Cat=="3C_Unbal")$Yes, yplus=subset(mth.sup.se, Cat=="3C_Unbal")$Yes+subset(mth.sup.mu, Cat=="3C_Unbal")$Yes, yminus=subset(mth.sup.mu, Cat=="3C_Unbal")$Yes-subset(mth.sup.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)
errbar(x=subset(mth.sup.mu, Cat=="3C_Mild")$C2.Weber, y=subset(mth.sup.mu, Cat=="3C_Mild")$Yes, yplus=subset(mth.sup.se, Cat=="3C_Mild")$Yes+subset(mth.sup.mu, Cat=="3C_Mild")$Yes, yminus=subset(mth.sup.mu, Cat=="3C_Mild")$Yes-subset(mth.sup.se, Cat=="3C_Mild")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("bottomright", legend=c("2C", "3C_Unbal", "3C_Mild", "3C_Bal"), col=c(1,3,4,2), pch=c("2", "u", "m", "b"), lty=1)
title(main=paste("MTH-sup (N=", length(unique(mth.sup$ID)), ")",sep=""))

## ---- Plot individial conditions most and mth (2C,3C mild, etc.) ----

par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(most.mu, Cat=="2C")$C2.Weber, subset(most.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(most.mu, Cat=="2C")$C2.Weber, subset(most.mu, Cat=="2C")$Yes, labels=subset(most.mu, Cat=="2C")$C3.Weber, cex=0.75, col = "blue")
points(subset(mth.mu, Cat=="2C")$C2.Weber, subset(mth.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="2C")$C2.Weber, subset(mth.mu, Cat=="2C")$Yes, labels=subset(mth.mu, Cat=="2C")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(most.mu, Cat=="2C")$C2.Weber, y=subset(most.mu, Cat=="2C")$Yes, yplus=subset(most.se, Cat=="2C")$Yes+subset(most.mu, Cat=="2C")$Yes, yminus=subset(most.mu, Cat=="2C")$Yes-subset(most.se, Cat=="2C")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(mth.mu, Cat=="2C")$C2.Weber, y=subset(mth.mu, Cat=="2C")$Yes, yplus=subset(mth.se, Cat=="2C")$Yes+subset(mth.mu, Cat=="3C_Bal")$Yes, yminus=subset(mth.mu, Cat=="2C")$Yes-subset(mth.se, Cat=="2C")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("most", "mth"), col=c("blue", "red"), lty=1)
title(main=paste("Most vs. mth 2C"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(most.mu, Cat=="3C_Unbal")$C2.Weber, subset(most.mu, Cat=="3C_Unbal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(most.mu, Cat=="3C_Unbal")$C2.Weber, subset(most.mu, Cat=="3C_Unbal")$Yes, labels=subset(most.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col = "blue")
points(subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.mu, Cat=="3C_Unbal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.mu, Cat=="3C_Unbal")$Yes, labels=subset(mth.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(most.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(most.mu, Cat=="3C_Unbal")$Yes, yplus=subset(most.se, Cat=="3C_Unbal")$Yes+subset(most.mu, Cat=="3C_Unbal")$Yes, yminus=subset(most.mu, Cat=="3C_Unbal")$Yes-subset(most.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(mth.mu, Cat=="3C_Unbal")$Yes, yplus=subset(mth.se, Cat=="3C_Unbal")$Yes+subset(mth.mu, Cat=="3C_Unbal")$Yes, yminus=subset(mth.mu, Cat=="3C_Unbal")$Yes-subset(mth.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("most", "mth"), col=c("blue", "red"), lty=1)
title(main=paste("Most vs. mth 3C unbal"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(most.mu, Cat=="3C_Mild")$C2.Weber, subset(most.mu, Cat=="3C_Mild")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(most.mu, Cat=="3C_Mild")$C2.Weber, subset(most.mu, Cat=="3C_Mild")$Yes, labels=subset(most.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col = "blue")
points(subset(mth.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.mu, Cat=="3C_Mild")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.mu, Cat=="3C_Mild")$Yes, labels=subset(mth.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(most.mu, Cat=="3C_Mild")$C2.Weber, y=subset(most.mu, Cat=="3C_Mild")$Yes, yplus=subset(most.se, Cat=="3C_Mild")$Yes+subset(most.mu, Cat=="3C_Mild")$Yes, yminus=subset(most.mu, Cat=="3C_Mild")$Yes-subset(most.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(mth.mu, Cat=="3C_Mild")$C2.Weber, y=subset(mth.mu, Cat=="3C_Mild")$Yes, yplus=subset(mth.se, Cat=="3C_Mild")$Yes+subset(mth.mu, Cat=="3C_Mild")$Yes, yminus=subset(mth.mu, Cat=="3C_Mild")$Yes-subset(mth.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("most", "mth"), col=c("blue", "red"), lty=1)
title(main=paste("Most vs. mth 3C mild"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(most.mu, Cat=="3C_Bal")$C2.Weber, subset(most.mu, Cat=="3C_Bal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(most.mu, Cat=="3C_Bal")$C2.Weber, subset(most.mu, Cat=="3C_Bal")$Yes, labels=subset(most.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col = "blue")
points(subset(mth.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.mu, Cat=="3C_Bal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.mu, Cat=="3C_Bal")$Yes, labels=subset(mth.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(most.mu, Cat=="3C_Bal")$C2.Weber, y=subset(most.mu, Cat=="3C_Bal")$Yes, yplus=subset(most.se, Cat=="3C_Bal")$Yes+subset(most.mu, Cat=="3C_Bal")$Yes, yminus=subset(most.mu, Cat=="3C_Bal")$Yes-subset(most.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(mth.mu, Cat=="3C_Bal")$C2.Weber, y=subset(mth.mu, Cat=="3C_Bal")$Yes, yplus=subset(mth.se, Cat=="3C_Bal")$Yes+subset(mth.mu, Cat=="3C_Bal")$Yes, yminus=subset(mth.mu, Cat=="3C_Bal")$Yes-subset(mth.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("most", "mth"), col=c("blue", "red"), lty=1)
title(main=paste("Most vs. mth 3C balanced"))

## ---- Plot individial conditions mth and prop (2C,3C mild, etc.) ----

par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(mth.mu, Cat=="2C")$C2.Weber, subset(mth.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="2C")$C2.Weber, subset(mth.mu, Cat=="2C")$Yes, labels=subset(mth.mu, Cat=="2C")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="2C")$C2.Weber, subset(prop.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="2C")$C2.Weber, subset(prop.mu, Cat=="2C")$Yes, labels=subset(prop.mu, Cat=="2C")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(mth.mu, Cat=="2C")$C2.Weber, y=subset(mth.mu, Cat=="2C")$Yes, yplus=subset(mth.se, Cat=="2C")$Yes+subset(mth.mu, Cat=="2C")$Yes, yminus=subset(mth.mu, Cat=="2C")$Yes-subset(mth.se, Cat=="2C")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="2C")$C2.Weber, y=subset(prop.mu, Cat=="2C")$Yes, yplus=subset(prop.se, Cat=="2C")$Yes+subset(prop.mu, Cat=="2C")$Yes, yminus=subset(prop.mu, Cat=="2C")$Yes-subset(prop.se, Cat=="2C")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("mth", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("mth vs. prop 2C"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.mu, Cat=="3C_Unbal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, subset(mth.mu, Cat=="3C_Unbal")$Yes, labels=subset(mth.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, labels=subset(prop.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(mth.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(mth.mu, Cat=="3C_Unbal")$Yes, yplus=subset(mth.se, Cat=="3C_Unbal")$Yes+subset(mth.mu, Cat=="3C_Unbal")$Yes, yminus=subset(mth.mu, Cat=="3C_Unbal")$Yes-subset(mth.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(prop.mu, Cat=="3C_Unbal")$Yes, yplus=subset(prop.se, Cat=="3C_Unbal")$Yes+subset(prop.mu, Cat=="3C_Unbal")$Yes, yminus=subset(prop.mu, Cat=="3C_Unbal")$Yes-subset(prop.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("mth", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("mth vs. prop 3C unbal"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(mth.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.mu, Cat=="3C_Mild")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="3C_Mild")$C2.Weber, subset(mth.mu, Cat=="3C_Mild")$Yes, labels=subset(mth.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="3C_Mild")$C2.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="3C_Mild")$C2.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, labels=subset(prop.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(mth.mu, Cat=="3C_Mild")$C2.Weber, y=subset(mth.mu, Cat=="3C_Mild")$Yes, yplus=subset(mth.se, Cat=="3C_Mild")$Yes+subset(mth.mu, Cat=="3C_Mild")$Yes, yminus=subset(mth.mu, Cat=="3C_Mild")$Yes-subset(mth.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Mild")$C2.Weber, y=subset(prop.mu, Cat=="3C_Mild")$Yes, yplus=subset(prop.se, Cat=="3C_Mild")$Yes+subset(prop.mu, Cat=="3C_Mild")$Yes, yminus=subset(prop.mu, Cat=="3C_Mild")$Yes-subset(prop.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("mth", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("mth vs. prop 3C mild"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(mth.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.mu, Cat=="3C_Bal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(mth.mu, Cat=="3C_Bal")$C2.Weber, subset(mth.mu, Cat=="3C_Bal")$Yes, labels=subset(mth.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="3C_Bal")$C2.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="3C_Bal")$C2.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, labels=subset(prop.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(mth.mu, Cat=="3C_Bal")$C2.Weber, y=subset(mth.mu, Cat=="3C_Bal")$Yes, yplus=subset(mth.se, Cat=="3C_Bal")$Yes+subset(mth.mu, Cat=="3C_Bal")$Yes, yminus=subset(mth.mu, Cat=="3C_Bal")$Yes-subset(mth.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Bal")$C2.Weber, y=subset(prop.mu, Cat=="3C_Bal")$Yes, yplus=subset(prop.se, Cat=="3C_Bal")$Yes+subset(prop.mu, Cat=="3C_Bal")$Yes, yminus=subset(prop.mu, Cat=="3C_Bal")$Yes-subset(prop.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("mth", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("mth vs. prop 3C balanced"))

## ---- Plot individial conditions sup and prop (2C,3C mild, etc.) ----

par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(sup.mu, Cat=="2C")$C2.Weber, subset(sup.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(sup.mu, Cat=="2C")$C2.Weber, subset(sup.mu, Cat=="2C")$Yes, labels=subset(sup.mu, Cat=="2C")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="2C")$C2.Weber, subset(prop.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="2C")$C2.Weber, subset(prop.mu, Cat=="2C")$Yes, labels=subset(prop.mu, Cat=="2C")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(sup.mu, Cat=="2C")$C2.Weber, y=subset(sup.mu, Cat=="2C")$Yes, yplus=subset(sup.se, Cat=="2C")$Yes+subset(sup.mu, Cat=="2C")$Yes, yminus=subset(sup.mu, Cat=="2C")$Yes-subset(sup.se, Cat=="2C")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="2C")$C2.Weber, y=subset(prop.mu, Cat=="2C")$Yes, yplus=subset(prop.se, Cat=="2C")$Yes+subset(prop.mu, Cat=="2C")$Yes, yminus=subset(prop.mu, Cat=="2C")$Yes-subset(prop.se, Cat=="2C")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("sup", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("sup vs. prop 2C"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(sup.mu, Cat=="3C_Unbal")$C2.Weber, subset(sup.mu, Cat=="3C_Unbal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(sup.mu, Cat=="3C_Unbal")$C2.Weber, subset(sup.mu, Cat=="3C_Unbal")$Yes, labels=subset(sup.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, labels=subset(prop.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(sup.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(sup.mu, Cat=="3C_Unbal")$Yes, yplus=subset(sup.se, Cat=="3C_Unbal")$Yes+subset(sup.mu, Cat=="3C_Unbal")$Yes, yminus=subset(sup.mu, Cat=="3C_Unbal")$Yes-subset(sup.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Unbal")$C2.Weber, y=subset(prop.mu, Cat=="3C_Unbal")$Yes, yplus=subset(prop.se, Cat=="3C_Unbal")$Yes+subset(prop.mu, Cat=="3C_Unbal")$Yes, yminus=subset(prop.mu, Cat=="3C_Unbal")$Yes-subset(prop.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("sup", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("sup vs. prop 3C unbal"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(sup.mu, Cat=="3C_Mild")$C2.Weber, subset(sup.mu, Cat=="3C_Mild")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(sup.mu, Cat=="3C_Mild")$C2.Weber, subset(sup.mu, Cat=="3C_Mild")$Yes, labels=subset(sup.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="3C_Mild")$C2.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="3C_Mild")$C2.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, labels=subset(prop.mu, Cat=="3C_Mild")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(sup.mu, Cat=="3C_Mild")$C2.Weber, y=subset(sup.mu, Cat=="3C_Mild")$Yes, yplus=subset(sup.se, Cat=="3C_Mild")$Yes+subset(sup.mu, Cat=="3C_Mild")$Yes, yminus=subset(sup.mu, Cat=="3C_Mild")$Yes-subset(sup.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Mild")$C2.Weber, y=subset(prop.mu, Cat=="3C_Mild")$Yes, yplus=subset(prop.se, Cat=="3C_Mild")$Yes+subset(prop.mu, Cat=="3C_Mild")$Yes, yminus=subset(prop.mu, Cat=="3C_Mild")$Yes-subset(prop.se, Cat=="3C_Unbal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("sup", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("sup vs. prop 3C mild"))


par(mfrow=c(1,1), mar=c(5,4,3,3))

plot(subset(sup.mu, Cat=="3C_Bal")$C2.Weber, subset(sup.mu, Cat=="3C_Bal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "blue", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(sup.mu, Cat=="3C_Bal")$C2.Weber, subset(sup.mu, Cat=="3C_Bal")$Yes, labels=subset(sup.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col = "blue")
points(subset(prop.mu, Cat=="3C_Bal")$C2.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, ylim=c(0,1), xlim=c(0.6,1.5), type="b", col = "red", pch="", ylab="Percent Yes", xlab="Weber Fraction (blue/non-blue)")
text(subset(prop.mu, Cat=="3C_Bal")$C2.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, labels=subset(prop.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col = "red")

errbar(x=subset(sup.mu, Cat=="3C_Bal")$C2.Weber, y=subset(sup.mu, Cat=="3C_Bal")$Yes, yplus=subset(sup.se, Cat=="3C_Bal")$Yes+subset(sup.mu, Cat=="3C_Bal")$Yes, yminus=subset(sup.mu, Cat=="3C_Bal")$Yes-subset(sup.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", lwd=0.2)
errbar(x=subset(prop.mu, Cat=="3C_Bal")$C2.Weber, y=subset(prop.mu, Cat=="3C_Bal")$Yes, yplus=subset(prop.se, Cat=="3C_Bal")$Yes+subset(prop.mu, Cat=="3C_Bal")$Yes, yminus=subset(prop.mu, Cat=="3C_Bal")$Yes-subset(prop.se, Cat=="3C_Bal")$Yes, add=TRUE, pch="", col=2, lwd=0.2)

legend("topleft", legend=c("sup", "prop"), col=c("blue", "red"), lty=1)
title(main=paste("sup vs. prop 3C balanced"))

## ---- Plot most by 3C ratio: sup vs. prop ----

par(mfrow=c(1.5,1.5), mar=c(5,4,4,3))

plot(subset(sup.mu, Cat=="2C")$C3.Weber, subset(sup.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,3), type="b", pch=1, ylab="Percent Yes", xlab="Weber Fraction (blue/highest-non-blue)")
#text(subset(sup.mu, Cat=="2C")$C3.Weber, subset(sup.mu, Cat=="2C")$Yes, labels=subset(sup.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(sup.mu, Cat=="3C_Bal")$C3.Weber, subset(sup.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch=1)
#text(subset(sup.mu, Cat=="3C_Bal")$C3.Weber, subset(sup.mu, Cat=="3C_Bal")$Yes, labels=subset(sup.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(sup.mu, Cat=="3C_Unbal")$C3.Weber, subset(sup.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch=1)
#text(subset(sup.mu, Cat=="3C_Unbal")$C3.Weber, subset(sup.mu, Cat=="3C_Unbal")$Yes, labels=subset(sup.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(sup.mu, Cat=="3C_Mild")$C3.Weber, subset(sup.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch=1)
#text(subset(sup.mu, Cat=="3C_Mild")$C3.Weber, subset(sup.mu, Cat=="3C_Mild")$Yes, labels=subset(sup.mu, Cat=="3C_Mild")$3C.Weber, cex=0.75, col=4)

legend("bottomright", legend=c("2C", "3C_Bal", "3C_Unbal", "3C_Mild"), col=1:4, pch=1)
title(main=paste(sep="","YES percent by 3C ratio for most-sup"))


par(mfrow=c(1.5,1.5), mar=c(5,4,4,3))

plot(subset(prop.mu, Cat=="2C")$C3.Weber, subset(prop.mu, Cat=="2C")$Yes, ylim=c(0,1), xlim=c(0.6,3), type="b", pch=1, ylab="Percent Yes", xlab="Weber Fraction (blue/highest-non-blue)")
#text(subset(prop.mu, Cat=="2C")$C3.Weber, subset(prop.mu, Cat=="2C")$Yes, labels=subset(prop.mu, Cat=="2C")$C3.Weber, cex=0.75)
points(subset(prop.mu, Cat=="3C_Bal")$C3.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, col=2, type="b", pch=1)
#text(subset(prop.mu, Cat=="3C_Bal")$C3.Weber, subset(prop.mu, Cat=="3C_Bal")$Yes, labels=subset(prop.mu, Cat=="3C_Bal")$C3.Weber, cex=0.75, col=2)
points(subset(prop.mu, Cat=="3C_Unbal")$C3.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, col=3, type="b", pch=1)
#text(subset(prop.mu, Cat=="3C_Unbal")$C3.Weber, subset(prop.mu, Cat=="3C_Unbal")$Yes, labels=subset(prop.mu, Cat=="3C_Unbal")$C3.Weber, cex=0.75, col=3)
points(subset(prop.mu, Cat=="3C_Mild")$C3.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, col=4, type="b", pch=1)
#text(subset(prop.mu, Cat=="3C_Mild")$C3.Weber, subset(prop.mu, Cat=="3C_Mild")$Yes, labels=subset(prop.mu, Cat=="3C_Mild")$3C.Weber, cex=0.75, col=4)

legend("bottomright", legend=c("2C", "3C_Bal", "3C_Unbal", "3C_Mild"), col=1:4, pch=1)
title(main=paste(sep="","YES percent by 3C ratio for most-prop"))

## ---- Data plots: stripcharts, scatterplots, sunflowerplots ----

par(mfrow=c(1,1), mar=c(5,4,4,3))

data <- subset(mosts, Cat == "2C")
stripchart(data$Number ~ data$Yes, method = "jitter", jitter =.15); title(main = "Stripchart for Bal most")


scatterplot3d(most.mu$C2.Weber, most.mu$C3.Weber, most.mu$Yes, angle=30 , highlight.3d=TRUE, type="h")
title(main=paste(sep="","Scatterplot for most (all participants)"))

scatterplot3d(mth.mu$C2.Weber, mth.mu$C3.Weber, mth.mu$Yes, angle=30 , highlight.3d=TRUE, type="h")
title(main=paste(sep="","Scatterplot for more than half"))


Det <- c("Mtn", "Many", "Prop")
par(mfrow=c(1.5,1.5), mar=c(5,4,4,3))
for (d in Det){
  answers.tmp <- subset(answers.f, answers.f$Determiner == as.character(d) & Truth == "t")
  sunflowerplot(answers.tmp$Number , answers.tmp$Yes, xlab="Percent Yes ", ylab="Determiner ", ylim=c(0,1), xlim=c(1,12))
  title(main=paste("Percent Yes for", d, "-T"))
  answers.tmp <- subset(answers.f, answers.f$Determiner == as.character(d) & Truth == "f")
  sunflowerplot(answers.tmp$Number , answers.tmp$Yes, xlab="Percent Yes ", ylab="Determiner ", ylim=c(0,1), xlim=c(1,12))
  title(main=paste("Percent Yes for", d, "-F"))
  #bin <- hexbin(answers.tmp$Number, answers.tmp$Rating, xbins=30)
  #plot(bin, main=paste("Ratings for", d))
}

rm (d, Det, data, answers.tmp)


sunflowerplot(mosts$Number, mosts$Yes, xlab="Percent Yes ", ylab="Determiner ", ylim=c(0,1), xlim=c(1,8))
title(main=paste("Percent Yes for most"))

sunflowerplot(sup$Number, sup$Yes, xlab="Percent Yes ", ylab="Determiner ", ylim=c(0,1), xlim=c(1,8))
title(main=paste("Percent Yes for superlative most"))

sunflowerplot(prop$Number, prop$Yes, xlab="Percent Yes ", ylab="Determiner ", ylim=c(0,1), xlim=c(1,8))
title(main=paste("Percent Yes for proportional most"))

sunflowerplot(mths$Number, mths$Yes, xlab="Percent Yes ", ylab="Determiner ", ylim=c(0,1), xlim=c(1,8))
title(main=paste("Percent Yes for mth"))


# answers.tmp <- NULL
# answers.tmp <- subset(mosts, mosts$Cat =="3C_Bal")
# #answers.tmp <- subset(answers.f, answers.f$Determiner == "Mtn" & Truth == "t" & Number <= 6)
# #answers.tmp$Number <- answers.tmp$Number+6
# #answers.tmp <- rbind (answers.tmp, subset(answers.f, answers.f$Determiner == "Mtn" & Truth == "f" & Number <= 6))
# sunflowerplot(answers.tmp$Number , answers.tmp$Rating, xlab="Item ", ylab="Rating ", ylim=c(1,7), xlim=c(1,8))
# title(main=paste("Ratings for most 3C-Bal"))
# 
# answers.tmp <- NULL
# answers.tmp <- subset(sup, sup$Cat =="3C_Bal")
# sunflowerplot(answers.tmp$Number , answers.tmp$Rating, xlab="Item ", ylab="Rating ", ylim=c(1,7), xlim=c(1,8))
# title(main=paste("Ratings for sup-most 3C-Bal"))
# 
# answers.tmp <- NULL
# answers.tmp <- subset(sup, sup$Cat =="3C_Mild")
# sunflowerplot(answers.tmp$Number , answers.tmp$Rating, xlab="Item ", ylab="Rating ", ylim=c(1,7), xlim=c(1,8))
# title(main=paste("Ratings for sup-most 3C-Mild"))
# 
# answers.tmp <- NULL
# answers.tmp <- subset(prop, prop$Cat =="3C_Bal")
# sunflowerplot(answers.tmp$Number , answers.tmp$Rating, xlab="Item ", ylab="Rating ", ylim=c(1,7), xlim=c(1,8))
# title(main=paste("Ratings for prop-most 3C-Bal"))

# answers.tmp <- subset(answers.f, answers.f$Determiner == "Mtn" & Truth == "t" & Number <= 6)
# answers.tmp$Number <- answers.tmp$Number+6
# answers.tmp <- rbind (answers.tmp, subset(answers.f, answers.f$Determiner == "Mtn" & Truth == "f" & Number <= 6))
# sunflowerplot(answers.tmp$Number , answers.tmp$Rating, xlab="Rating ", ylab="Determiner ", ylim=c(1,7), xlim=c(1,12))
# title(main=paste("Ratings for mtn 2C"))
# 
# rm(answers.tmp)

## ---- Modeling: same/different ANS model (Lidz et al. 2011 p.243, Pica et al. 2004) ----

erfc <- function(x) 2 * pnorm(x * sqrt(2), lower = FALSE)  # erfc = complementary error function
mdl <- function(w,n1,n2) return(1/2*erfc((n1-n2)/(sqrt(2)*w*sqrt((n1^2)+(n2^2)))))

# Numerosities
pattern <- list(c(8,12),c(9,12),c(9,11),c(10,11), c(10,10), c(11,10),c(11,9),c(12,9),c(12,8)) #Blue/non blue
#pattern <-list(c(8,9),c(9,9),c(9,8),c(10,8),c(10,7), c(11,7),c(11,6),c(12,7),c(12,6)) #Blue/highest non blue mild

#data <- subset(prop.mu, Cat == "3C_Mild")

# mean accuracy per determiner/condition 
all.most <- c(.11,.17,.18,.23,.62,.79,.72,.78) #most 2C
all.most <- c(.24,.24,.35,.46,.64,.73,.78,.81) #most 3C_Bal
all.most <- c(.21,.19,.19,.38,.56,.78,.81,.83) #most 3C_Unbal
all.most <- c(.12,.22,.34,.43,.68,.72,.76,.81) #most 3C_Mild

all.mth  <- c(.07,.01,.07,.09,.76,.90,.88,.89) #mth 2C
all.mth  <- c(.09,.11,.11,.15,.68,.82,.83,.90) #mth 3C_Bal
all.mth  <- c(.11,.14,.10,.15,.69,.90,.87,.90) #mth 3C_Unbal
all.mth  <- c(.06,.07,.14,.20,.80,.78,.90,.93) #mth 3C_Mild

all.sup  <- c(.13,.17,.18,.25,.65,.81,.77,.85) #sup 2C
all.sup  <- c(.32,.38,.49,.60,.69,.82,.86,.84) #sup 3C_Bal
all.sup  <- c(.18,.18,.19,.39,.60,.82,.84,.87) #sup 3C_Unbal
all.sup  <- c(.14,.23,.46,.53,.77,.78,.81,.86) #sup 3C_Mild

all.prop <- c(.08,.18,.17,.20,.59,.77,.67,.71) #prop 2C
all.prop <- c(.14,.10,.19,.29,.59,.62,.68,.78) #prop 3C_Bal
all.prop <- c(.24,.20,.20,.38,.50,.72,.77,.77) #prop 3C_Unbal
all.prop <- c(.01,.21,.21,.32,.58,.64,.71,.76) #prop 3C_Mild

actual <- c(.70, .80, .75, .81)

# Actual mean % YES for the YES condition
actual <- c(.62,.79,.72,.78) #most 2C  
actual <- c(.76,.90,.88,.89) #mth 2C
actual <- c(.65,.81,.77,.85) #sup 2C
actual <- c(.59,.77,.67,.71) #prop 2C

actual <- c(.64,.73,.78,.81) #most 3C_Bal  
actual <- c(.68,.82,.83,.90) #mth 3C_Bal
actual <- c(.69,.82,.86,.84) #sup 3C_Bal
actual <- c(.59,.62,.68,.78) #prop 3C_Bal

actual <- c(.56,.78,.81,.83) #most 3C_Unbal  
actual <- c(.69,.90,.87,.90) #mth 3C_Unbal
actual <- c(.60,.82,.84,.87) #sup 3C_Unbal
actual <- c(.58,.64,.71,.76) #prop 3C_Unbal

actual <- c(.68,.72,.76,.81) #most 3C_Mild 
actual <- c(.80,.78,.90,.93) #mth 3C_Mild
actual <- c(.58,.64,.71,.76) #sup 3C_mild
actual <- c(.59,.77,.67,.71) #prop 3C_mild


# Try different values of w, looking for the best model
## NB: We are looking for the best model for the 4 YES conditions, rather than for all the 8 conditions
## (The model does a very bad job if you include all 8 conditions, which I think is telling something. I talked to Martin a bit about this.)

r2s <- data.frame(r2=NULL,w=NULL) # Data frame to store the r^2's and w's

for (w in seq(from=.05, to=.5, by=0.001)) { # Loop through w=0.1 to w=0.2
  d <- data.frame(beta=NULL,w.frac=NULL) # Temporary data frame storing the predictions of mdl for each condition
  for (i in 1:8) { # For each of the conditions i,
    blue <- pattern[[i]][1] # The number of blue dots
    yellow <- pattern[[i]][2] # The number of yellow dots
    if (blue > yellow) { # for the conditions where the answer is YES,
      d <- rbind(d,data.frame(beta=mdl(w,yellow, blue), w.frac=blue/yellow)) } # Store the predictions of mdl
#   if (yellow > blue) { # for the conditions where the answer is NO,
#     d <- rbind(d,data.frame(beta=mdl(w, blue, yellow), w.frac=blue/yellow)) } # Store the predictions of mdl     
  }
  r2 <- 1 - (sum((actual-d$beta)^2)/sum((actual-mean(actual))^2)) # Compute r^2
  r2s <- rbind(r2s,data.frame(r2=r2,w=w)) # Store the r^2 in r2s together with w
}

## The Best model

w = r2s[r2s$r2==max((r2s$r2)),"w"] # check the w that gives the best r^2
cat(paste("best w: ", w))

d <- NULL # This will contain the predictions of the best model
for (i in 1:9) { # For each of the 8 conditions,
  blue <- pattern[[i]][1] # The number of blue dots
  non.blue <- pattern[[i]][2] # The number of yellow dots
  d <- rbind(d,data.frame(beta=mdl(w,non.blue,blue), w.frac=blue/non.blue)) # Store the predictions
}

r2 <- 1 - (sum((all.most-d$beta)^2)/sum((all.most-mean(all.most))^2)) # Compute most r^2
r2 <- 1 - (sum((all.mth-d$beta)^2)/sum((all.mth-mean(all.mth))^2)) # Compute mth r^2
r2 <- 1 - (sum((all.sup-d$beta)^2)/sum((all.sup-mean(all.sup))^2)) # Compute sup r^2
r2 <- 1 - (sum((all.prop-d$beta)^2)/sum((all.prop-mean(all.prop))^2)) # Compute prop r^2
cat(paste("R^2 for all 8 items: ", r2)) 

all.prop <- c(.70, .80, .75, .81, .70, .80, .75, .81)
## Plot predicted vs. observed

plot(d$w.frac, d$beta, ylim=c(0,1), type="b", xlab = "Weber fraction", ylab = "YES percent", lty = 2) # Plot the predictions
lines(d$w.frac[1:9],all.most,col=2,type="b") # Overlay the actual data for the YES conditions
lines(d$w.frac[1:9],all.sup,col=6,type="b") # Overlay the actual data for the YES conditions
lines(d$w.frac[1:9],all.prop,col=3,type="b") # Overlay the actual data for the YES conditions
lines(d$w.frac[1:9],all.mth,col=4,type="b") # Overlay the actual data for the YES conditions

legend("topleft", legend=c("fitted", "most", "sup", "prop", "mth"), col=c(1,2,6,3,4), lty=c(2,1,1,1,1))
title(main=paste("Fitted vs. Observed"))

## ---- Add factors ----

#answers.t$Col <- factor(answers.t$Col, levels=c(2,3))
#levels(answers.t$Col) <- c("2-Colors", "3-Colors")
#answers.t$Cats <- factor(answers.t$Cat, levels=c("2C", "3C_Unbal", "3C_Mild", "3C_Bal"))
#answers.t$Numbers <- factor(answers.t$Number, levels=c(1:9))
answers.t$Yes <- factor(answers.t$Yes, levels=c(0:1))
answers.t$Exp <- factor(answers.t$Most, levels=c(0:1))
levels(answers.t$Exp) <- c("More than half", "Most")
answers.t$Det <- as.factor(ifelse(answers.t$Exp == "Most", 0.5, -0.5)) #contrast coding for determiner
answers.t$Participant <- as.factor(answers.t$ID)
answers.t$Item <- as.factor(answers.t$Item)

summary(answers.t)

## ---- Stats: Linear models ----

library(lme4)

## Plan: 
## -=-=-
## 2C model: predict accuracy from 2C ratio.
## 3C model: predict accuracy from 2C ratio and 3C ratio. 
## Predict: for mth and prop-most there should not be a difference between models. 
##          for most-sup there 3C model should do better than 2C model.
## Result: Model with 3C: significant effect of 3C only for sup, not mth or prop.
## Most inclusive model: Experiment (most vs. mth); #Colors (2 vs. 3), Condition (2C, bal, unbal, mild), 2C ratio, 3C ratio

#Model suggested by Adam and Edward: Det, ratios, PropTC, SupTC

C3.modelRed <- lmer(Yes ~ Det*C2.Weber + Det*C3.Weber + Det*RedRatio + Det*PropTC + Det*SupTC + (1+Det*C2.Weber+Det*C3.Weber+Det*RedRatio+Det*PropTC+Det*SupTC|ID) + (1|Item), family = binomial (logit), data = answers.t, verbose = TRUE)
summary(C3.modelRed)
#does not converge

C3.model <- lmer(Yes ~ Det*C2.Weber + Det*C3.Weber + Det*PropTC + Det*SupTC + (1+Det*C2.Weber+Det*C3.Weber+Det*PropTC+Det*SupTC|ID) + (1|Item), family = binomial (logit), data = answers.t, verbose = TRUE)
summary(C3.model)

C3.modelNoYellow <- lmer(Yes ~ Det*C2.Weber + Det*PropTC + Det*SupTC + (1+Det*C2.Weber+Det*PropTC+Det*SupTC|ID) + (1|Item), family = binomial (logit), data = answers.t, verbose = TRUE)
summary(C3.modelNoYellow)

anova(C3.model, C3.modelNoYellow)

#C3all.model <- lmer(Yes ~ Exp*C2.Weber + Exp*C3.Weber + Exp*PropTC + Exp*SupTC + (1+Exp*C2.Weber+Exp*C3.Weber+Exp*PropTC+Exp*SupTC|ID) + (1+Exp*C2.Weber+Exp*C3.Weber+Exp*PropTC+Exp*SupTC|Item), family = binomial (logit), data = answers.t, verbose = TRUE)
#summary(C3all.model)
#model with slopes for items does not converge


# USED FOLLOWING REVIEW: models without TC, based only on ratios. 
C3.test <- lmer(Yes ~ Det*C2.Weber + Det*C3.Weber + (1+Det*C2.Weber+Det*C3.Weber|ID) + (1|Item), family = binomial (logit), data = answers.t, verbose = TRUE)
#model with slopes/intercepts for items did not converge
summary(C3.test)
## <-- this is the model we now use in the revised version of the manuscript.


#Most model
#mild.data <- subset(mosts, mosts$Cat == "3C_Mild")
mild.data <- subset(mosts, mosts$Cat == "3C_Mild" & Number <= 5)
mild.data$SupSub <- ifelse(mild.data$PropSub == 1, -0.5, 0.5)
mild.model <- lmer(Yes ~ SupSub*PropTC + (1+SupSub*PropTC|ID) + (1|Item), family = binomial (logit), data = mild.data, verbose = TRUE)
summary(mild.model)
#model fails to converge, results saved but with warning: In mer_finalize(ans) : false convergence (8)

# model repored in footnote in paper: 
mild.model2 <- lmer(Yes ~ SupSub*SupTC + (1+SupSub*SupTC|ID) + (1|Item), family = binomial (logit), data = mild.data, verbose = TRUE)
summary(mild.model2)

# models for revisions -propTC, -C2 ratios, C3 ratios:  THIS IS WHAT WE REPORT IN THE TEXT
mild.model.ratios <- lmer(Yes ~ SupSub*C3.Weber + (1+SupSub*C3.Weber|ID) + (1|Item), family = binomial (logit), data = mild.data, verbose = TRUE)
summary(mild.model.ratios)
#note: model with ratios just gives main effects, not an interaction.

# model added for revision: use propTC to predict data.
mild.model3 <- lmer(Yes ~ SupSub*PropTC + (1+SupSub*PropTC|ID) + (1|Item), family = binomial (logit), data = mild.data, verbose = TRUE)
summary(mild.model3)

mild.model3.ratios <- lmer(Yes ~ SupSub*C2.Weber + (1+SupSub*C2.Weber|ID) + (1|Item), family = binomial (logit), data = mild.data, verbose = TRUE)
summary(mild.model3.ratios)

# similar model for mth: 
mild.data.mth <- subset(mths, mths$Cat == "3C_Mild" & Number <= 5)
mild.data.mth$SupSub <- ifelse(mild.data.mth$PropSub == 1, -0.5, 0.5)
mild.model.mth <- lmer(Yes ~ SupSub*SupTC + (1+SupSub*SupTC|ID) + (1|Item), family = binomial (logit), data = mild.data.mth, verbose = TRUE)
#doesn't converge

mild.model.mth2 <- lmer(Yes ~ SupSub*C3.Weber + (1+SupSub*C3.Weber|ID) + (1|Item), family = binomial (logit), data = mild.data.mth, verbose = TRUE)
summary(mild.model.mth2)

mild.model.mth3 <- lmer(Yes ~ SupSub*SupTC + (1+SupSub|ID) + (1|Item), family = binomial (logit), data = mild.data.mth, verbose = TRUE)
summary(mild.model.mth3)
#more specific models (with SupTC, with or without interaction) do not converge



##---- Older models -- do not use! ----

C3.model.everything <- lmer(Yes ~ Exp + Col + Cats*C2.Weber + Cats*C3.Weber + (1+Col+Cats+Exp+C2.Weber+C3.Weber|ID) + (1+Col+Cats+Exp+C2.Weber+C3.Weber|Item), family = binomial (logit), data = answers.t)   #does not converge at the moment
summary(C3.model.everything)

#C3.model.Col <- lmer(Yes ~ Col + Exp*C2.Weber + Exp*C3.Weber + (1+Col+Exp+C2.Weber+C3.Weber|ID) + (1|Item), family = binomial (link="logit"), data = answers.t) #converges with no slope at the moment

C3.model.noCol <- lmer(Yes ~ Cats + Exp*C2.Weber + Exp*C3.Weber + (1+Cats+Exp+C2.Weber+C3.Weber|ID) + (1|Item), family = binomial (link="logit"), data = answers.t, verbose = TRUE) 
summary(C3.model.noCol)
# Cats not significant,  3C.Weber not significant, everything else significant

C3.model.noCats <- lmer(Yes ~ Exp*C2.Weber + Exp*C3.Weber + (1+Exp+C2.Weber+C3.Weber|ID) + (1|Item), family = binomial (link="logit"), data = answers.t, verbose = TRUE)
summary(C3.model.noCats)
# no main effect but interaction of 3C.Weber and Exp, everything else significant

C3.model.no3C.Weber <- lmer(Yes ~ Exp*C2.Weber + (1+Exp+C2.Weber|ID) + (1|Item), family = binomial (link="logit"), data = answers.t, verbose = TRUE)
summary(C3.model.no3C.Weber)
# everything significant

anova(C3.model.noCats, C3.model.no3C.Weber)
#lost information, removing 3C.Weber not justified. 




# simple most model
C3.model <- lmer(Yes ~ C2.Weber + C3.Weber + (1+C2.Weber+C3.Weber|ID) + (1|Item), family = binomial (link="logit"), data = mosts)
C2.model <- lmer(Yes ~ C2.Weber + (1+C2.Weber|ID) + (1|Item), family = binomial (link="logit"), data = mosts)
anova(C3.model, C2.model)

# simple mth model
C3.model <- lmer(Yes ~ C2.Weber + C3.Weber + (1+C2.Weber+C3.Weber|ID) + (1|Item), family = binomial (link = "logit"), data = mths)
C2.model <- lmer(Yes ~ C2.Weber + (1+C2.Weber|ID) + (1|Item), family = binomial (link="logit"), data = mths)
anova(C3.model, C2.model)


##notes from meeting with Adam: 
#C3.Weber:C3 (consider c3 only when there are 3 colors)

#Percent ~ C2.Weber + C3.Weber + condition*C2.Weber + condition*C3.Weber 

#Helmert coding: compare: 2 vs. all 3, then unbal vs. others, then mild vs. bal
#probit
#arcsine transform
