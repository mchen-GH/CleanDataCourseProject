############################################################################
###	This file describes the variables, the data, and any transformations 
###     or work that I performed to clean up the data.
############################################################################

The project data files can be downloaded from the link below and are not included in this repo.
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

The data are smart phone (Samsung Galaxy S II) accelerometer and gyroscope signals gathered in experiments with
30 subjects, each performed 6 activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING).

	Provided File			Content
	-------------------		-------------------
	activity_labels.txt		A 6x2 table that provides mapping between V1 (Activity ID) and V2 (Activity name).
	features.txt			A 561x2 table that provides mapping between V1 (feature ID) and V2(feature name).
	features_info.txt		This file explains in detail how the 561 features were derived, which I will not repeat here.
		
The original authors randomly partitioned the data into two sets, where 70% of the subjects was selected for generating 
the training data and 30% the test data. 

	Provided File			Content
	-------------------		-------------------
	subject_train.txt		A 7352x1 table. The single column contains integer data with 21 unique values, namely 21 subjects.
	X_train.txt			A 7352x561 table that provides measurements of the 561 features. All values are normalized and bounded within [-1,1].
	y_train.txt			A 7352x1 table. The single column contains integer data with 6 unique values, namely 6 activities.
	subject_test.txt		A 2947x1 table. The single column contains integer data with 9 unique values, namely 9 subjects.
	X_test.txt			A 2947x561 table that provides measurements of the 561 features. All values are normalized and bounded within [-1,1].
	y_test.txt			A 2947x1 table. The single column contains integer data with 6 unique values, namely 6 activities.

The original data set also provided a few other raw data files that were not used in this assignment and not described here.


The required tasks for the assignment are listed below:
	1.Merges the training and the test sets to create one data set.
	2.Extracts only the measurements on the mean and standard deviation for each measurement. 
	3.Uses descriptive activity names to name the activities in the data set
	4.Appropriately labels the data set with descriptive variable names. 
	5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


I took the following sequence of steps to fullfill the data analysis requirements:

	Step 1. Extracts only the measurements on the mean and standard deviation for each measurement. 
        
		I inspected the data from features.txt and identified 66, out of 561, features containing either mean() or std() in the feature names.
		Then, I used the 66 feature names to find the corresponding feature IDs, which in turn are used to find the corresponding columns in X_train and X_test data.
 		Finally, two 66-column subsets were created from X_train and X_test data, respectively.

	Step 2. Uses descriptive activity names to name the activities in the data set.

        	The "V1" columns of the subject.train and subject.test were renamed to "subjectID".
		The "V1" columns of the y.train and y.test were renamed to "activityID".
		Then, I added single-column tables subject_train and y_train into X_train table and subject_test and y_test into X_test. So, now each has 68 columns.
		The "V1" and "V2" columns of the activity_labels were renamed to "activityID" and "activityName", respectively.
		Finally, I did a join on "activityID" between the activity_labels and the 68-column tables above to add "activityName" column. So, now each has 69 columns.
		The "activityName" column satisfies the requirement of descriptive activity name.

	Step 3. Merges the training and the test sets to create one data set.

		I used rbind method to combind the two 69-column data tables into one that merges training and test sets.

	Step 4. Appropriately labels the data set with descriptive variable names. 
        
		The feature column names "V1","V2","V3", etc. were renamed to corresponding descriptive feature names.

	Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
        
        	I used lapply method with group by subjectID,activityID,activityName to compute means for each of the 66 features.
		The resultig data set has only 180 rows, which is expected for 30 subjects times 6 activities.
		The result was written to tidy_summary.txt file as required.
	