# Download zipped filed
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "./accel_data.zip", method = "curl")

unzip("accel_data.zip")
library(tidyverse)

# Reading the txt files in main folder, and in the "test" and "train" folders
activity_labels <- read.table("activity_labels.txt", header = FALSE)
features <- read.table("features.txt")

subject_test <- read.table("test/subject_test.txt")
X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")

subject_train <- read.table("train/subject_train.txt")
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")


# Change "Y_test" file and "Y_train" file from numbers to labels, using the "activity_labels" file to know how to convert numbers to labels. This will give vectors of the activity types.
test_activity_vector <- y_test[,1]
activity_labels[,2] <- tolower(activity_labels[,2]) #Made activity labels lower case so that it's prettier.
test_activity_vector <- gsub(activity_labels[1,1], activity_labels[1,2], test_activity_vector)
test_activity_vector <- gsub(activity_labels[2,1], activity_labels[2,2], test_activity_vector)
test_activity_vector <- gsub(activity_labels[3,1], activity_labels[3,2], test_activity_vector)
test_activity_vector <- gsub(activity_labels[4,1], activity_labels[4,2], test_activity_vector)
test_activity_vector <- gsub(activity_labels[5,1], activity_labels[5,2], test_activity_vector)
test_activity_vector <- gsub(activity_labels[6,1], activity_labels[6,2], test_activity_vector)

train_activity_vector <- y_train[,1]
train_activity_vector <- gsub(activity_labels[1,1], activity_labels[1,2], train_activity_vector)
train_activity_vector <- gsub(activity_labels[2,1], activity_labels[2,2], train_activity_vector)
train_activity_vector <- gsub(activity_labels[3,1], activity_labels[3,2], train_activity_vector)
train_activity_vector <- gsub(activity_labels[4,1], activity_labels[4,2], train_activity_vector)
train_activity_vector <- gsub(activity_labels[5,1], activity_labels[5,2], train_activity_vector)
train_activity_vector <- gsub(activity_labels[6,1], activity_labels[6,2], train_activity_vector)


# Get Mean and Stdev from the X_test and X_train files. I used "features.txt" to figure out which columns were the correct Mean and Stdev values. These are col 41-46(tGravityAcc) and 121-126(tBodyGyro). "GravityAcc" and "BodyGyro" are the only measured values

col_vector <- c(41,42,43,44,45,46,121,122,123,124,125,126) #vector of the column numbers that I need.

train_data <- X_train[,col_vector] #selecting the columns that I need from X_train
test_data <- X_test[,col_vector] #selecting the columns that I need from X_test

# Add columns for the subject number and the activity type. 
train_data2 <- cbind(subject_train, train_activity_vector, train_data)
test_data2 <- cbind(subject_test, test_activity_vector, test_data)

#Name the columns. I first make a vector of the column names. Then I add these to the data frames.
name_vector <- c("subject_number", "activity", "gravity_accel_mean_x", "gravity_accel_mean_y", "gravity_accel_mean_z", "gravity_accel_stdev_x", "gravity_accel_stdev_y", "gravity_accel_stdev_z", "body_gyro_mean_x", "body_gyro_mean_y", "body_gyro_mean_z", "body_gyro_stdev_x", "body_gyro_stdev_y", "body_gyro_stdev_z")

colnames(train_data2) <- name_vector
colnames(test_data2) <- name_vector

#Join the test and train dataframes
joined <- rbind(train_data2, test_data2)

#To get the means of the variables grouped by subject number and activity, I first use "group_by" so that R will do the functions according to subject_number and activity. I named the columns using my old name vector, as that seemed to make most sense for the final data frame (tibble). 
tidy_data <- joined %>%  group_by(subject_number, activity) %>% 
        summarize(mean(gravity_accel_mean_x), mean(gravity_accel_mean_y), mean(gravity_accel_mean_z), mean(gravity_accel_stdev_x), mean(gravity_accel_stdev_y), mean(gravity_accel_stdev_z), mean(body_gyro_mean_x), mean(body_gyro_mean_y), mean(body_gyro_mean_z), mean(body_gyro_stdev_x), mean(body_gyro_stdev_y), mean(body_gyro_stdev_z))

colnames(tidy_data) <- name_vector

View(tidy_data) # Look at my resulting tibble
dim(tidy_data) #180 rows and 14 columns in my resulting tibble
write.table(tidy_data, "./tidy_data.txt", row.names = FALSE)


