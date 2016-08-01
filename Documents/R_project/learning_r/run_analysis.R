## manipulate with the training dataset

train<-read.table("train/X_train.txt")### get the data
features<-read.table("features.txt") ### variable labels
features$V2<-gsub("\\,|\\-", "\\_", features$V2)

colnames(train)<-features$V2 ###change variable labels for the training set

label_train<-read.table("train/y_train.txt") ### create "key"
colnames(label_train)<-"ID_act"
label_train$sets<-"training"

train_set<-cbind(label_train, train) ### add "key" to the training set

## manipulate with the testing dataset

test<-read.table("test/X_test.txt")### get the data
colnames(test)<-features$V2 ### variable labels
label_test<-read.table("test/y_test.txt") ### create the "key"
colnames(label_test)<-"ID_act"
label_test$sets<-"testing"

test_set<-cbind(label_test, test) ### add "key" to the testing set

### joint two datasets together


whole<-rbind(train_set, test_set) ### 10299 observations

### interpret the "Key" with corresponding activities

act<-read.table("activity_labels.txt")

colnames(act)<-c("ID_act", "activity")

### merge based on the "key", so we will be able to interpret the activity

merge_whole<-merge(act, whole, by="ID_act")



### extract measurements with mean and std

pattern<-"^ID_act|^act|^sets|mean|std"
extract<-grep(pattern, names(merge_whole))

extr_whole<-merge_whole[,extract]

### manipulate with variable names

var_name<-names(extr_whole)

pattern <- "\\(\\)"
var_name <- gsub(pattern, "", var_name)
pattern1 <-"^t"
var_name <- sub(pattern1, "Time_", var_name)
pattern2 <- "^f"
var_name <- sub(pattern2, "Freqdomain_", var_name)

### change variable names for extr_whole dataset

colnames(extr_whole) <- var_name


#### new dataset contains the average of each variable for each activity and each subject 

library(dplyr)

new<-extr_whole %>% 
        select (activity, 4:82) %>%
        group_by (activity) %>%
        summarise_each(funs(mean))

write.table(new, "new.txt")
        