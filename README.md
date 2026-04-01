# Metabolic-Insight: Analyzing Clinical Efficacy of Dietary Interventions

---
Dataset Description
ชุดข้อมูลนี้เป็นข้อมูลการติดตามผลเชิงคลินิก (Clinical Observation Data) จากกลุ่มตัวอย่างอาสาสมัครจำนวน 70 ราย ที่เข้าร่วมโปรแกรมทดสอบผลิตภัณฑ์เสริมอาหาร เพื่อศึกษาความสัมพันธ์และการเปลี่ยนแปลงของตัวชี้วัดทางสุขภาพใน 2 มิติหลัก

### 1. Data Scope & Structure 🧠
ข้อมูลถูกจัดเก็บแบบ Longitudinal Data (มีการเก็บข้อมูลหลายจุดเวลา เช่น Before & After) 
โดยแบ่งหมวดหมู่ข้อมูลออกเป็น:
- **Demographic Data:** ข้อมูลพื้นฐาน เช่น อายุ และเพศ
- **Body Composition Metrics:** ค่าองค์ประกอบร่างกายที่วัดด้วยเครื่องมือเฉพาะทาง เช่น Body Fat Percentage (%),Skeletal Muscle Mass (kg), Visceral Fat Level

- **Blood Chemistry Profiles:** ค่าผลแล็บทางเคมีในเลือด เช่น Lipid Profile (Cholesterol, HDL, LDL, Triglycerides),Blood Glucose Levels

###  2. Data Preparation & Cleaning 🛠️
เพื่อให้ข้อมูลพร้อมสำหรับการวิเคราะห์เชิงสถิติและการสร้างโมเดล AI:
- Outlier Detection: ตรวจสอบค่าเคมีในเลือดที่ผิดปกติ (Physiological Outliers) เพื่อแยกแยะระหว่างค่าที่คลาดเคลื่อนจากการเก็บข้อมูล กับค่าที่ผิดปกติในเชิงพยาธิสภาพ
- Normalizing Data: มีการทำ Feature Scaling สำหรับค่าเคมีในเลือดที่มีหน่วยวัดและช่วงตัวเลข (Range) ที่แตกต่างกันมาก
- Handling Missing Values: จัดการข้อมูลที่ขาดหายไปจากอาสาสมัครที่อาจไม่ได้มาตรวจตามนัด (Drop-out analysis)

### 3. Privacy & Compliance
De-identification: ข้อมูลทั้งหมดผ่านกระบวนการถอดชื่อ-นามสกุล และรหัสประจำตัวโรงพยาบาลออก เพื่อให้เป็นไปตามมาตรฐาน PDPA และจรรยาบรรณวิชาชีพ
Research Ethics: ข้อมูลนี้ถูกนำมาใช้เพื่อวัตถุประสงค์ในการแสดงทักษะการวิเคราะห์ (Portfolio) โดยมีการปรับเปลี่ยนค่าตัวเลขบางส่วน (Data Masking) เพื่อรักษาความลับของแหล่งทุนวิจัยและสูตรผลิตภัณฑ์
