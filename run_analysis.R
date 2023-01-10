# Load necessary libraries
library(dplyr)

# Set file names
filename <- "getdata_projectfiles_UCI HAR Dataset.zip.zip"
features_file <- "UCI HAR Dataset/features.txt"
activity_labels_file <- "UCI HAR Dataset/activity_labels.txt"
subject_test_file <- "UCI HAR Dataset/test/subject_test.txt"
x_test_file <- "UCI HAR Dataset/test/X_test.txt"
y_test_file <- "UCI HAR Dataset/test/y_test.txt"
subject_train_file <- "UCI HAR Dataset/train/subject_train.txt"
x_train_file <- "UCI HAR Dataset/train/X_train.txt"
y_train_file <- "UCI HAR Dataset/train/y_train.txt"

# Download zip file if it doesn't already exist
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  

# Extract zip file if the folder doesn't already exist
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Read in data
features <- read.table(features_file, col.names = c("n","functions"))
activity_labels <- read.table(activity_labels_file, col.names = c("code", "activity"))
subject_test <- read.table(subject_test_file, col.names = "subject")
x_test <- read.table(x_test_file, col.names = features$functions)
y_test <- read.table(y_test_file, col.names = "code")
subject_train <- read.table(subject_train_file, col.names = "subject")
x_train <- read.table(x_train_file, col.names = features$functions)
y_train <- read.table(y_train_file, col.names = "code")

# Combine test and train data
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject, Y, X)

# Extract only mean and std columns and add activity labels
TidyData <- Merged_Data %>% select(subject, code, contains("mean"), contains("std"))
TidyData$code <- activity_labels[TidyData$code, 2]

# Clean up column names
names(TidyData)[2] = "activity"
names(TidyData)<-gsub("Acc", "Accelerometer", names(TidyData))
names(TidyData)<-gsub("Gyro", "Gyroscope", names(TidyData))
names(TidyData)<-gsub("BodyBody", "Body ",  names(TidyData))
names(TidyData)<-gsub("Mag", "Magnitude", names(TidyData))
names(TidyData)<-gsub("^t", "Time", names(TidyData))
names(TidyData)<-gsub("^f", "Frequency", names(TidyData))
names(TidyData)<-gsub("tBody", "TimeBody", names(TidyData))
names(TidyData)<-gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-std()", "STD", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("angle", "Angle", names(TidyData))
names(TidyData)<-gsub("gravity", "Gravity", names(TidyData))

# Group data by subject and activity and summarize each remaining column by mean
FinalData <- TidyData %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))

# Write final data to file
write.table(FinalData, "FinalData.txt", row.name=FALSE)

# Print structure of final data
str(FinalData)