install.packages(c("gtsummary", "flextable", "gt"))
library(dplyr)
library(tidyverse)
library(ggplot2)
library(gtsummary)
library(flextable)
library(gt)

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

## Descriptive Statistics (Mean ± SD)
# ANALYSIS 1: TABLE 1 — BASELINE CHARACTERISTICS
## base R
# คำนวณ Mean และ SD แยกกันแล้วค่อยนำมาต่อกัน
means <- aggregate(cbind(hb_a1c, weight_kg, ldl, bmi) ~ group + visit, data = df_clean, FUN = mean)
sds <- aggregate(cbind(hb_a1c, weight_kg, ldl, bmi) ~ group + visit, data = df_clean, FUN = sd)

print(means)
print(sds)

## ใช้ library ที่ีให้สะดวกมาก
tb_baseline <- df_clean %>% 
  filter(visit == "Baseline") %>% 
  select(id, group, age, gender, weight_kg, body_fat_pct, lean_kg, bmr,
         hb_a1c, ldl, bmi)

tb1 <- tb_baseline %>% 
  select(-id) %>% 
  tbl_summary(
    by = group,
    label = list(
      age ~ "Age (years)",
      weight_kg ~ "Weight (kg)",
      hb_a1c ~ "HbA1C (%)",
      ldl ~ "LDL (mg/dl)",
      body_fat_pct ~ "% Body Fat",
      lean_kg ~ "Muscle Lean (kg)",
      bmr ~ "BMR",
      bmi ~ "BMI (kg/m2)"
    ), statistic = list(
      all_continuous()  ~ "{mean} ({sd})", # show mean
      all_categorical() ~ "{n} ({p}%)" # show N (%)
    ),
    digits    = list(all_continuous() ~ 1),
    missing   = "no"
  ) %>% 
  ## เพิ่มส่วนของ p -value
  add_p(
    test = list(
      all_continuous()  ~ "t.test",
      all_categorical() ~ "chisq.test"
    )
  )  %>% 
  ## add column Overall
  add_overall()  %>% 
  modify_header(label = "**Variable**") %>% 
  modify_spanning_header(c("stat_1","stat_2") ~ "**group**") %>% 
  bold_labels()

print(tb1)

