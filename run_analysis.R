library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileurl, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")

#convert column 2 into character
activity_labels[,2] <- as.character(activity_labels[,2])
feature <- read.table("UCI HAR Dataset/features.txt")
feature[,2] <- as.character(feature[,2])

# Extract only the data on mean and standard deviation
meanandstd <- grep(".*mean.*|.*std.*", feature[,2])

# Rename and remove mean, std and ()
meanandstd.names <- feature[meanandstd,2]
meanandstd.names <- gsub('-mean', 'Mean', meanandstd.names)
meanandstd.names <- gsub('-std', 'Std', meanandstd.names)
meanandstd.names <- gsub('[-()]', '', meanandstd.names)


# Load the datasets
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")[meanandstd]
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(subject_train, y_train , x_train)

x_test <- read.table("UCI HAR Dataset/test/X_test.txt")[meanandstd]
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
testing <- cbind(subject_test, y_test, x_test)

# merge datasets and add labels
completedata <- rbind(training, testing)
colnames(completedata) <- c("subject", "activity", meanandstd.names)

# turn activities & subjects into factors
completedata$activity <- factor(completedata$activity, levels = activity_labels[,1], labels = activity_labels[,2])
completedata$subject <- as.factor(completedata$subject)

completedata.melted <- melt(completedata, id = c("subject", "activity"))
completedata.mean <- dcast(completedata.melted, subject + activity ~ variable, mean)

write.table(completedata.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
