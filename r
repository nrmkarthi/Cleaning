
library(dplyr)


x.test <- read.csv("test/X_test.txt", sep="",
                              header=FALSE)


y.test <- read.csv("UCI HAR Dataset/test/y_test.txt", sep="",
                              header=FALSE)


subject.test <- read.csv("UCI HAR Dataset/test/subject_test.txt",
                                    sep="", header=FALSE)

test <- data.frame(subject.test, y.test, x.test)


x.train <- read.csv("UCI HAR Dataset/train/X_train.txt", sep="",
                               header=FALSE)


y.train <- read.csv("UCI HAR Dataset/train/y_train.txt", sep="",
                               header=FALSE)

# Read in the training subject dataset
subject.train <- read.csv("UCI HAR Dataset/train/subject_train.txt",
                                    sep="", header=FALSE)


train <- data.frame(subject.train, y.train, x.train)


run.data <- rbind(train, test)


remove(subject.test, x.test, y.test, subject.train,
       x.train, y.train, test, train)

# Read in the measurement labels dataset
features <- read.csv("UCI HAR Dataset/features.txt", sep="", header=FALSE)
# Convert the 2nd column into a vector
column.names <- as.vector(features[, 2])
# Apply the measurement labels as column names to the combined
# running dataset
colnames(run.data) <- c("subject_id", "activity_labels", column.names)

# Select only the columns that contain mean or standard deviations.
# Make sure to bring along the subject and label columns.
# Exclude columns with freq and angle in the name.
run.data <- select(run.data, contains("subject"), contains("label"),
                       contains("mean"), contains("std"), -contains("freq"),
                       -contains("angle"))

# Read in the activity labels dataset
activity.labels <- read.csv("UCI HAR Dataset/activity_labels.txt", 
                            sep="", header=FALSE)


run.data$activity_labels <- as.character(activity.labels[
  match(run.data$activity_labels, activity.labels$V1), 'V2'])

# Clean up the column names. Remove parantheses and hyphens
# from column names, both of which are invalid characters in
# column names. Also fix a set of columns that repeat the
# word "Body".
setnames(run.data, colnames(run.data), gsub("\\(\\)", "", colnames(run.data)))
setnames(run.data, colnames(run.data), gsub("-", "_", colnames(run.data)))
setnames(run.data, colnames(run.data), gsub("BodyBody", "Body", colnames(run.data)))

# Group the running data by subject and activity, then
# calculate the mean of every measurement.
run.data.summary <- run.data %>%
  group_by(subject_id, activity_labels) %>%
  summarise_each(funs(mean))

# Write run.data to file
write.table(run.data.summary, file="run_data_summary.txt", row.name=FALSE)
