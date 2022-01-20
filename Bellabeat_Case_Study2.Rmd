---
title: "Bellabeat_Case_Study"
author: "Jay Entienza"
date: "1/20/2022"
output: html_document
---



# The Case Study

## About Bellabeat

Bellabeat is a wellness company that manufactures health-focused smart products. Their main goal is to empower women by making them knoweledgable and more in control of their health. Bellabeat products allow their users to track their activities, sleep activities, stress levels, and reproductive health.

## Business Task

Bellabeat is an already successful company in their industry. However, they are now thinking of more ways to grow.

To do this, Bellabeat wants to analyze how consumers use non-Bellabeat smart devices. From the analyses, Bellabeat asked us to apply the insights on one of their products.

### Business Questions:

Specifically,these are our business questions:

**1. What are some trends in smart device usage?**

**2. How could these trends apply to Bellabeat consumers?**

**3. How could these trends help influence Bellabeat marketing strategy?**

------------------------------------------------------------------------

# Data Preparation

### Data Source

The data used in this analysis is a 2-month period worth of [FitBit Fitness Tracker Data from Kaggle](https://www.kaggle.com/arashnic/fitbit), which data were originally gathered by [Furbeg, Brinton, Keating, & Ortiz in 2016.](https://zenodo.org/record/53894#.Yd9M0_5ByHt)

**Data Acquisition:** According to the cited study, the participants in the study were reached via a crowd-sourcing strategy. These participant were said to be the respondents from a distributed survey (which they did not specify) via *Amazon Mechanical Turk* between March 12 2016 - May 12 2016.\
\
By the end, they were able to gather a total of **30 eligible FitBit users.**

**Gathered [[Data:\\\\](Data:){.uri}](%5BData:%5D(Data:)%7B.uri%7D){.uri}** The FitBit users consented to getting a record of their:

1.  Daily Physical Activity

2.  Daily Steps

3.  Daily Heart Rates

4.  Daily Calories Burned

### Data Scope & Limitation:

The following are the information I have found to be lacking or were not defined from the data set and what are

-   **Characteristics of Samples** - the demographics (age, sex, class, etc.) of the sample. With this, we must keep in mind how would it differ in comparison with Bellabeat's target audience: women.

-   **Inconsistencies with records** - as we will see throughout the analyses, I've decided not to use some of the data types because there were too many missing records that they are not matched with the records of other data types. For example: there were a lot of users that do not have records for their sleep habits.

-   **Relevance of data -** with the ongoing pandemic, our data might be outdated as a lot of factors have changed the way we view and incorporate health and fitness in our lifestyle

### Definition of Variables

Knowing these limitations and information about our data set, we will define the variables using FitBit's definition.

**Daily Physical Activity**

These are presented in total per day per user

1\. Intensity of activities:

a\. **Sedentary Activity** - I did not find anything from the FitBit data resources on the definition of Sedentary Activtiies, but since the classification is based on MET, literature says that: sedentary activities are those having a MET value between one and 1.5 or less than 2.0 -- such as lying down and sitting down

b\. **Lightly Active** - between 1.5 to 3 METs

c\. **Fairly Active** - between 3 and 6 METs

d\. **Very Active** - greater than or equal to 6 METs or equal to 145 steps per minute in at least 10-minute bouts

2.  **Total Steps** - total steps taken by each user in a day

3.  **Calories -** total calories burned in a day per user

**Sleep Activity**

All recorded data of each users' sleep activity are provided in minutes.

1\. **Total Time in Bed**

2\. **Total Time Asleep**

In my analysis, I mostly used the data on minutes spent by users doing various intensities of activities as the basis of our daily consumption trend. This would narrow the focus in answering the business question and would make our analysis more concise. However, I still used the data on total steps and distance to compare in between variables. (More details on this throughout the report).

## Setting R Environment

```{r Setting Environment}

library(ggplot2)
library(tidyverse)
library(lubridate)
library(scales)
library(tidyr)
library(dplyr)
library(readr)
library(skimr)
library(ggpubr)
library(reshape2)
```

### Loading the Data into Data Frames

I loaded the three main CSVs needed for the analysis: *daily activity, sleep day, and weight log info*. I did not load the separate csv file for calories because upon checking, the data is already incorporated in the daily activity csv under "Calories" column. I also decided not to include the heart rate csv anymore as the ID numbers are completely different from the other data sets and it would not make sense to compare it side by side.

**Heart rate Data**: I did not include the data on this because the ID numbers are completely different from the other records.

```{r}
setwd("~/Portfolio_Bellabeat/Cleaned Data from Excel")   #Setting File Directory

dailyActivity2 <- read.csv("dailyActivity_merged - Copy.csv")       #Daily Activity Data
head(dailyActivity2)

dailySleep2 <- read.csv("sleepDay_merged2.csv")                     #Sleep Data
head(dailySleep2)

weightinfo <- read.csv("weightLogInfo_merged.csv")                  #Weight Info Data
head(weightinfo)

heartrate <- read.csv("heartrate_seconds_merged.csv")                                     #heart rate
head(heartrate)


```

### Overview Data Structure & Format

```{r}
typeof(weightinfo$Date)
typeof(weightinfo$Timestamp)

typeof(dailySleep2$SleepDay) #it returned as a character, yet it is written as date and time
class(dailySleep2$SleepDay)

typeof(dailySleep2$Date_Reformatted)
typeof(dailySleep2$ï..Id)

```

------------------------------------------------------------------------

# Data Cleaning

### Standardization of Individual CSVs

```{r}
dailyActivity2$Date_Reformatted <- as.Date(dailyActivity2$ActivityDate,format='%m/%d/%Y') #daily Activity
dailySleep2$Date_Reformatted <- as.Date(dailySleep2$SleepDay, format='%m/%d/%Y')  #sleep data

weightinfo$Date_Reformatted <- as.Date(weightinfo$Date, format='%m/%d/%Y') #weightinfo
```

```{r}
#Renaming Id column 
dailySleep2_ <- dailySleep2%>% 
  rename(Id=ï..Id)
```

### Checking for Number of Unique Records

```{r}
#Checking how many unique records are there in each data set to know how will we merge the data 
n_distinct(dailyActivity2$Id)
n_distinct(dailySleep2_$Id)
n_distinct(weightinfo $Id)

```

After counting the unique Id values in each data set, we find that the numbers are not equal. More so, the number of unique values for weight info is much smaller than the other two. **Because of this, I've decided not to include Weight info in the main analysis as there is obviously a lack of data hence, comparing the trends side by side would not make sense.**

Knowing that the number of records per data set are inconsistent, I first proceeded to combining the data sets before removing duplicates. In any case, it will arrive at the same results.

## Merging Data

After standardizing the formats, I merged the data sets using left join with Daily Sleep data set as my base table. This is because I want to be able to work on a data set that have records for daily activities, calories, and sleep activity.

```{r}
merged_ActivitySleep <- left_join(dailySleep2_, dailyActivity2, by=c("Id","Date_Reformatted"))
head(merged_ActivitySleep)
```

### Duplicates

```{r}
#double checking for unique IDs in the merged table
n_distinct(merged_ActivitySleep$Id) 


#Counting the number of duplicate records per row in the merged table
sum(duplicated(merged_ActivitySleep))

#removing duplicates
DailyActivity_Sleep <- distinct(merged_ActivitySleep)
head(DailyActivity_Sleep)

#Now "DailyActivity_Sleep" is the table that we will use from here on now
```

### Cleaning Merged Data

```{r include=FALSE}
DailyActivity_Sleep$Id <- as.character(DailyActivity_Sleep$Id) 
drop_na(DailyActivity_Sleep)
```

------------------------------------------------------------------------

# Data Analysis

To proceed with my analysis, I went back to the business questions.

**Business Question: 1. What are some trends in smart device usage?**

To answer this, I analyzed the following:

1.  **An overall descriptive statistics of the scores to analyze their distribution**
2.  **Descriptive Statistics per User per Variable**
3.  **Relationship of Variables per User**
4.  **Percentage of each User Type**
5.  **Total Time Smart Watches were Worn**

## Descriptive Statistics

```{r}
skim_without_charts(DailyActivity_Sleep)
summary(DailyActivity_Sleep)
```

### **Test of Normality**

Before deciding which descriptive statistics are we going to use for our analysis, we have to check whether the data falls along a normal distribution or not. To do this, I both used visualization and normality test measures. I visualized the scores of each variables along a histogram to check if there are numerous outliers. Then, I used the Shapiro-Wilk test for normality to confirm it's normality. **Visualization of the scores**

```{r}
#Intensity of Activities
ggplot(data= DailyActivity_Sleep, aes(VeryActiveMinutes))+
  geom_histogram()+ggtitle("Very Active Minutes")
ggplot(data= DailyActivity_Sleep, aes(LightlyActiveMinutes))+
  geom_histogram()+ggtitle("Lightly Active Minutes")
ggplot(data= DailyActivity_Sleep, aes(FairlyActiveMinutes))+
  geom_histogram()+ggtitle("Fairly Active Minutes")
ggplot(data= DailyActivity_Sleep, aes(SedentaryMinutes))+
      geom_histogram()+ggtitle("Sedentary Minutes")

```

**\
Intensity of Activities:** From the histogram, it appears that they do not fall along a normal curve and we also see a lot of outliers. The same findings are also true for the Calories, Total Steps, and Sleep data records.

```{r}
#Total Steps & Calories
ggplot(data=DailyActivity_Sleep, aes(TotalSteps))+
  geom_histogram()+ggtitle("Total Steps")

ggplot(data= DailyActivity_Sleep, aes(Calories))+
  geom_histogram()+ggtitle("Calories")
```

```{r}
#Sleep & Time in Bed
ggplot(data= DailyActivity_Sleep, aes(TotalMinutesAsleep))+
  geom_histogram()+ggtitle("Total Minutes Asleep")
ggplot(data= DailyActivity_Sleep, aes(TotalTimeInBed))+
  geom_histogram()+ggtitle("Total Time in Bed")

```

**Using Shapiro-Wilk Test for Normality**

```{r}

shapiro.test(DailyActivity_Sleep$VeryActiveMinutes)

shapiro.test(DailyActivity_Sleep$SedentaryMinutes)

shapiro.test(DailyActivity_Sleep$LightlyActiveMinutes)

shapiro.test(DailyActivity_Sleep$FairlyActiveMinutes)
```

Based on the Shapiro-Wilk test for normality, we can see that none of the data fall in a normal distribution and when we visualize the data further, we also see that there are a number of outliers among the scores. Therefore, choosing the mean as the representation of our data would not fully capture the whole data. Instead, we must use the median score to describe our data.

**Recalculating Descriptive Statistics**

```{r}
summary(DailyActivity_Sleep)


```

```{r}
#Medians of Lifestyle
median(DailyActivity_Sleep$VeryActiveMinutes)
median(DailyActivity_Sleep$FairlyActiveMinutes)
median(DailyActivity_Sleep$LightlyActiveMinutes)
median(DailyActivity_Sleep$SedentaryMinutes)
```

```{r}
#Medians of Total Steps 
median(DailyActivity_Sleep$TotalSteps)

#Median of calories
median(DailyActivity_Sleep$Calories)

#median of sleep records 
median(DailyActivity_Sleep$TotalMinutesAsleep)
median(DailyActivity_Sleep$TotalTimeInBed)
```

**Results:\
Daily Minutes per Intensity of Activity:**

Highest median: **Sedentary Minutes**\
Lowest median: **Very Active Minutes**\

Most of the users spend the most time in sedentary and in very active mode.

The difference between the medians of the scores were also huge except for the very active minutes and the fairly active minutes.\
\
**Daily Calories Burned:**

Median is at 2207 calories burned a day. I did not classify this into categories using standard values because

**Daily Total Steps**

The median daily steps in a day among users is around the average recommended daily steps.

## Grouping Data per User

To get an accurate description of our FitBit users' scores per variable, we must first group the data per user or by their ID numbers.\
\
From this point of analysis, I classified each users' activity into their: **lifestyle type, sleeping habits, intensity step type** by following the health expert-recommended (specifically the WHO) number of minutes of activity for **adults** per week.

```{r}
per_user <- DailyActivity_Sleep %>% 
  group_by(Id) %>% 
  summarise_at(vars(VeryActiveMinutes:SedentaryMinutes,TotalMinutesAsleep:TotalTimeInBed,TotalSteps, Calories),list(median))

head(per_user)
```

**Redefining Levels**

```{r}

per_user <- per_user %>% add_column %>% mutate(Lifestyle = case_when(
VeryActiveMinutes >= 21 ~ "Very Active",
FairlyActiveMinutes >= 21 & VeryActiveMinutes <=20 ~ "Fairly Active",
FairlyActiveMinutes == 0.0 & VeryActiveMinutes == 0.0 ~"Sedentary",
FairlyActiveMinutes <= 20 & VeryActiveMinutes <= 20 & LightlyActiveMinutes > 20 ~"Lightly Active"))


per_user <- per_user %>% add_column %>% mutate(Sleep = case_when(TotalMinutesAsleep >= 420 ~ "Enough Sleep", TotalMinutesAsleep <=420 ~"Not Enough Sleep"))


per_user <- per_user %>% add_column %>% mutate(Steps=case_when(TotalSteps >= 10000 ~"Active Steps",
                                                                 TotalSteps <=9999 & TotalSteps >=7500 ~ "Lightly Active Steps", 
                                                                 TotalSteps <=7499 & TotalSteps >=5000 ~ "Slightly Active Steps", 
                                                                 TotalSteps <=4999 ~"Sedentary Steps"))
head(per_user)
```

**Transforming Variables**

We need to transform

```{r}
#Transforming Lifestyle Data into Numeric Factors

head(per_user)
per_user$Lifestyle.S <- factor(per_user$Lifestyle, c("Sedentary","Lightly Active","Fairly Active", "Very Active"))
per_user$Lifestyle.SP <- as.numeric(per_user$Lifestyle.S)


#Transforming Sleep Data into Numeric Factors
per_user$Sleep.S <- factor(per_user$Sleep, c("Not Enough Sleep","Enough Sleep"))
per_user$Sleep.SP <- as.numeric(per_user$Sleep.S)

#Transforming Time in Bed into Numeric Factors
per_user$TimeInBed.S <- factor(per_user$TotalTimeInBed)
per_user$TimeInBed.SP <- as.numeric(per_user$TimeInBed.S)

#Transforming Total Steps 
per_user$Steps.S <- factor(per_user$Steps, c("Sedentary Steps","Lightly Active Steps","Slightly Active Steps", "Active Steps"))
per_user$Steps.SP <- as.numeric(per_user$Steps.S)


#Transforming Calories
per_user$Calories.S <- factor(per_user$Calories)
per_user$Calories.SP <- as.numeric(per_user$Calories.S)


head(per_user)

```

### Correlating Variables

**Relationship of Lifestyle User Type with Other Variables**

```{r}
#Lifestyle vs. Steps
cor.test(per_user$Lifestyle.SP, per_user$Steps.SP,
         method = "spearman",
         exact = FALSE)

LSTEPS <- ggscatter(per_user, x="Lifestyle.SP", y="Steps.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "User Lifestyle Type", ylab = "Steps",
          title= "User Lifestyle Type vs. Steps Intensity")

#Lifestyle vs. Calories Burned
cor.test(per_user$Lifestyle.SP, per_user$Calories.SP,
         method = "spearman",
         exact = FALSE)

LCALORIES <- ggscatter(per_user,x="Lifestyle.SP", y="Calories.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "User Lifestyle Type", ylab = "Calories Burned",
          title = "User Lifestyle Type vs. Calories Burned")

#Lifestyle vs. Sleep Activity
cor.test(per_user$Lifestyle.SP, per_user$Sleep.SP,
         method = "spearman",
         exact = FALSE)

LSLEEP <- ggscatter(per_user, x="Lifestyle.SP", y="Sleep.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "User Lifestyle Type", ylab = "Minutes Asleep",
          title = "User Lifestyle Type vs. Minutes Asleep")

```

**Relationship of Calories Burned with Other Variables**

```{r}
#Calories vs. Sleep
cor.test(per_user$Sleep.SP, per_user$Calories.SP,
         method = "spearman",
         exact = FALSE)
SLECALORIES <- ggscatter(per_user,x="Sleep.SP", y="Calories.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "Sleep", ylab = "Calories Burned",
          title = "Sleep vs. Calories Burned")

#Calories vs. Steps
cor.test(per_user$Steps.SP, per_user$Calories.SP,
         method = "spearman",
         exact = FALSE)

STECALORIES <- ggscatter(per_user,x="Steps.SP", y="Calories.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "Steps", ylab = "Calories Burned",
          title = "Steps vs. Calories Burned")
```

**Relationship of Total Time in Bed**

```{r}
#TotalTimeinBed vs. TimeASleep
cor.test(per_user$TimeInBed.SP, per_user$Sleep.SP, method="spearman", 
         exact = FALSE)
BEDSLEEP <- ggscatter(per_user,x="TimeInBed.SP",y="Sleep.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "Minutes in Bed", ylab = "Sleep",
          title = "Minutes in Bed vs. Minutes Sleep")

#TotalTimeinBed vs. Lifestyle
cor.test(per_user$TimeInBed.SP, per_user$Lifestyle.SP,method="spearman",
          exact = FALSE)
BEDLIFES <- ggscatter(per_user,x="TimeInBed.SP",y="Lifestyle.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "Minutes in Bed", ylab = "User Lifestyle Type",
          title = "Minutes in Bed vs. User Lifestyle Type")


#TotalTimeinBed vs. Steps
cor.test(per_user$TimeInBed.SP,per_user$Steps.SP, method = "spearman",
         exact = FALSE)
BEDSTEPS <- ggscatter(per_user,x="TimeInBed.SP",y="Steps.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "Minutes in Bed", ylab = "Steps",
          title = "Minutes in Bed vs. Steps")

#TotalTimeInBed vs. Calories
cor.test(per_user$TimeInBed.SP,per_user$Calories.SP, method = "spearman",
         exact = FALSE)
BEDCALORIES <- ggscatter(per_user,x="TimeInBed.SP",y="Calories.SP",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "Minutes in Bed", ylab = "Calories Burned",
          title = "Minutes in Bed vs. Calories Burned")

```

#### Combining Plots with (ggarrange)

```{r}
ggarrange(LCALORIES,LSLEEP

          ,LSTEPS)

ggarrange(BEDCALORIES,BEDSLEEP,

          BEDSTEPS,BEDLIFES)

ggarrange(SLECALORIES,STECALORIES)
```

**Results:**

Based on the results of the Spearman correlation, there are no significant relationships among the variables except for the time spent in bed and time spent asleep.

# Data Trends per Days of the Week

```{r}
#Extracting Days of the Week
DailyActivity_Sleep$Weekdays<-weekdays(as.Date(DailyActivity_Sleep$Date_Reformatted))
```

### **Grouping Data per Days of the Week**

```{r}
User_Weekdays_Median <- DailyActivity_Sleep %>% 

  group_by(Weekdays) %>% 

  summarise_at(vars(VeryActiveMinutes:SedentaryMinutes,TotalMinutesAsleep:TotalTimeInBed,TotalSteps, Calories),list(median))

```

### Transforming Variable

```{r}
#Fixing code for user_weekdays_median2

#lifestyle
User_Weekdays_Median <- User_Weekdays_Median %>% add_column %>% mutate(Lifestyle = case_when(
    VeryActiveMinutes >= 21 ~ "Very Active",
    FairlyActiveMinutes >= 21 & VeryActiveMinutes <=20 ~ "Fairly Active",
    FairlyActiveMinutes == 0.0 & VeryActiveMinutes == 0.0 ~"Sedentary",
    FairlyActiveMinutes <= 20 & VeryActiveMinutes <= 20 & LightlyActiveMinutes > 20 ~"Lightly Active"))
User_Weekdays_Median$Lifestyle.S <- factor(User_Weekdays_Median$Lifestyle, c("Sedentary","Lightly Active","Fairly Active", "Very Active"))
User_Weekdays_Median$Lifestyle.SP <- as.numeric(User_Weekdays_Median$Lifestyle.S)


#sleep
User_Weekdays_Median <- User_Weekdays_Median %>% add_column %>% mutate(Sleep = case_when(TotalMinutesAsleep >= 420 ~ "Enough Sleep", TotalMinutesAsleep <=420 ~"Not Enough Sleep"))
User_Weekdays_Median$Sleep.S <- factor(User_Weekdays_Median$Sleep, c("Not Enough Sleep","Enough Sleep"))
User_Weekdays_Median$Sleep.SP <- as.numeric(User_Weekdays_Median$Sleep.S)



#Steps
User_Weekdays_Median <- User_Weekdays_Median %>% add_column %>% mutate(Steps=case_when(TotalSteps >= 10000 ~"Active Steps",
                                                                 TotalSteps <=9999 & TotalSteps >=7500 ~ "Lightly Active Steps", 
                                                                 TotalSteps <=7499 & TotalSteps >=5000 ~ "Slightly Active Steps", 
                                                                 TotalSteps <=4999 ~"Sedentary Steps"))
User_Weekdays_Median$Steps.S <- factor(User_Weekdays_Median$Steps, c("Sedentary Steps","Lightly Active Steps","Slightly Active Steps", "Active Steps"))
User_Weekdays_Median$Steps.SP <- as.numeric(User_Weekdays_Median$Steps.S)

#calories
User_Weekdays_Median$Calories.S <- factor(User_Weekdays_Median$Calories)
User_Weekdays_Median$Calories.SP <- as.numeric(User_Weekdays_Median$Calories.S)


#Fixing the arrangement of days of the week 
User_Weekdays_Median$Weekdays <- factor(User_Weekdays_Median$Weekdays, c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))


head(User_Weekdays_Median)

```

### Visualizing Medians per Days of the Week

```{r}
#graphing medians of lifestyle trend per day of the week
ggplot(data=User_Weekdays_Median, aes(x=Weekdays, y=Lifestyle.S))+geom_bar(stat="identity", fill = "royalblue2")+ labs(title = "Median Lifestyle Trend per Day of the Week", x="",y="")

#Graphing Medians of Lifestyle with steps as fill
ggplot(data=User_Weekdays_Median, aes(x=Weekdays, y=Lifestyle.S,fill=Steps.S))+
geom_bar(stat="identity")+ labs(title = "Median Lifestyle & Steps Intensity per Day of the Week", x="",y="", fill="Steps Intensity")

#graphing medians of calories trend per day of the week
ggplot(data=User_Weekdays_Median,aes(x=Weekdays,y=Calories.S))+ geom_bar(stat = "identity", fill="steelblue")+ labs(title = "Calories Burned per Day of the Week", x="",y="")

ggplot(data=User_Weekdays_Median, aes(x=Weekdays, y=Calories.S,fill=Steps.S))+
geom_bar(stat="identity")+ labs(title = "Median Calories Burned & Steps Intensity per Day of the Week", x="",y="", fill="Steps Intensity")

#graphing medians of total steps with step activity intensity
ggplot(data=User_Weekdays_Median,aes(x=Weekdays,y=TotalSteps, fill=Steps.S))+
geom_bar(stat = "identity")+labs(title = "Median Steps per Day of the Week", x="",y="",fill= "Steps Activity Intensity")

#graphing minutes asleep with sleep habits as fill
ggplot(data=User_Weekdays_Median,aes(x=Weekdays,y=TotalMinutesAsleep, fill=Sleep.S))+geom_bar(stat = "identity")+labs(title = "Median Time Asleep per Day of the Week", x="",y="", fill = "Sleep Habits")

```

**Results:**

**Trends per Day of the Week**

**Lifestyle per Day of the Week:**

[Day with most very active minutes]{.ul}: Monday

[Days with most sedentary minutes]{.ul}: Sunday

For most days in the whole two-month data duration, the median activity of the users are just lightly active except for Mondays and Sundays. Mondays were found to peak in very active minutes in users while Sundays were more sedentary.

**Steps per Day of the Week:**

[Day with highest & very active steps]{.ul}: Saturday

[Day with lowest & slightly active steps:]{.ul} Sunday

[Rest of the week:]{.ul} Lightly Active Steps

**Lifestyle & Intensity of Steps per Day of the Week:**

-   On mondays where the users had the highest number of very active minutes, the steps intensity that peaked that day were that of lightly active steps.

-   Saturday: the most active steps with lightly active lifestyle overall

-   Sunday: slightly active steps with sedentary lifestyle overall

**Calories Burned per Day of the Week:**

[Day with highest calories burned:]{.ul} Saturday (Followed by Monday and Tuesday)

[Day with lowest calories burned:]{.ul} Sunday

-   For calories burned per day of the week, there was not a consistent pattern in the graph.

-   In connection with the lifestyle trend per day of the week, the peak on sedentary minutes from the lifestyle trend is consistent with the calories burned being the lowest on Sundays.

-   However, we see that the day with the highest calories burned is not exactly consistent with the peak in very active minutes. It was Monday that peaked the most number of very active minutes from the lifestyle trend, while it is Saturday that had most number of calories burned from the calories trend.

    -   Although it is not entirely consistent, Monday still came in second to Saturday in terms of calories burned per day. Monday was still high at 2232 and Saturday was at 2363.

**Calories Burned & Steps Intensity per Day of the Week:**

-   Saturday: highest calories burned and most are active steps

-   Sunday: lowest calories burned and most are slightly active steps only

-   Rest of the week: lightly active steps

**Minutes Asleep per Day of the Week:**

[Day with highest minutes & enough sleep]{.ul}: Sunday

[Day with lowest minutes & not enough sleep:]{.ul} Friday

# Users Percentage

```{r}
#Creating data frame for user lifestyle percentage

lifestyle_percentage <- per_user %>% add_column %>% 

  group_by (Lifestyle) %>% 

  summarise(total = n()) %>% 

  mutate(total_ = sum(total)) %>% 

  group_by(Lifestyle) %>% 

  summarise(lifestyle_percent = total/total_) 

#Creating data frame for user sleeping habits percentage

sleep_percentage <- per_user %>% add_column %>% 
  group_by(Sleep.S) %>% 
  summarise(total = n()) %>% 
  mutate(total_ = sum(total)) %>% 
  group_by(Sleep.S) %>% 
  summarise(sleep_percent = total/total_)

```

## **Visualization**

```{r}
#pie chart


lifestylepie <- ggplot(data=lifestyle_percentage,aes(x="",y=lifestyle_percent,fill=Lifestyle))+

  geom_col(color="black")+

  coord_polar("y",start= 0)+

  geom_text(aes(label=paste0(round(lifestyle_percent*100),

                            "%")), position = position_stack(vjust=0.5))+

              theme(panel.background = element_blank(),

                    axis.line = element_blank(),

                    axis.text = element_blank(),

                    axis.ticks = element_blank(),

                    axis.title = element_blank(), 

                    plot.title = element_text(hjust = 0.5, size = 12))+

              ggtitle("User Type Distribution")


##Ggplot sleeping habits

sleephabitspie <- ggplot(data=sleep_percentage, aes(x="",y=sleep_percent,fill=Sleep.S))+
  geom_col(color="black")+
  coord_polar("y",start = 0)+
  geom_text(aes(label=paste0(round(sleep_percent*100),

                            "%")), position = position_stack(vjust=0.5))+

              theme(panel.background = element_blank(),

                    axis.line = element_blank(),

                    axis.text = element_blank(),

                    axis.ticks = element_blank(),

                    axis.title = element_blank(), 

                    plot.title = element_text(hjust = 0.5, size = 12))+

              ggtitle("User's Sleeping Habits Distribution")

ggarrange(lifestylepie, sleephabitspie, hjust = -0.5, vjust = 1.5, font.label = list(size=14, color = "black", face = "bold", family = NULL), align = c("v"))

```

**User Lifestyle Type Distribution:**

Most of the users in the dataset have a lightly active lifestyle and the least percentage of users have a fairly active lifestyle. Those with very active lifestyle only comprise 21% of the overall users.

Lightly Active Users: 38%

Sedentary Users: 33%

Very Active: 21%

Fairly Active: 8%

**User Sleeping Habits Distribution:**

Most of the users get enough sleep

Enough Sleep: 54%

Not Enough Sleep: 46%

# Duration Smart Watches Worn

## Weekly Average

```{r}
#isolating
weekly_average <- DailyActivity_Sleep %>% 
  select(Id,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,TotalMinutesAsleep,TotalTimeInBed)

totalweekly_average <-weekly_average %>% 
  group_by(Id) %>% add_column %>% 
  mutate(minutes_worn_total = VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes+TotalMinutesAsleep+TotalTimeInBed)
head(totalweekly_average)

total_average <- totalweekly_average %>% group_by(Id) %>% summarise_at(vars(minutes_worn_total),list(sum))
head(total_average)

mean(total_average$minutes_worn_total)

```

**Results:**

The overall average smart watch of all users for the two months is: 31591.67 minutes

Dividing this by 8, at this rate, on an average, users wear their smart watches 3,948.96 minutes per week or 65 hours per week. In a day, users wear their smart watches for 9 hours.

------------------------------------------------------------------------

# Conclusion & Recommendations

## Trend in Smart Watch Usage

**Smart Watch Usage**

On average, users wear their smartwatches for 9 hours a day.

**Users' Lifestyle**

Although the distribution of users based on their lifestyle is not that varied, the greatest number of FitBit smartwatch users are light to sedentary users. Only 21% of the 24 participants are very active users.

The average total steps of the users are 8913 which can be classified as a fairly active number of steps and still fall along with the range of recommended number of steps daily.

**Users' Sleeping Habits**

In terms of sleeping habits, most of the users get enough sleeping hours as recommended, which is 420 minutes or 7hours.

**Calories Burned**

The users burn a median of 2207 calories per day.

**Relationships among Variables**

There are no significant relationships among the variables except for the time spent in bed and time asleep, which makes sense.

## Application to Bellabeat's Consumers

Bellabeat's products target audiences are adult, middle-aged, elderly, and pregnant women. Most women at this age have a hard time prioritizing their health and fitness because of various reasons ("Physical activity for women", 2016). It could be that they lack the time, motivation, or resources, or that they are just too busy with parenting and other responsibilities. However, we must keep in mind that these insights are not conclusive and needs to be counterchecked with an updated and more accurate study on women's lifestyle trend.

## Recommendations for Bellabeat

My recommendation for Bellabeat is to utilize **Bellabeat Coach and Bellabeat Time**. I based my insights on both the results of my analysis on FitBit users' consumption and the current trend in smart devices.

For an overview, I recommend that Bellabeat amplify and upgrade its branding of a **minimal, fashionable, and convenient health and fitness wearable**.

### For Bellabeat Time & Bellabeat App Features:

1.  **Increase incentives to encourage people to wear their smartwatches more**

Bellabeat can develop an incentive-scheme feature on the Bellabeat app in the form of a game or star-collection type to increase their smartwatch usage. For example, they can use a point-earning system for every week that they wear their smartwatches for more than 15 hours a day. This could be in the form of earning points to gain access to one of the programs in Bellabeat Coach or a discount coupon perhaps.

2.  **Encourage wearing Bellabeat Time during sleep time through notifications & reports**

Give message notifications like "We missed your sleep time last night, how was it?" every 3 days of not completing the sleep record. This is to not overwhelm the users but still gently remind them to keep track of their sleep records. Bellabeat app could also have scheduled postings of sleep habits facts in the form of notifications. Sleep habits facts could range from benefits of getting good hours of sleep, the harms of not sleeping enough, and tips on how to sleep better.

Apart from these, the Bellabeat app could also release a weekly report of the users' sleep records as a reminder.

3.  **Encourage users to move more by notifications and reports**

Notification of sedentary minutes and suggest ways to be more active using the application. Similar to encouraging users to keep track of their sleep records, Bellabeat could also do a weekly summary report.

4.  **Free sample marketing using Bellabeat Coach**

Alongside improving the notification and reporting feature of Bellabeat, they could also have a free and premium version of Bellabeat Coach. In the Bellabeat Coach free version - they could have short workout videos, meal-prep recipes, lifestyle lessons catered to women, etc. that would be linked to their smart devices. Workout routines and meal-prep recipes in the app should always have easier and quicker options for busy women or women who are just getting started with their fitness journey. For example, the Bellabeat Coach free version can have a feature that suggests workouts or content depending on the report that the app will gather on the users' smartwatch usage. While for the premium version, Bellabeat will give an extended and more elaborate service of the free version features. Some examples of this are having more varieties of health and fitness classes, one-on-one coaching, more personalized meal-prep planning, etc. By giving a trial or free version of Bellabeat Coach services, users will more likely avail their premium services because they have already tried and gauged the benefit of the program for them.

### For Bellabeat Time Re-branding

1.  **Invest in improving Bellabeat Time vital monitoring features**

The current market in smartwatches and wearable technology is getting more competitive as leading brands like Apple Smart Watches are incorporating more medical features into their watches. With the ongoing pandemic, having a smartwatch that can measure your oxygen saturation (SPO2) and an accurate heart rate tracker is efficient right now. Apple has quickly adapted to this and is continuously dominating the smartwatch scene.

Investing in more accurate and broader vital monitoring features could benefit the users more. Based on the analysis, users of FitBit smartwatch are more lightly active users, meaning to say, they are not athletes or regular gym-goers. With this, they could be using smartwatches as a tool to monitor their vitals, but a more extensive study is needed to confirm this insight.

2.  **Advertisement re-branding the whole smartwatch design trends**

-   Campaign on Minimal & Fashionable Health & Fitness Wearables

What makes Bellabeat unique from other smartwatch brands is its minimalistic and fashionable design made for women. With the rise of numerous smartwatch brands having the same tech look, Bellabeat could stand out by building its campaign towards minimalism and fashionability when it comes to health and fitness tracking.

-   Exploring Short Video Trends & Challenges on Social Media

Since Bellabeat has already been investing in digital and social media ads, I think it would be good for them to continue doing that. It might be more beneficial for them to take advantage of the rise of short videos, TikTok videos, trends, and challenges, Instagram posts, and stories to create this following on Bellabeat's minimal and fashionable fitness tracker wearables.

### For Future Data Analysis

-   Post-pandemic trend in women's health and fitness

-   Post-pandemic trend in active fashion

For future studies, Bellabeat could focus on the analysis of the trend in women's health and fitness. Specifically, they should study the changes the pandemic has brought when it comes to women's health and fitness. Bellabeat's sampling should also take into consideration women coming from different backgrounds -- different age groups, class, nature of the job, and consumer type. Apart from health and fitness, future business analyses could also look into current trends of active fashion to keep Bellabeat's features updated.

Overall, Bellabeat has a niched role to start with -- **"Health and fitness do not have to be boring, it can be fashionable and minimal with Bellabeat",** Bellabeat just has to continue growing to stay in the scene.

# References

Furberg, R., Brinton, J., Keating, M., & Ortiz, A. (2016). Crowd-sourced Fitbit datasets 03.12.2016-05.12.2016 [Data set]. Zenodo. [\<https://doi.org/10.5281/zenodo.53894>](https://doi.org/10.5281/zenodo.53894){.uri}

Perez,S. (2018, December 21). *Bellabeat's new hybrid smartwatch tracks your stress...and goes with your outfit*. TechCrunch. Retrieved from [\<https://techcrunch.com/2018/12/21/bellabeats-new-hybrid-smartwatch-tracks-your-stress-and-goes-with-your-outfit/>](https://techcrunch.com/2018/12/21/bellabeats-new-hybrid-smartwatch-tracks-your-stress-and-goes-with-your-outfit/){.uri}

Physical activity for women.(2016, June 30).Retrieved from <https://www.betterhealth.vic.gov.au/health/healthyliving/physical-activity-for-women>

Stenson, J. (2021, September 12). *How many steps a day should you take? Study finds 7,000 can go a long way.* NBC News. Retrieved from <https://www.nbcnews.com/health/health-news/how-many-steps-day-should-you-take-study-finds-7-n1278853>

