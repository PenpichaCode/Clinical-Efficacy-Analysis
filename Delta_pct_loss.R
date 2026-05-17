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