## Descriptive Statistics (Mean ± SD)
# ANALYSIS 1: TABLE 1 — BASELINE CHARACTERISTICS
install.packages(c("gtsummary", "flextable", "gt"))
library(gtsummary)
library(flextable)
library(gt)

## base r
# คำนวณ Mean และ SD แยกกันแล้วค่อยนำมาต่อกัน
means <- aggregate(cbind(hb_a1c, weight_kg, ldl, bmi) ~ group + visit, data = df_clean, FUN = mean)
sds <- aggregate(cbind(hb_a1c, weight_kg, ldl, bmi) ~ group + visit, data = df_clean, FUN = sd)

print(means)
print(sds)

names(df_clean)

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
  

