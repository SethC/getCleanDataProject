
#get and unzip data to working directory data folder
if(!file.exists("./data")){dir.create("./data")}
fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile="./data/UCI_DataSet.zip")
unzip("./data/UCI_DataSet.zip", overwrite=TRUE, exdir="./data")

#read in features and activity labels
features<-read.table("./data/UCI HAR Dataset/features.txt")
activity_labels<-read.table("./data/UCI HAR Dataset/activity_labels.txt")
cols<-features[,2]


#Read in test data
y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt")
X_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")

labels<-merge(y_test, activity_labels)
colnames(X_test)<-cols


#combine test data
X_test<-cbind(X_test, rep("Test", 2947)); colnames(X_test)[562]="TestOrTrain"
X_test<-cbind(X_test, subject_test); colnames(X_test)[563]="Subject"
X_test<-cbind(X_test, labels[,2]); colnames(X_test)[564]="Activity"


#Read in training data
y_train<-read.table("./data/UCI HAR Dataset/train/y_train.txt")
X_train<-read.table("./data/UCI HAR Dataset/train/X_train.txt")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")

labels<-merge(y_train, activity_labels)
colnames(X_train)<-cols


#combine train data
X_train<-cbind(X_train, rep("train", 7352)); colnames(X_train)[562]="TestOrTrain"
X_train<-cbind(X_train, subject_train); colnames(X_train)[563]="Subject"
X_train<-cbind(X_train, labels[,2]); colnames(X_train)[564]="Activity"


X<-rbind(X_train, X_test)

meanCols<-grep("mean()", features[,2], fixed=TRUE)
stdCols<-grep("std()", features[,2])

export<-X[,c(meanCols, stdCols)]
export<-cbind(X[,563:564], export)

install.packages("reshape2", "plyr")
library(reshape2)
library(plyr)

exportMelt<-melt(export, id=colnames(export[,1:2]), measure.vars=colnames(export[,3:68]))
exportMeans<-ddply(exportMelt, c("Subject", "Activity", "variable"), function(df)mean(df$value))

colnames(exportMeans)[4]="Average"

write.table(exportMeans, file="./data/tidy_ds.txt", row.name=FALSE)
