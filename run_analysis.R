################################################################################
###     This function analyzes data as required by the Course Project in the
###             Getting and Cleaning Data course.
###
###     The following data files must reside in the same working directory: 
###             activity_labels.txt
###             features.txt
###             subject_train.txt
###             X_train.txt
###             y_train.txt
###             subject_test.txt
###             X_test.txt
###             y_test.txt
################################################################################
run_analysis <- function() {
        ### Step 0 - fast read data into data.tables
        library(data.table)
        actLabel <- fread("activity_labels.txt", sep="auto", header="auto", na.strings="NA")
        featureName <- fread("features.txt", sep="auto", header="auto", na.strings="NA")
        subject.train <- fread("subject_train.txt", sep="auto", header="auto", na.strings="NA")
        y.train <- fread("y_train.txt", sep="auto", header="auto", na.strings="NA")
        X.train <- fread("X_train.txt", sep="auto", header="auto", na.strings="NA")
        subject.test<- fread("subject_test.txt", sep="auto", header="auto", na.strings="NA")
        y.test<- fread("y_test.txt", sep="auto", header="auto", na.strings="NA")
        X.test<- fread("X_test.txt", sep="auto", header="auto", na.strings="NA")

        ### Step 1. Extracts only the measurements on the mean and standard deviation for each measurement. 
        ###             Only 66 out of 561 features are either mean or standard deviation.
        requiredFeatures <- featureName[which(featureName$V2 %in% c(
                "tBodyAcc-mean()-X","tBodyAcc-mean()-Y","tBodyAcc-mean()-Z",
                "tBodyAcc-std()-X","tBodyAcc-std()-Y","tBodyAcc-std()-Z",
                "tGravityAcc-mean()-X","tGravityAcc-mean()-Y","tGravityAcc-mean()-Z",
                "tGravityAcc-std()-X","tGravityAcc-std()-Y","tGravityAcc-std()-Z",
                "tBodyAccJerk-mean()-X","tBodyAccJerk-mean()-Y","tBodyAccJerk-mean()-Z",
                "tBodyAccJerk-std()-X","tBodyAccJerk-std()-Y","tBodyAccJerk-std()-Z",
                "tBodyGyro-mean()-X","tBodyGyro-mean()-Y","tBodyGyro-mean()-Z",
                "tBodyGyro-std()-X","tBodyGyro-std()-Y","tBodyGyro-std()-Z",
                "tBodyGyroJerk-mean()-X","tBodyGyroJerk-mean()-Y","tBodyGyroJerk-mean()-Z",
                "tBodyGyroJerk-std()-X","tBodyGyroJerk-std()-Y","tBodyGyroJerk-std()-Z",
                "tBodyAccMag-mean()","tBodyAccMag-std()","tGravityAccMag-mean()","tGravityAccMag-std()",
                "tBodyAccJerkMag-mean()","tBodyAccJerkMag-std()","tBodyGyroMag-mean()","tBodyGyroMag-std()",
                "tBodyGyroJerkMag-mean()","tBodyGyroJerkMag-std()",
                "fBodyAcc-mean()-X","fBodyAcc-mean()-Y","fBodyAcc-mean()-Z",
                "fBodyAcc-std()-X","fBodyAcc-std()-Y","fBodyAcc-std()-Z",
                "fBodyAccJerk-mean()-X","fBodyAccJerk-mean()-Y","fBodyAccJerk-mean()-Z",
                "fBodyAccJerk-std()-X","fBodyAccJerk-std()-Y","fBodyAccJerk-std()-Z",
                "fBodyGyro-mean()-X","fBodyGyro-mean()-Y","fBodyGyro-mean()-Z",
                "fBodyGyro-std()-X","fBodyGyro-std()-Y","fBodyGyro-std()-Z",
                "fBodyAccMag-mean()","fBodyAccMag-std()","fBodyBodyAccJerkMag-mean()",
                "fBodyBodyAccJerkMag-std()","fBodyBodyGyroMag-mean()","fBodyBodyGyroMag-std()",
                "fBodyBodyGyroJerkMag-mean()","fBodyBodyGyroJerkMag-std()"))]
        
        ## myvars provides corresponding column names in X tables for the 66 required features.
        myvars <- paste("V", requiredFeatures$V1, sep="") 
        ## subsetting X tables of both train and test by the 66 required features
        X.train.sub <- subset(X.train, select=myvars)
        X.test.sub <- subset(X.test, select=myvars)
        
        ### Step 2. Uses descriptive activity names to name the activities in the data set
        ## rename columns in subject tables and y tables
        setnames(subject.train,"V1","subjectID")
        setnames(y.train,"V1","activityID")
        setnames(subject.test,"V1","subjectID")
        setnames(y.test,"V1","activityID")
        ## combine subject, X, and y tables into single tables for both train and test sets
        X.train.sub.IDs <- X.train.sub[,subjectID:=subject.train$subjectID][,activityID:=y.train$activityID]
        X.test.sub.IDs <- X.test.sub[,subjectID:=subject.test$subjectID][,activityID:=y.test$activityID]
        ## rename columns in actLabel table (activity labels)
        setnames(actLabel, old = c('V1','V2'), new = c('activityID','activityName'))
        ## do join (merge) to add activityName column into the single tables obtained above
        setkey(actLabel,activityID)
        setkey(X.test.sub.IDs,activityID)
        setkey(X.train.sub.IDs,activityID)
        X.test.sub.IDs.ActName <- merge(X.test.sub.IDs,actLabel, all.x=TRUE)
        X.train.sub.IDs.ActName <- merge(X.train.sub.IDs,actLabel, all.x=TRUE)
        
        ### Step 3.Merges the training and the test sets to create one data set.
        combined <- rbind(X.train.sub.IDs.ActName, X.test.sub.IDs.ActName) 
        
        ### Step 4.Appropriately labels the data set with descriptive variable names. 
        ###        Rename "V1","V2","V3", etc. to corresponding measurement names
        setnames(combined, old = myvars, new = requiredFeatures$V2)
        
        ### Step 5.From the data set in step 4, creates a second, independent 
        ###        tidy data set with the average of each variable for each 
        ###        activity and each subject.
        ## compute mean of each feature for each subset grouped by subjectID,activityID,activityName
        combined_group <- combined[, lapply(.SD, mean, na.rm=TRUE), by = list(
                subjectID,activityID,activityName)]
        ## order by subjectID,activityID,activityName
        combined_group[order(subjectID,activityID,activityName),]
        ## write the result to tidy_summary.txt file as required
        write.table(combined_group, file = "tidy_summary.txt", row.names = FALSE)
}