var shuffleSequence = seq("intro", "consent", "demo", sepWith("sep", seq("practice", rshuffle("target","filler"))), "contact", "end");
var practiceItemTypes = ["practice"];

var defaults = [
    "Separator", {
        transfer: 1000,
        normalMessage: "Please wait for the next sentence.",
		ignoreFailure: true,
    },
    "NewDashedSentence", {
        mode: "self-paced reading"
    },
    "Question", {
        hasCorrect: true
    },
    "Message", {
        hideProgressBar: true
    },
    "Form", {
        hideProgressBar: true,
        continueOnReturn: true,
        saveReactionTime: true
    }
];

var items = [

    // New in Ibex 0.3-beta-9. You can now add a '__SendResults__' controller in your shuffle
    // sequence to send results before the experiment has finished. This is NOT intended to allow
    // for incremental sending of results -- you should send results exactly once per experiment.
    // However, it does permit additional messages to be displayed to participants once the
    // experiment itself is over. If you are manually inserting a '__SendResults__' controller into
    // the shuffle sequence, you must set the 'manualSendResults' configuration variable to 'true', since
    // otherwise, results are automatically sent at the end of the experiment.
    //
    //["sr", "__SendResults__", { }],

    ["sep", "Separator", { }],

    // New in Ibex 0.3-beta19. You can now determine the point in the experiment at which the counter
    // for latin square designs will be updated. (Previously, this was always updated upon completion
    // of the experiment.) To do this, insert the special '__SetCounter__' controller at the desired
    // point in your running order. If given no options, the counter is incremented by one. If given
    // an 'inc' option, the counter is incremented by the specified amount. If given a 'set' option,
    // the counter is set to the given number. (E.g., { set: 100 }, { inc: -1 })
    //
    //["setcounter", "__SetCounter__", { }],

    // NOTE: You could also use the 'Message' controller for the experiment intro (this provides a simple
    // consent checkbox).

    ["intro", "Form", {
        html: { include: "hadas_intro.html" },
        validators: {
		}
    } ],
	
	["consent", "Form", {
        html: { include: "hadas_consent.html" },
        validators: {
		}
    } ],

	["demo", "Form", {
        html: { include: "hadas_demo.html" },
        validators: {
            WorkerId: function (s) { if (s.match(/^\w+$/)) return true; else return "Bad value for \u2018WorkerId\u2019"; },
			age: function (s) { if (s.match(/^\d+$/)) return true; else return "Bad value for \u2018age\u2019"; }
		}
    } ],
	
	
	["contact", "Form", {
        html: { include: "hadas_contact.html" },
        validators: {
        }
    } ],
	
	
	["end", "Form", {
        html: { include: "hadas_end.html" },
        validators: {
    	}
    } ],
	
["practice", "NewDashedSentence", {s: "This is a practice sentence to get you used to reading sentences like this."}],
["practice", "NewDashedSentence", {s: "This is another practice sentence with a practice question following it."},
                 "Question", {hasCorrect: false, randomOrder: false,
                              q: "Could you read this sentence at a natural pace?", as: ["Yes","No"]}],
["practice", "NewDashedSentence", {s: "This is the last practice sentence before the experiment begins."}],
	
// 'which-did'
[["target",3], "NewDashedSentence",
 {s: "The conductor asked which soloist was willing to perform which\r concerto that the brilliant protégé did and restructured the rehearsal accordingly."},
 "Question", { q: "Has the protégé already performed any concertos?", as: ['Yes','No'] }],

// 'every-did'
[["target",3], "NewDashedSentence",
 {s: "The conductor asked which soloist was willing to perform every\r concerto that the brilliant protégé did and restructured the rehearsal accordingly."},
 "Question", { q: "Has the protégé already performed any concertos?", as: ['Yes','No'] }],

// 'which-was'
[["target",3], "NewDashedSentence",
 {s: "The conductor asked which soloist was willing to perform which\r concerto that the brilliant protégé was and restructured the rehearsal accordingly."},
 "Question", { q: "Has the protégé already performed any concertos?", as: ['No','Yes'] }],

// 'every-was'
[["target",3], "NewDashedSentence",
 {s: "The conductor asked which soloist was willing to perform every\r concerto that the brilliant protégé was and restructured the rehearsal accordingly."},
 "Question", { q: "Has the protégé already performed any concertos?", as: ['No','Yes'] }],

// 'which-did'
[["target",5], "NewDashedSentence",
 {s: "The prosecutor asked which defendant was told to discredit which\r lieutenant that the drill sergeant did but only one defendant revealed anything."},
 "Question", { q: "Was the drill sergeant told to discredit anyone?", as: ['No','Yes'] }],

// 'every-did'
[["target",5], "NewDashedSentence",
 {s: "The prosecutor asked which defendant was told to discredit every\r lieutenant that the drill sergeant did but only one defendant revealed anything."},
 "Question", { q: "Was the drill sergeant told to discredit anyone?", as: ['No','Yes'] }],

// 'which-was'
[["target",5], "NewDashedSentence",
 {s: "The prosecutor asked which defendant was told to discredit which\r lieutenant that the drill sergeant was but only one defendant revealed anything."},
 "Question", { q: "Was the drill sergeant told to discredit anyone?", as: ['Yes','No'] }],

// 'every-was'
[["target",5], "NewDashedSentence",
 {s: "The prosecutor asked which defendant was told to discredit every\r lieutenant that the drill sergeant was but only one defendant revealed anything."},
 "Question", { q: "Was the drill sergeant told to discredit anyone?", as: ['Yes','No'] }],

// 'which-did'
[["target",8], "NewDashedSentence",
 {s: "The analyst predicted which investor was prepared to buy which\r stock that the hedge fund did and sent a memo to the bank management."},
 "Question", { q: "Has the hedge fund already abought any stock?", as: ['Yes','No'] }],

// 'every-did'
[["target",8], "NewDashedSentence",
 {s: "The analyst predicted which investor was prepared to buy every\r stock that the hedge fund did and sent a memo to the bank management."},
 "Question", { q: "Has the hedge fund already abought any stock?", as: ['Yes','No'] }],

// 'which-was'
[["target",8], "NewDashedSentence",
 {s: "The analyst predicted which investor was prepared to buy which\r stock that the hedge fund was and sent a memo to the bank management."},
 "Question", { q: "Has the hedge fund already abought any stock?", as: ['No','Yes'] }],

// 'every-was'
[["target",8], "NewDashedSentence",
 {s: "The analyst predicted which investor was prepared to buy every\r stock that the hedge fund was and sent a memo to the bank management."},
 "Question", { q: "Has the hedge fund already abought any stock?", as: ['No','Yes'] }],

// 'which-did'
[["target",13], "NewDashedSentence",
 {s: "The librarian learned which teacher was planning to borrow which\r book that the visiting scholar did and accordingly shortened the loan periods."},
 "Question", { q: "Was the visiting scholar planning to borrow any more books in the future?", as: ['No','Yes'] }],

// 'every-did'
[["target",13], "NewDashedSentence",
 {s: "The librarian learned which teacher was planning to borrow every\r book that the visiting scholar did and accordingly shortened the loan periods."},
 "Question", { q: "Was the visiting scholar planning to borrow any more books in the future?", as: ['No','Yes'] }],

// 'which-was'
[["target",13], "NewDashedSentence",
 {s: "The librarian learned which teacher was planning to borrow which\r book that the visiting scholar was and accordingly shortened the loan periods."},
 "Question", { q: "Was the visiting scholar planning to borrow any more books in the future?", as: ['Yes','No'] }],

// 'every-was'
[["target",13], "NewDashedSentence",
 {s: "The librarian learned which teacher was planning to borrow every\r book that the visiting scholar was and accordingly shortened the loan periods."},
 "Question", { q: "Was the visiting scholar planning to borrow any more books in the future?", as: ['Yes','No'] }],

// 'which-did'
[["target",17], "NewDashedSentence",
 {s: "The focus-group explained which discount was likely to attract which\r demographic that the Spring sale did and then several TV ads were launched."},
 "Question", { q: "Has the spring sale already happened?", as: ['Yes','No'] }],

// 'every-did'
[["target",17], "NewDashedSentence",
 {s: "The focus-group explained which discount was likely to attract every\r demographic that the Spring sale did and then several TV ads were launched."},
 "Question", { q: "Has the spring sale already happened?", as: ['Yes','No'] }],

// 'which-was'
[["target",17], "NewDashedSentence",
 {s: "The focus-group explained which discount was likely to attract which\r demographic that the Spring sale was and then several TV ads were launched."},
 "Question", { q: "Has the spring sale already happened?", as: ['No','Yes'] }],

// 'every-was'
[["target",17], "NewDashedSentence",
 {s: "The focus-group explained which discount was likely to attract every\r demographic that the Spring sale was and then several TV ads were launched."},
 "Question", { q: "Has the spring sale already happened?", as: ['No','Yes'] }],

// 'which-did'
[["target",18], "NewDashedSentence",
 {s: "The secretary found_out which professor was going to question which\r student that the disciplinary committee did and then scheduled the hearings."},
 "Question", { q: "Was the disciplinary committee planning to question the students in the future?", as: ['No','Yes'] }],

// 'every-did'
[["target",18], "NewDashedSentence",
 {s: "The secretary found_out which professor was going to question every\r student that the disciplinary committee did and then scheduled the hearings."},
 "Question", { q: "Was the disciplinary committee planning to question the students in the future?", as: ['No','Yes'] }],

// 'which-was'
[["target",18], "NewDashedSentence",
 {s: "The secretary found_out which professor was going to question which\r student that the disciplinary committee was and then scheduled the hearings."},
 "Question", { q: "Was the disciplinary committee planning to question the students in the future?", as: ['Yes','No'] }],

// 'every-was'
[["target",18], "NewDashedSentence",
 {s: "The secretary found_out which professor was going to question every\r student that the disciplinary committee was and then scheduled the hearings."},
 "Question", { q: "Was the disciplinary committee planning to question the students in the future?", as: ['Yes','No'] }],

// 'which-did'
[["target",19], "NewDashedSentence",
 {s: "The general forgot which unit was scheduled to attack which\r target that the nuclear submarine did and sent a messenger to headquarters."},
 "Question", { q: "Was the nuclear submarine going to attack the targets at some point in the future?", as: ['No','Yes'] }],

// 'every-did'
[["target",19], "NewDashedSentence",
 {s: "The general forgot which unit was scheduled to attack every\r target that the nuclear submarine did and sent a messenger to headquarters."},
 "Question", { q: "Was the nuclear submarine going to attack the targets at some point in the future?", as: ['No','Yes'] }],

// 'which-was'
[["target",19], "NewDashedSentence",
 {s: "The general forgot which unit was scheduled to attack which\r target that the nuclear submarine was and sent a messenger to headquarters."},
 "Question", { q: "Was the nuclear submarine going to attack the targets at some point in the future?", as: ['Yes','No'] }],

// 'every-was'
[["target",19], "NewDashedSentence",
 {s: "The general forgot which unit was scheduled to attack every\r target that the nuclear submarine was and sent a messenger to headquarters."},
 "Question", { q: "Was the nuclear submarine going to attack the targets at some point in the future?", as: ['Yes','No'] }],

// 'which-did'
[["target",21], "NewDashedSentence",
 {s: "The admiral specified which ship was ordered to attack which\r position that the navy jet did and then the joint army-navy exercise began."},
 "Question", { q: "Was the the navy jet ordered to attack the positions in the future?", as: ['No','Yes'] }],

// 'every-did'
[["target",21], "NewDashedSentence",
 {s: "The admiral specified which ship was ordered to attack every\r position that the navy jet did and then the joint army-navy exercise began."},
 "Question", { q: "Was the the navy jet ordered to attack the positions in the future?", as: ['No','Yes'] }],

// 'which-was'
[["target",21], "NewDashedSentence",
 {s: "The admiral specified which ship was ordered to attack which\r position that the navy jet was and then the joint army-navy exercise began."},
 "Question", { q: "Was the the navy jet ordered to attack the positions in the future?", as: ['Yes','No'] }],

// 'every-was'
[["target",21], "NewDashedSentence",
 {s: "The admiral specified which ship was ordered to attack every\r position that the navy jet was and then the joint army-navy exercise began."},
 "Question", { q: "Was the the navy jet ordered to attack the positions in the future?", as: ['Yes','No'] }],

// 'which-did'
[["target",23], "NewDashedSentence",
 {s: "The colonel explained which officer was ordered to interrogate which\r prisoner that the CIA agent did and then described what methods not to use."},
 "Question", { q: "Has the CIA agent already interrogated the prisoners?", as: ['Yes','No'] }],

// 'every-did'
[["target",23], "NewDashedSentence",
 {s: "The colonel explained which officer was ordered to interrogate every\r prisoner that the CIA agent did and then described what methods not to use."},
 "Question", { q: "Has the CIA agent already interrogated the prisoners?", as: ['Yes','No'] }],

// 'which-was'
[["target",23], "NewDashedSentence",
 {s: "The colonel explained which officer was ordered to interrogate which\r prisoner that the CIA agent was and then described what methods not to use."},
 "Question", { q: "Has the CIA agent already interrogated the prisoners?", as: ['No','Yes'] }],

// 'every-was'
[["target",23], "NewDashedSentence",
 {s: "The colonel explained which officer was ordered to interrogate every\r prisoner that the CIA agent was and then described what methods not to use."},
 "Question", { q: "Has the CIA agent already interrogated the prisoners?", as: ['No','Yes'] }],

// 'which-did'
[["target",25], "NewDashedSentence",
 {s: "The detective discovered which mobster was planning to blackmail which\r business that the street gang did and immediately informed his superiors."},
 "Question", { q: "Have any businesses been blackmailed by the street gang in the past?", as: ['Yes','No'] }],

// 'every-did'
[["target",25], "NewDashedSentence",
 {s: "The detective discovered which mobster was planning to blackmail every\r business that the street gang did and immediately informed his superiors."},
 "Question", { q: "Have any businesses been blackmailed by the street gang in the past?", as: ['Yes','No'] }],

// 'which-was'
[["target",25], "NewDashedSentence",
 {s: "The detective discovered which mobster was planning to blackmail which\r business that the street gang was and immediately informed his superiors."},
 "Question", { q: "Have any businesses been blackmailed by the street gang in the past?", as: ['No','Yes'] }],

// 'every-was'
[["target",25], "NewDashedSentence",
 {s: "The detective discovered which mobster was planning to blackmail every\r business that the street gang was and immediately informed his superiors."},
 "Question", { q: "Have any businesses been blackmailed by the street gang in the past?", as: ['No','Yes'] }],

// 'which-did'
[["target",26], "NewDashedSentence",
 {s: "The sheriff knew which marshal was excited to chase which\r fugitive that the state police did but doubted that the fugitives would be caught."},
 "Question", { q: "Was the state police getting excited about chasing the fugitives?", as: ['No','Yes'] }],

// 'every-did'
[["target",26], "NewDashedSentence",
 {s: "The sheriff knew which marshal was excited to chase every\r fugitive that the state police did but doubted that the fugitives would be caught."},
 "Question", { q: "Was the state police getting excited about chasing the fugitives?", as: ['No','Yes'] }],

// 'which-was'
[["target",26], "NewDashedSentence",
 {s: "The sheriff knew which marshal was excited to chase which\r fugitive that the state police was but doubted that the fugitives would be caught."},
 "Question", { q: "Was the state police getting excited about chasing the fugitives?", as: ['Yes','No'] }],

// 'every-was'
[["target",26], "NewDashedSentence",
 {s: "The sheriff knew which marshal was excited to chase every\r fugitive that the state police was but doubted that the fugitives would be caught."},
 "Question", { q: "Was the state police getting excited about chasing the fugitives?", as: ['Yes','No'] }],

// 'which-did'
[["target",2], "NewDashedSentence",
 {s: "The principal determined which instructor was able to teach which\r class that the substitute teacher did and accordingly finalized the schedule."},
 "Question", { q: "Has the substitute teacher taught any classes in the past?", as: ['Yes','No'] }],

// 'every-did'
[["target",2], "NewDashedSentence",
 {s: "The principal determined which instructor was able to teach every\r class that the substitute teacher did and accordingly finalized the schedule."},
 "Question", { q: "Has the substitute teacher taught any classes in the past?", as: ['Yes','No'] }],

// 'which-was'
[["target",2], "NewDashedSentence",
 {s: "The principal determined which instructor was able to teach which\r class that the substitute teacher was and accordingly finalized the schedule."},
 "Question", { q: "Has the substitute teacher taught any classes in the past?", as: ['Yes','No'] }],

// 'every-was'
[["target",2], "NewDashedSentence",
 {s: "The principal determined which instructor was able to teach every\r class that the substitute teacher was and accordingly finalized the schedule."},
 "Question", { q: "Has the substitute teacher taught any classes in the past?", as: ['Yes','No'] }],

// 'which-did'
[["target",10], "NewDashedSentence",
 {s: "The carpenter asked which apprentice was qualified to use which\r technique that the licensed electrician did and then assigned personnel to projects."},
 "Question", { q: "Was the electrician qualified to use any techniques?", as: ['Yes','No'] }],

// 'every-did'
[["target",10], "NewDashedSentence",
 {s: "The carpenter asked which apprentice was qualified to use every\r technique that the licensed electrician did and then assigned personnel to projects."},
 "Question", { q: "Was the electrician qualified to use any techniques?", as: ['Yes','No'] }],

// 'which-was'
[["target",10], "NewDashedSentence",
 {s: "The carpenter asked which apprentice was qualified to use which\r technique that the licensed electrician was and then assigned personnel to projects."},
 "Question", { q: "Was the electrician qualified to use any techniques?", as: ['Yes','No'] }],

// 'every-was'
[["target",10], "NewDashedSentence",
 {s: "The carpenter asked which apprentice was qualified to use every\r technique that the licensed electrician was and then assigned personnel to projects."},
 "Question", { q: "Was the electrician qualified to use any techniques?", as: ['Yes','No'] }],

// 'which-did'
[["target",11], "NewDashedSentence",
 {s: "The choreographer determined which dancer was ready to perform which\r dance_routine that the Russian ballerina did and then started the dance recital."},
 "Question", { q: "Could the Russian ballerina perform any dance routines?", as: ['Yes','No'] }],

// 'every-did'
[["target",11], "NewDashedSentence",
 {s: "The choreographer determined which dancer was ready to perform every\r dance_routine that the Russian ballerina did and then started the dance recital."},
 "Question", { q: "Could the Russian ballerina perform any dance routines?", as: ['Yes','No'] }],

// 'which-was'
[["target",11], "NewDashedSentence",
 {s: "The choreographer determined which dancer was ready to perform which\r dance_routine that the Russian ballerina was and then started the dance recital."},
 "Question", { q: "Could the Russian ballerina perform any dance routines?", as: ['Yes','No'] }],

// 'every-was'
[["target",11], "NewDashedSentence",
 {s: "The choreographer determined which dancer was ready to perform every\r dance_routine that the Russian ballerina was and then started the dance recital."},
 "Question", { q: "Could the Russian ballerina perform any dance routines?", as: ['Yes','No'] }],

// 'which-did'
[["target",14], "NewDashedSentence",
 {s: "The attorney clarified which witness was supposed to support which\r alibi that the undercover informant did and then gave his closing argument."},
 "Question", { q: "Was the undercover informant expected to support any alibis?", as: ['Yes','No'] }],

// 'every-did'
[["target",14], "NewDashedSentence",
 {s: "The attorney clarified which witness was supposed to support every\r alibi that the undercover informant did and then gave his closing argument."},
 "Question", { q: "Was the undercover informant expected to support any alibis?", as: ['Yes','No'] }],

// 'which-was'
[["target",14], "NewDashedSentence",
 {s: "The attorney clarified which witness was supposed to support which\r alibi that the undercover informant was and then gave his closing argument."},
 "Question", { q: "Was the undercover informant expected to support any alibis?", as: ['Yes','No'] }],

// 'every-was'
[["target",14], "NewDashedSentence",
 {s: "The attorney clarified which witness was supposed to support every\r alibi that the undercover informant was and then gave his closing argument."},
 "Question", { q: "Was the undercover informant expected to support any alibis?", as: ['Yes','No'] }],

// 'which-did'
[["target",16], "NewDashedSentence",
 {s: "The programmer realized which update was certain to solve which\r problem that the old software did but surprisingly decided not to tell anyone."},
 "Question", { q: "Could the old software solve the problems that the programmer found?", as: ['Yes','No'] }],

// 'every-did'
[["target",16], "NewDashedSentence",
 {s: "The programmer realized which update was certain to solve every\r problem that the old software did but surprisingly decided not to tell anyone."},
 "Question", { q: "Could the old software solve the problems that the programmer found?", as: ['Yes','No'] }],

// 'which-was'
[["target",16], "NewDashedSentence",
 {s: "The programmer realized which update was certain to solve which\r problem that the old software was but surprisingly decided not to tell anyone."},
 "Question", { q: "Could the old software solve the problems that the programmer found?", as: ['Yes','No'] }],

// 'every-was'
[["target",16], "NewDashedSentence",
 {s: "The programmer realized which update was certain to solve every\r problem that the old software was but surprisingly decided not to tell anyone."},
 "Question", { q: "Could the old software solve the problems that the programmer found?", as: ['Yes','No'] }],

// 'which-did'
[["target",20], "NewDashedSentence",
 {s: "The biologist discovered which reptile was likely to have which\r gene that the Tyrannosaurus Rex did and proposed additional tests."},
 "Question", { q: "Was it likely that the Tyrannosaurus Rex shared some genes with some reptiles?", as: ['Yes','No'] }],

// 'every-did'
[["target",20], "NewDashedSentence",
 {s: "The biologist discovered which reptile was likely to have every\r gene that the Tyrannosaurus Rex did and proposed additional tests."},
 "Question", { q: "Was it likely that the Tyrannosaurus Rex shared some genes with some reptiles?", as: ['Yes','No'] }],

// 'which-was'
[["target",20], "NewDashedSentence",
 {s: "The biologist discovered which reptile was likely to have which\r gene that the Tyrannosaurus Rex was and proposed additional tests."},
 "Question", { q: "Was it likely that the Tyrannosaurus Rex shared some genes with some reptiles?", as: ['Yes','No'] }],

// 'every-was'
[["target",20], "NewDashedSentence",
 {s: "The biologist discovered which reptile was likely to have every\r gene that the Tyrannosaurus Rex was and proposed additional tests."},
 "Question", { q: "Was it likely that the Tyrannosaurus Rex shared some genes with some reptiles?", as: ['Yes','No'] }],

// 'which-did'
[["target",22], "NewDashedSentence",
 {s: "The engineer explained which apprentice was asked to service which\r engine that the sick crew_member did and then called the train company."},
 "Question", { q: "Was the sick crew member ordered not to service the engines?", as: ['No','Yes'] }],

// 'every-did'
[["target",22], "NewDashedSentence",
 {s: "The engineer explained which apprentice was asked to service every\r engine that the sick crew_member did and then called the train company."},
 "Question", { q: "Was the sick crew member ordered not to service the engines?", as: ['No','Yes'] }],

// 'which-was'
[["target",22], "NewDashedSentence",
 {s: "The engineer explained which apprentice was asked to service which\r engine that the sick crew_member was and then called the train company."},
 "Question", { q: "Was the sick crew member ordered not to service the engines?", as: ['No','Yes'] }],

// 'every-was'
[["target",22], "NewDashedSentence",
 {s: "The engineer explained which apprentice was asked to service every\r engine that the sick crew_member was and then called the train company."},
 "Question", { q: "Was the sick crew member ordered not to service the engines?", as: ['No','Yes'] }],

// 'which-did'
[["target",27], "NewDashedSentence",
 {s: "The scientist discovered which antibody was likely to attack which\r virus that the standard medication did but needed funding to complete her study."},
 "Question", { q: "Was the medication good at attacking viruses?", as: ['Yes','No'] }],

// 'every-did'
[["target",27], "NewDashedSentence",
 {s: "The scientist discovered which antibody was likely to attack every\r virus that the standard medication did but needed funding to complete her study."},
 "Question", { q: "Was the medication good at attacking viruses?", as: ['Yes','No'] }],

// 'which-was'
[["target",27], "NewDashedSentence",
 {s: "The scientist discovered which antibody was likely to attack which\r virus that the standard medication was but needed funding to complete her study."},
 "Question", { q: "Was the medication good at attacking viruses?", as: ['Yes','No'] }],

// 'every-was'
[["target",27], "NewDashedSentence",
 {s: "The scientist discovered which antibody was likely to attack every\r virus that the standard medication was but needed funding to complete her study."},
 "Question", { q: "Was the medication good at attacking viruses?", as: ['Yes','No'] }],

// 'which-did'
[["target",1], "NewDashedSentence",
 {s: "The orderly learned which doctor was planning to monitor which\r patient that the duty nurse did and immediately updated the charts."},
 "Question", { q: "Did the orderly find out information about the doctors?", as: ['Yes','No'] }],

// 'every-did'
[["target",1], "NewDashedSentence",
 {s: "The orderly learned which doctor was planning to monitor every\r patient that the duty nurse did and immediately updated the charts."},
 "Question", { q: "Did the orderly find out information about the doctors?", as: ['Yes','No'] }],

// 'which-was'
[["target",1], "NewDashedSentence",
 {s: "The orderly learned which doctor was planning to monitor which\r patient that the duty nurse was and immediately updated the charts."},
 "Question", { q: "Did the orderly find out information about the doctors?", as: ['Yes','No'] }],

// 'every-was'
[["target",1], "NewDashedSentence",
 {s: "The orderly learned which doctor was planning to monitor every\r patient that the duty nurse was and immediately updated the charts."},
 "Question", { q: "Did the orderly find out information about the doctors?", as: ['Yes','No'] }],

// 'which-did'
[["target",4], "NewDashedSentence",
 {s: "The coordinator learned which tutor was scheduled to teach which\r topic that the Physics professor did and assigned them to classrooms."},
 "Question", { q: "Was the coordinator scheduled to teach a class with the Physics professor?", as: ['No','Yes'] }],

// 'every-did'
[["target",4], "NewDashedSentence",
 {s: "The coordinator learned which tutor was scheduled to teach every\r topic that the Physics professor did and assigned them to classrooms."},
 "Question", { q: "Was the coordinator scheduled to teach a class with the Physics professor?", as: ['No','Yes'] }],

// 'which-was'
[["target",4], "NewDashedSentence",
 {s: "The coordinator learned which tutor was scheduled to teach which\r topic that the Physics professor was and assigned them to classrooms."},
 "Question", { q: "Was the coordinator scheduled to teach a class with the Physics professor?", as: ['No','Yes'] }],

// 'every-was'
[["target",4], "NewDashedSentence",
 {s: "The coordinator learned which tutor was scheduled to teach every\r topic that the Physics professor was and assigned them to classrooms."},
 "Question", { q: "Was the coordinator scheduled to teach a class with the Physics professor?", as: ['No','Yes'] }],

// 'which-did'
[["target",6], "NewDashedSentence",
 {s: "The teacher found_out which student was eager to attend which\r trip that the class president did and organized the field trips accordingly."},
 "Question", { q: "Were the students organizing the field trip themselves?", as: ['No','Yes'] }],

// 'every-did'
[["target",6], "NewDashedSentence",
 {s: "The teacher found_out which student was eager to attend every\r trip that the class president did and organized the field trips accordingly."},
 "Question", { q: "Were the students organizing the field trip themselves?", as: ['No','Yes'] }],

// 'which-was'
[["target",6], "NewDashedSentence",
 {s: "The teacher found_out which student was eager to attend which\r trip that the class president was and organized the field trips accordingly."},
 "Question", { q: "Were the students organizing the field trip themselves?", as: ['No','Yes'] }],

// 'every-was'
[["target",6], "NewDashedSentence",
 {s: "The teacher found_out which student was eager to attend every\r trip that the class president was and organized the field trips accordingly."},
 "Question", { q: "Were the students organizing the field trip themselves?", as: ['No','Yes'] }],

// 'which-did'
[["target",7], "NewDashedSentence",
 {s: "The detective found_out which guard was willing to hassle which\r prisoner that the sadistic warden did and included the names in his report."},
 "Question", { q: "Did the detective investigate the prison guards?", as: ['Yes','No'] }],

// 'every-did'
[["target",7], "NewDashedSentence",
 {s: "The detective found_out which guard was willing to hassle every\r prisoner that the sadistic warden did and included the names in his report."},
 "Question", { q: "Did the detective investigate the prison guards?", as: ['Yes','No'] }],

// 'which-was'
[["target",7], "NewDashedSentence",
 {s: "The detective found_out which guard was willing to hassle which\r prisoner that the sadistic warden was and included the names in his report."},
 "Question", { q: "Did the detective investigate the prison guards?", as: ['Yes','No'] }],

// 'every-was'
[["target",7], "NewDashedSentence",
 {s: "The detective found_out which guard was willing to hassle every\r prisoner that the sadistic warden was and included the names in his report."},
 "Question", { q: "Did the detective investigate the prison guards?", as: ['Yes','No'] }],

// 'which-did'
[["target",9], "NewDashedSentence",
 {s: "The realtor asked which trainee was able to show which\r property that the experienced secretary did but nobody was available that weekend."},
 "Question", { q: "Were the trainees able to show properties over the weekend?", as: ['No','Yes'] }],

// 'every-did'
[["target",9], "NewDashedSentence",
 {s: "The realtor asked which trainee was able to show every\r property that the experienced secretary did but nobody was available that weekend."},
 "Question", { q: "Were the trainees able to show properties over the weekend?", as: ['No','Yes'] }],

// 'which-was'
[["target",9], "NewDashedSentence",
 {s: "The realtor asked which trainee was able to show which\r property that the experienced secretary was but nobody was available that weekend."},
 "Question", { q: "Were the trainees able to show properties over the weekend?", as: ['No','Yes'] }],

// 'every-was'
[["target",9], "NewDashedSentence",
 {s: "The realtor asked which trainee was able to show every\r property that the experienced secretary was but nobody was available that weekend."},
 "Question", { q: "Were the trainees able to show properties over the weekend?", as: ['No','Yes'] }],

// 'which-did'
[["target",12], "NewDashedSentence",
 {s: "The organizers found_out which announcer was willing to cover which\r game that the notorious commentator did and finalized the broadcasting schedule."},
 "Question", { q: "Did the commentator request a change to the broadcasting schedule?", as: ['No','Yes'] }],

// 'every-did'
[["target",12], "NewDashedSentence",
 {s: "The organizers found_out which announcer was willing to cover every\r game that the notorious commentator did and finalized the broadcasting schedule."},
 "Question", { q: "Did the commentator request a change to the broadcasting schedule?", as: ['No','Yes'] }],

// 'which-was'
[["target",12], "NewDashedSentence",
 {s: "The organizers found_out which announcer was willing to cover which\r game that the notorious commentator was and finalized the broadcasting schedule."},
 "Question", { q: "Did the commentator request a change to the broadcasting schedule?", as: ['No','Yes'] }],

// 'every-was'
[["target",12], "NewDashedSentence",
 {s: "The organizers found_out which announcer was willing to cover every\r game that the notorious commentator was and finalized the broadcasting schedule."},
 "Question", { q: "Did the commentator request a change to the broadcasting schedule?", as: ['No','Yes'] }],

// 'which-did'
[["target",15], "NewDashedSentence",
 {s: "The dispatcher clarified which apprentice was scheduled to accompany which\r crew that the experienced engineer did and sent the crews on their way."},
 "Question", { q: "Was the dispatcher sick?", as: ['No','Yes'] }],

// 'every-did'
[["target",15], "NewDashedSentence",
 {s: "The dispatcher clarified which apprentice was scheduled to accompany every\r crew that the experienced engineer did and sent the crews on their way."},
 "Question", { q: "Was the dispatcher sick?", as: ['No','Yes'] }],

// 'which-was'
[["target",15], "NewDashedSentence",
 {s: "The dispatcher clarified which apprentice was scheduled to accompany which\r crew that the experienced engineer was and sent the crews on their way."},
 "Question", { q: "Was the dispatcher sick?", as: ['No','Yes'] }],

// 'every-was'
[["target",15], "NewDashedSentence",
 {s: "The dispatcher clarified which apprentice was scheduled to accompany every\r crew that the experienced engineer was and sent the crews on their way."},
 "Question", { q: "Was the dispatcher sick?", as: ['No','Yes'] }],

// 'which-did'
[["target",24], "NewDashedSentence",
 {s: "The log showed which detective was sent to arrest which\r suspect that the FBI agent did and also where the arrest took place."},
 "Question", { q: "Did the log contain details about where the FBI agent was?", as: ['No','Yes'] }],

// 'every-did'
[["target",24], "NewDashedSentence",
 {s: "The log showed which detective was sent to arrest every\r suspect that the FBI agent did and also where the arrest took place."},
 "Question", { q: "Did the log contain details about where the FBI agent was?", as: ['No','Yes'] }],

// 'which-was'
[["target",24], "NewDashedSentence",
 {s: "The log showed which detective was sent to arrest which\r suspect that the FBI agent was and also where the arrest took place."},
 "Question", { q: "Did the log contain details about where the FBI agent was?", as: ['No','Yes'] }],

// 'every-was'
[["target",24], "NewDashedSentence",
 {s: "The log showed which detective was sent to arrest every\r suspect that the FBI agent was and also where the arrest took place."},
 "Question", { q: "Did the log contain details about where the FBI agent was?", as: ['No','Yes'] }],

// 'which-did'
[["target",28], "NewDashedSentence",
 {s: "The warden guessed which inmate was trying to smuggle which\r contraband that the corrupt guard did and therefore intensified the security screens."},
 "Question", { q: "Did anyone suspect the warden of smuggling?", as: ['No','Yes'] }],

// 'every-did'
[["target",28], "NewDashedSentence",
 {s: "The warden guessed which inmate was trying to smuggle every\r contraband that the corrupt guard did and therefore intensified the security screens."},
 "Question", { q: "Did anyone suspect the warden of smuggling?", as: ['No','Yes'] }],

// 'which-was'
[["target",28], "NewDashedSentence",
 {s: "The warden guessed which inmate was trying to smuggle which\r contraband that the corrupt guard was and therefore intensified the security screens."},
 "Question", { q: "Did anyone suspect the warden of smuggling?", as: ['No','Yes'] }],

// 'every-was'
[["target",28], "NewDashedSentence",
 {s: "The warden guessed which inmate was trying to smuggle every\r contraband that the corrupt guard was and therefore intensified the security screens."},
 "Question", { q: "Did anyone suspect the warden of smuggling?", as: ['No','Yes'] }],



// '-'
[["filler",28+1], "NewDashedSentence", {s: "The scientist knew which assistant was asked to work_on which\r project that the famous professor designed and ordered materials for the project."},
 "Question", { q: "Did the famous professor order materials for his lab himself?", as: ['No','Yes'] }],

// '-'
[["filler",28+2], "NewDashedSentence", {s: "The general asked which platoon was assigned to train_with which\r weapon that the enemy soldiers feared and decided to shorten everyone's vacation by two days."},
 "Question", { q: "Did the enemy soldiers fear any weapons?", as: ['Yes','No'] }],

// '-'
[["filler",28+3], "NewDashedSentence", {s: "The casting_director wondered which drummer was able to play_with which\r band that the bass guitarist liked and decided to hold open auditions for the positions."},
 "Question", { q: "Was any drummer compared to the bass guitarist?", as: ['No','Yes'] }],

// '-'
[["filler",28+4], "NewDashedSentence", {s: "The chef explained which ingredient was certain to improve which\r dish that the expensive truffles ruined and sent his apprentice to the specialty store."},
 "Question", { q: "Did the chef add ingredients to his dishes?", as: ['Yes','No'] }],

// '-'
[["filler",28+5], "NewDashedSentence", {s: "The intern predicted which senior_partner was determined to accept which\r case that the district attorney prosecuted and started to prepare the affidavits."},
 "Question", { q: "Were the affidavits prepared by the district attorney?", as: ['No','Yes'] }],

// '-'
[["filler",28+6], "NewDashedSentence", {s: "The spokesperson announced which astronaut was scheduled to fly_in which\r mission that the Russian scientists planned and also what experiments would be conducted during the missions."},
 "Question", { q: "Were there space missions planned by the Russians?", as: ['Yes','No'] }],

// '-'
[["filler",28+7], "NewDashedSentence", {s: "The magician decided which assistant was qualified to participate in which\r illusion that the daring acrobat proposed and showed us how his optical illusions worked."},
 "Question", { q: "Did the acrobat participate in any illusions?", as: ['No','Yes'] }],

// '-'
[["filler",28+8], "NewDashedSentence", {s: "The agent learned which record_company was determined to sign which\r artist that the film studio had_fired and called his clients to prepare them for the auditions."},
 "Question", { q: "Did the film studio fire any artist?", as: ['Yes','No'] }],

// '-'
[["filler",28+9], "NewDashedSentence", {s: "The coach decided which player was going to learn which\r play that the opposing team practiced and subsequently extended practice for another hour."},
 "Question", { q: "Did the team cut its practice short?", as: ['No','Yes'] }],

// '-'
[["filler",28+10], "NewDashedSentence", {s: "The chief_of_staff learned which secretary was willing to host which\r minister from a European country and accordingly the dinner plans were finalized."},
 "Question", { q: "Will any secretaries host ministers from European countries?", as: ['Yes','No'] }],

// '-'
[["filler",28+11], "NewDashedSentence", {s: "The secretary told Bill which analyst was supposed to participate_in every\r meeting that the bank manager organized and then sent everybody reminders."},
 "Question", { q: "Did the bank manager send out reminders about any meetings himself?", as: ['No','Yes'] }],

// '-'
[["filler",28+12], "NewDashedSentence", {s: "The detective realized which suspect was trying to discredit every\r testimony that the district attorney collected and decided to change the focus of his investigation."},
 "Question", { q: "Did the district attorney collect the testimonies himself?", as: ['Yes','No'] }],

// '-'
[["filler",28+13], "NewDashedSentence", {s: "The bartender bragged about knowing which drink would appeal to every\r guest that the celebrating bachelorette invited and immediately added it to the specials menu."},
 "Question", { q: "Did the bachelorette herself request changes to the specials menu?", as: ['No','Yes'] }],

// '-'
[["filler",28+14], "NewDashedSentence", {s: "The baker realized which apprentice was hoping to steal every\r recipe that the rich clientele liked and understandably fired him from his shop."},
 "Question", { q: "Was anyone trying to steal recipes that the rich clientele liked?", as: ['Yes','No'] }],

// '-'
[["filler",28+15], "NewDashedSentence", {s: "The marketing analyst was hired to find_out which tennis_player would promote every\r racket that was used by a Top Ten player and subsequently a multimillion deal was signed."},
 "Question", { q: "Did the sponsors promote a new tennis racket?", as: ['No','Yes'] }],

// '-'
[["filler",28+16], "NewDashedSentence", {s: "The saleswoman predicted which brand was destined to appeal_to every\r age_group that the clothing store targeted and accordingly purchased the new merchandise."},
 "Question", { q: "Did the clothing store target multiple age groups?", as: ['Yes','No'] }],

// '-'
[["filler",28+17], "NewDashedSentence", {s: "The colonel clarified which officer was ordered to train every\r soldier that the sergeant major enlisted and additionally how long their training would last."},
 "Question", { q: "Was the sergeant major ordered to train all the soldiers?", as: ['No','Yes'] }],

// '-'
[["filler",28+18], "NewDashedSentence", {s: "The assistant_manager remembered which waitress was able to cover every\r shift that the overworked busboy will_miss and fortunately the schedule could be rearranged."},
 "Question", { q: "Was the busboy going to miss any shifts?", as: ['Yes','No'] }],

// '-'
[["filler",28+19], "NewDashedSentence", {s: "The journalist revealed which bank was planning to take over every\r company that the anxious board of directors mismanaged and immediately called his editor."},
 "Question", { q: "Did the board of directors accept a bid from the bank?", as: ['No','Yes'] }],

// '-'
[["filler",28+20], "NewDashedSentence", {s: "The logician specified which axiom was used to prove every\r theorem that the ancient philosopher conjectured and furthermore showed us how to construct the proofs."},
 "Question", { q: "Did the logician use any axioms in his proofs?", as: ['Yes','No'] }],

// '-'
[["filler",28+21], "NewDashedSentence", {s: "The gossip column reported which florist was asked to decorate at_least_one\r wedding that the exotic chef catered and published paparazzi photos of all the guests."},
 "Question", { q: " Were the wedding guests photographed?", as: ['Yes','No'] }],

// '-'
[["filler",28+22], "NewDashedSentence", {s: "The spy overheard which general was planning to attack one_of_the\r bases that the enemy soldiers occupied and immediately reported the information to his superiors."},
 "Question", { q: "Did the spy hesitate to report his information?", as: ['No','Yes'] }],

// '-'
[["filler",28+23], "NewDashedSentence", {s: "The prosecutor established which defendant was sent to destroy the\r evidence that the arresting officer logged and asked the judge to add another count to the indictment."},
 "Question", { q: "Was there any evidence logged by the arresting officer?", as: ['Yes','No'] }],

// '-'
[["filler",28+24], "NewDashedSentence", {s: "The ranger explained which tree species was able to grow in many\r areas of the forest and where it was most likely to be found."},
 "Question", { q: "Did the ranger plant new trees in the forest?", as: ['No','Yes'] }],

// '-'
[["filler",28+25], "NewDashedSentence", {s: "The architect specified which building was expected to replace three\r high-rises that the zoning inspector condemned and how long the construction work would last."},
 "Question", { q: "Did the architect know how long the construction would last?", as: ['Yes','No'] }],

// '-'
[["filler",28+26], "NewDashedSentence", {s: "The waiter forgot which guest was eager to try one_of_the\r specials that the food columnist was but fortunately the order was saved in the restaurant computer."},
 "Question", { q: "Did the waiter keeping track of the orders?", as: ['No','Yes'] }],

// '-'
[["filler",28+27], "NewDashedSentence", {s: "The coordinator pointed_out which volunteer was willing to join the\r charity that the benevolent millionaire did and explained how many people it services."},
 "Question", { q: " Was the charity supported by a millionaire?", as: ['Yes','No'] }],

// '-'
[["filler",28+28], "NewDashedSentence", {s: "The overeager caddy overheard which golfer was hoping to use at_least_one\r club that Tiger Woods also did and told the rest of the caddies about this."},
 "Question", { q: "Did the caddy use Tiger Woods' clubs?", as: ['No','Yes'] }],

// '-'
[["filler",28+29], "NewDashedSentence", {s: "The commentator pointed_out which player was trying to get a_certain\r card that had been dumped by the card dealer in the previous round."},
 "Question", { q: "Did the card dealer dump a card?", as: ['Yes','No'] }],

// '-'
[["filler",28+30], "NewDashedSentence", {s: "The chemist guessed which compound was also likely to cause the\r reaction that the radioactive isotope was and conducted an experiment to see if he was right."},
 "Question", { q: "Did a physicist study the reaction caused by the radioactive isotope?", as: ['No','Yes'] }],

// '-'
[["filler",28+31], "NewDashedSentence", {s: "The tabloid reporter revealed which actress wore the_same\r dress that the famous singer did last year and posted a juicy headline on the tabloid website."},
 "Question", { q: "Did the singer wear the same dress as any actress?", as: ['Yes','No'] }],

// '-'
[["filler",28+32], "NewDashedSentence", {s: "The analyst guessed which broker was attempting to buy the_same\r bonds that the investment banker was and additionally how much he would be willing to spend."},
 "Question", { q: "Did the analyst try to buy any stock?", as: ['No','Yes'] }],
 
];