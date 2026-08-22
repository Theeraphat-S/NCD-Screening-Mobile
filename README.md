# NCD Screening Mobile Application (รพ.สต.แม่อาย)

> **โมบายแอปพลิเคชันสำหรับการคัดกรองความเสี่ยงของผู้ป่วย 4 โรคไม่ติดต่อเรื้อรัง**  
> มินิโปรเจกต์ สาขาวิชาเทคโนโลยีสารสนเทศ คณะวิทยาศาสตร์ มหาวิทยาลัยแม่โจ้  
> **ผู้พัฒนา**: นาย ธีรภัทร ศรีมณฑา (6504106360) | **อาจารย์ที่ปรึกษา**: อ.ดร.จักรกฤช เตโช

---

## 📌 บทนำและภาพรวมโครงงาน (Overview)

แอปพลิเคชันคัดกรองความเสี่ยง 4 โรคไม่ติดต่อเรื้อรัง (NCDs) พัฒนาขึ้นเพื่อเป็นเครื่องมือสนับสนุนการทำงานเชิงรุกของ **รพ.สต.แม่อาย จ.เชียงใหม่** ช่วยให้อาสาสมัครสาธารณสุขประจำหมู่บ้าน (อสม.) และพยาบาลวิชาชีพสามารถเก็บข้อมูลสุขภาพ ตรวจคัดกรองสัญญาณชีพ ประเมินความเสี่ยง 4 โรคสำคัญได้แบบ Real-time พร้อมทั้งให้ประชาชนสามารถเข้าดูประวัติและผลการประเมินสุขภาพของตนเองได้อย่างสะดวก

### 4 กลุ่มโรคไม่ติดต่อเรื้อรังที่คัดกรอง:
1. 🩺 **โรคเบาหวาน (Diabetes Mellitus)** — ประเมินจากระดับน้ำตาลในเลือด (FBS) และประวัติสุขภาพ
2. 🫀 **โรคความดันโลหิตสูง (Hypertension)** — ประเมินจากความดันตัวบน (SBP) และตัวล่าง (DBP)
3. 🏃‍♂️ **โรคอ้วนลงพุง (Metabolic Syndrome / Obesity)** — ประเมินจากดัชนีมวลกาย (BMI) และรอบเอวแยกตามเพศ
4. ❤️ **โรคหลอดเลือดหัวใจ (Cardiovascular Disease - CVD)** — ประเมินจากคะแนนความเสี่ยงสะสมร่วมและประวัติครอบครัว

---

## 👥 ผู้ใช้งานระบบ (Actors) & ฟังก์ชันการทำงาน (21 Use Cases)

ระบบออกแบบตามข้อกำหนดเอกสาร SRS ครอบคลุม **3 กลุ่มผู้ใช้งาน (Roles)**:

### 1. 👤 ผู้ป่วย / ประชาชนทั่วไป (Patient)
- **Login Patient**: เข้าสู่ระบบด้วยเลขบัตรประจำตัวประชาชน 13 หลัก
- **List Physical & Screening History**: ดูรายการประวัติการตรวจคัดกรองสุขภาพย้อนหลัง
- **View Physical & Screening Details**: ดูรายละเอียดผลการตรวจ สัญญาณชีพ และผลประเมินความเสี่ยง 4 โรค พร้อมสถานะการรับรองจากพยาบาล

### 2. 🤝 อาสาสมัครสาธารณสุขประจำหมู่บ้าน (VHV / อสม.)
- **Login VHV**: เข้าสู่ระบบด้วยเลขบัตรประชาชน / เบอร์โทรศัพท์ และรหัสผ่าน
- **List Patient**: ดูรายชื่อผู้ป่วยทั้งหมดในหมู่บ้านที่รับผิดชอบ
- **Search Patient**: ค้นหาผู้ป่วยด้วยเลขบัตรประชาชน 13 หลัก
- **Add Patient**: เพิ่มข้อมูลผู้ป่วยใหม่ พร้อมแนบรูปถ่ายและคำนวณอายุอัตโนมัติ
- **Edit Patient**: แก้ไขข้อมูลประจำตัวผู้ป่วย
- **Delete Patient**: ลบข้อมูลผู้ป่วย พร้อมระบบยืนยันความปลอดภัยก่อนลบ
- **View Patient Detail**: ดูประวัติและข้อมูลส่วนบุคคลของผู้ป่วย
- **Add Disease Screening Form**: กรอกแบบฟอร์มคัดกรอง 2 ตอน (สัญญาณชีพ + ประวัติการแพ้/ครอบครัว)
- **View Risk Assessment**: ดูผลวิเคราะห์ความเสี่ยง 4 โรคทันทีหลังบันทึกข้อมูล

