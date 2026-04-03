library(dplyr)
library(tidyverse)

df <- read.csv("/Users/penpicha/p2-progress-apr/Clinical/metabolic_insight_n200_full.csv")

# 1. check data structure
str(df)
names(df)
# 2. ตรวจสอบจำนวนค่าว่าง (NA) ในแต่ละคอลัมน์
colSums(is.na(df))

# change <chr> to factor
data <- data %>% 
  mutate(visit = factor(visit, 
                        levels = c("Baseline", 
                                   "Day 30", "Day 60", 
                                   "Day 90", "6 Months", 
                                   "9 Months", "12 Months")))

# แล้วลองเช็คอีกรอบ
levels(data$visit)

