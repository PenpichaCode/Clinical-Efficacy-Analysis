library(patchwork)
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





