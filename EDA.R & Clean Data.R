library(dplyr)
library(tidyverse)
library(ggplot2)

df <- read.csv("/Users/penpicha/Desktop/2026comingUp/WebPortfolio2025-2026/Projects_practics/Clinical_project_practics/metabolic_study_n200.csv")

# 1. check data structure
glimpse(df)
names(df)
# 2. ตรวจสอบจำนวนค่าว่าง (NA) ในแต่ละคอลัมน์
colSums(is.na(df))

# 2. Imputation NA 
df_clean <- df %>% 
  # Convert to Factors
  mutate(across(c(group, visit, gender), as.factor)
) %>% 
  # Imputation แยกตามกลุ่ม (Group) และช่วงเวลา (Visit)
  group_by(group, visit) %>% 
  mutate(
  weight_kg = ifelse(is.na(weight_kg), 
                     mean(weight_kg, na.rm = TRUE), weight_kg),
  hb_a1c = ifelse(is.na(hb_a1c),
                  mean(hb_a1c, na.rm = TRUE), hb_a1c)
) %>% 
  ungroup() %>% 
  
  # BMI calculated
  mutate(
    bmi = weight_kg / (height_cm / 100)**2
  )
# Check NulL again !
colSums(is.na(df_clean))

# Check Normalization base R
hist(df_clean$bmi,
     main = "Normol Dist of BMI",
     xlab = "kb/m2") 

# Check with ggplot
ggplot(df_clean, aes(x = hb_a1c, fill = group)) +
  geom_density(alpha = 0.25) +
  theme_minimal()

# outline
boxplot(hb_a1c ~ group, data = df_clean)

## Advance Distribution with group
df_clean %>% 
  ggplot(aes(x = hb_a1c, fill = group)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~visit) +
  theme_minimal()

ggplot(df_clean, aes(x = hb_a1c, fill = group)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~visit) + 
  theme_light() +
  labs(title = "HbA1c Distribution Split by Visit")







