install.packages(c("gtsummary", "flextable", "gt"))
library(dplyr)
library(tidyverse)
library(ggplot2)
library(gtsummary)
library(flextable)
library(gt)
library(patchwork)

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

##  Delta change (trending)
# 101 Rename Months
df_prepared <- df_clean %>%
  mutate(visit_clean = case_when(
    visit == "Baseline"  ~ "M00",
    visit == "Day 90"     ~ "M03",
    visit == "6 Months"  ~ "M06",
    visit == "9 Months"  ~ "M09",
    visit == "12 Months" ~ "M12",
    TRUE ~ visit
  ))
# ตรวจสอบว่าถูกเปลี่ยนครบหมดไหม
table(df_prepared$visit_clean, df_prepared$group)

delta_pct <- df_prepared %>% 
  filter(visit_clean %in% c("M00",
                            "M03",
                            "M06",
                            "M09",
                            "M12")) %>% 
  select(id, group, visit_clean, age, gender, weight_kg, body_fat_pct, lean_kg, bmr, hb_a1c, ldl, bmi) %>% 
  pivot_wider(names_from = visit_clean, 
              values_from = c(weight_kg, body_fat_pct, 
                              lean_kg, bmr, hb_a1c, ldl, 
                              bmi)) %>% 
  # คำนวณ % Change: ((Final - Initial) / Initial) * 100
  mutate(
    across(
      .cols = ends_with("_M03") | ends_with("_M06") | 
        ends_with("_M09") | ends_with("_M12"),
      .fns = ~ . - get(str_replace(cur_column(), "_(M03|M06|M09|M12)$", "_M00")),
      .names = "delta_{.col}"
    )
  )

# plot graph trajectory
plot_trajectory_pct <- function(var, ylab) {
  
  # 1. คำนวณ % change โดยการใช้สูตรดึงค่าแรก (M00) ของแต่ละ id
  df_pct <- df_prepared %>% 
    filter(visit_clean %in% c("M00", "M03", "M06", "M09", "M12")) %>% 
    group_by(id, group) %>% 
    arrange(visit_clean) %>% 
    mutate(
      baseline_val = first(.data[[var]]), ## .data[[var]] = df_prepared$var
      # ใช้สูตรปกติคำนวณ โดยเดือน M00 
      pct_change = ((.data[[var]] - baseline_val) / baseline_val) * 100
    ) %>%
    ungroup()
  
  # 2. สรุปข้อมูลเป็น Group Mean ± SE
  sum_pct <- df_pct %>%
    group_by(visit_clean, group) %>%
    summarise(
      ymean = mean(pct_change, na.rm = TRUE),
      yse   = sd(pct_change, na.rm = TRUE) / sqrt(n()),
      .groups = "drop"
    )
  
  # 3. สร้างกราฟ
  ggplot(sum_pct, aes(x = visit_clean, y = ymean, color = group, group = group)) +
    # เส้นอ้างอิงที่ 0% (Baseline)
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    
    # เส้น Trajectory และ Error Bars
    geom_line(size = 1.2) +
    geom_errorbar(aes(ymin = ymean - yse, ymax = ymean + yse), width = 0.15) +
    geom_point(size = 3, shape = 21, fill = "white", stroke = 1.5) +
    
    # ปรับแต่งแกนและ Label ให้ตรงกับข้อมูลจริง
    scale_color_manual(values = c("Supplement" = "blue", "Control" = "#CD5C5C")) +
    scale_x_discrete(labels = c("M00" = "Baseline", 
                                "M03" = "3 Months", 
                                "M06" = "6 Months", 
                                "M09" = "9 Months", 
                                "M12" = "12 Months")) +
    labs(
      title = paste("% Change Trajectory:", ylab),
      subtitle = "Calculated systematically from Day 0 | Mean ± SE",
      x = "Timeline",
      y = "% Change from Baseline",
      color = "Study Group"
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
}

# วาดกราฟ % Change ของ LDL
names(df_clean)
plot_trajectory_pct(var = "hb_a1c", ylab = "HbA1C %")


## วาดกราฟโดยใช้ library(patchwork)
## สร้างกราฟหลายตัวแปร
params <- list(
  list(var = "weight_kg", ylab = "Weight Loss (kg)"),
  list(var = "body_fat_pct", ylab = "BodyFat (%)"),
  list(var = "lean_kg", ylab = "Muscle Lean (kg)"),
  list(var = "bmr", ylab = "BMR"),
  list(var = "hb_a1c", ylab = "HbA1C"),
  list(var = "ldl", ylab = "Low-density Lipoprotein (LDL)"),
  list(var = "bmi", ylab = "BMI (kg/m2)")
)

plots <- lapply(params, function(p) {
  plot_trajectory_pct(p$var, p$ylab)
})

wrap_plots(plots, ncol = 2) +
  plot_annotation(
    title    = "% Change Trajectory — All Parameters",
    subtitle = "Mean ± SE | Supplement vs Control",
    theme    = theme(plot.title = element_text(size = 16, face = "bold"))
  )

wrap_plots(plots, ncol = 2) + ## 2 column
  plot_layout(guides = "collect") + # auto , keep, collect
  plot_annotation(title = "% Change Trajectory — All Parameters") &
  theme(legend.position = "bottom")

