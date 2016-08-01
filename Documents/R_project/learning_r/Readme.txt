The data is truncated into training and testing datasets:

First, working on the training set as below:

1. to get the data and save them in a variable "train": train<-read.table("train/X_train.txt");

2. but the data does not include headers, so we need to find the headers from features.txt:
   features<-read.table("features.txt") 

3. some adjustment for the headers to replace "." and "-" with "_":features$V2<-gsub("\\,|\\-", "\\_", features$V2)

4. apply the feature names for train dataset: colnames(train)<-features$V2 



5. need to create "key" column for later merge, using the label for activities: label_train<-read.table("train/y_train.txt")
6. change the column name to "ID_act": colnames(label_train)<-"ID_act"

7. now combine the train dataset with "key" column cotrain_set<-cbind(label_train, train).

==========================================================================================

Second, working on the testing set as below:

1. to get the data and save them in a variable "test:
test<-read.table("test/X_test.txt")

2. add column names for the test set:
colnames(test)<-features$V2

3. create the "key" column as in the train set:
label_test<-read.table("test/y_test.txt")
colnames(label_test)<-"ID_act"
label_test$sets<-"testing"

4. combine the "key" and the "test" sets:
test_set<-cbind(label_test, test) 

========================================================================================

Third, joint train and test datasets together:


whole<-rbind(train_set, test_set) ### 10299 observations

=========================================================================================

Interpret the activity labels:

act<-read.table("activity_labels.txt")

colnames(act)<-c("ID_act", "activity")

==========================================================================================

merge based on the "key", so we will be able to interpret the activity:

merge_whole<-merge(act, whole, by="ID_act")

=========================================================================================

extract measurements with mean and std, also you want to keep ID_act, act, sets:

pattern<-"^ID_act|^act|^sets|mean|std"
extract<-grep(pattern, names(merge_whole))

get the data set called extr_whole containing measurements with only mean and std columns:

extr_whole<-merge_whole[,extract]

==========================================================================================

Make some adjustments to the column names so that they would easier to read:

var_name<-names(extr_whole)

pattern <- "\\(\\)"
var_name <- gsub(pattern, "", var_name)
pattern1 <-"^t"
var_name <- sub(pattern1, "Time_", var_name)
pattern2 <- "^f"
var_name <- sub(pattern2, "Freqdomain_", var_name)


colnames(extr_whole) <- var_name

===========================================================================================

new dataset contains the average of each variable for each activity and each subjec(we need
to use dplyr with grouping based on the activities and summarise_each(funs()):


library(dplyr)

new<-extr_whole %>% 
        select (activity, 4:82) %>%
        group_by (activity) %>%
        summarise_each(funs(mean))

write.table(new, "tidy_data.txt")