### 3. 👩‍⚕️ พยาบาลวิชาชีพ (Nurse)
- **Login Nurse**: เข้าสู่ระบบด้วยรหัสพยาบาล (Nurse ID) และรหัสผ่าน
- **List Village**: ดูรายการหมู่บ้านทั้งหมดในความรับผิดชอบ (หมู่ 1 - หมู่ 5 รพ.สต.แม่อาย)
- **List VHV by Village**: ดูรายชื่อ อสม. แยกรายหมู่บ้าน
- **Add VHV / Edit VHV / View VHV Detail**: เพิ่ม แก้ไข และดูข้อมูล อสม. พร้อมมอบหมายพื้นที่
- **List Patient by Village**: ดูรายชื่อผู้ป่วยและประวัติคัดกรองแยกตามหมู่บ้าน
- **View Risk Assessment**: ตรวจสอบรายละเอียดผลการคัดกรองสุขภาพ
- **Approve Risk Assessment**: รับรองผลการประเมิน หรือปรับแก้ไขระดับความเสี่ยง 4 โรคพร้อมยืนยันความถูกต้อง

---

## 🏗️ สถาปัตยกรรมระบบ (System Architecture)

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK ^3.10)
- **Architecture Pattern**: Clean Architecture / Feature-Driven Design
- **State Management**: BLoC Pattern (`flutter_bloc`)
- **Dependency Injection**: Service Locator (`get_it`)
- **Data Source**: Offline-First Repository Pattern พร้อม Mock Data Seed ครบชุดสำหรับ Demo และพร้อมขยายสู่ RESTful API Backend
- **Calculation Engine**: Pure Dart Domain Service (`NcdRiskCalculator`) คำนวณความเสี่ยง Real-time ตามเกณฑ์มาตรฐานกรมควบคุมโรค/กระทรวงสาธารณสุข

---

## 🚀 เริ่มต้นใช้งาน (Getting Started)

### ความต้องการของระบบ:
- Flutter SDK 3.10.8 หรือสูงกว่า
- Android Studio / VS Code / Xcode (สำหรับ iOS)

### 1. ติดตั้ง Dependencies
```bash
flutter pub get
```

### 2. รันแอปพลิเคชัน
```bash
flutter run
```

### 3. รันการทดสอบ (Automated Test Suite)
```bash
flutter test
```
*(ผ่านการทดสอบ 100% ครบ 57 Test Cases ทั้ง Unit Tests, BLoC Tests และ Widget Tests)*

---

## 🔑 ข้อมูลสำหรับทดสอบเข้าใช้งาน (Demo Credentials)

| Role | Identifier / User ID | Password |
|---|---|---|
| **ผู้ป่วย (Patient)** | `1234567890123` | *(ไม่ต้องใช้)* |
| **อสม. (VHV)** | `1111111111111` | `password123` |
| **พยาบาล (Nurse)** | `NUR001` | `password123` |

---

## 📁 โครงสร้างโปรเจกต์ (Project Directory Structure)

```
lib/
├── config/              # Environment & App Configuration
├── domain/              # Domain Layer
│   ├── models/          # NCD Models (Patient, VHV, Nurse, Screening, Village, etc.)
│   ├── repositories/    # NCD Repository Interface & Mock Implementation
│   └── services/        # NCD Risk Calculation Engine (NcdRiskCalculator)
├── feature/             # Feature Modules
│   ├── auth/            # Role Selection & Login Pages + AuthBloc
│   ├── patient/         # Patient Management, History & PatientBloc
│   ├── screening/       # Screening Form (Part 1 & 2), Risk Views & ScreeningBloc
│   ├── vhv/             # VHV Management & VhvBloc
│   └── nurse/           # Village Overview, VHV Admin & Nurse Approval Flow
├── shared/              # Reusable UI tokens, styles, components
└── main.dart            # MultiBlocProvider & Application Root
```

---

## 📄 เอกสารอ้างอิงและบันทึกการตัดสินใจ
- [CONTEXT.md](CONTEXT.md): พจนานุกรมคำศัพท์และนิยามเชิงโดเมน (Glossary)
- [ADR 0001: Offline-First Repository](docs/adr/0001-offline-mock-repository-architecture.md)
- [ADR 0002: Client-Side NCD Risk Engine](docs/adr/0002-client-side-ncd-risk-calculator.md)
