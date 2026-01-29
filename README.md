
## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 2.19+
- Android Studio / Xcode
- Device dengan kamera untuk Face Recognition

### Installation
1. Clone repository ini
2. Install dependencies: `flutter pub get`
3. Run aplikasi: `flutter run`

## 🔧 Configuration

### 1. DeviceID Registration
Setiap device yang akan menggunakan aplikasi harus didaftarkan DeviceID-nya ke sistem.

### 2. VPN Configuration
WireGuard client akan otomatis terkonfigurasi saat login pertama kali. Pastikan VPN server sudah running.

### 3. Face Recognition Setup
- API endpoint harus dikonfigurasi di `api_config.dart`
- Minimal resolusi kamera: 720p
- Format response API: JSON

## 📱 User Flow

1. **Splash Screen** → Loading & sistem check
2. **Login** → User ID + Password + DeviceID verification
3. **Face Verification** → Biometric authentication
4. **Dashboard** → View pending transactions
5. **Action** → Accept/Reject transaction
6. **Re-verification** → Face recognition untuk konfirmasi
7. **Submit** → Process approval/rejection

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Frontend** | Flutter (Dart) |
| **State Management** | Provider |
| **Face Recognition** | face_camera package + Custom API |
| **Security** | WireGuard VPN, JWT, AES-256 |
| **Backend** | Node.js / Python (RESTful API) |
| **Database** | PostgreSQL / MySQL |
| **VPN Server** | MikroTik |

## 📸 Screenshots

| Splash Screen | Login | Face Verification |
|--------------|-------|-------------------|
| ![Splash](screenshots/splash.png) | ![Login](screenshots/login.png) | ![Face](screenshots/face_verify.png) |

| Transaction List | Approval | Success |
|-----------------|----------|---------|
| ![List](screenshots/transaction_list.png) | ![Approve](screenshots/approve.png) | ![Success](screenshots/success.png) |

## 🚦 Project Status

- ✅ Phase 1: POC Development (Completed)
- 🔄 Phase 2: Internal Testing (In Progress)
- ⏳ Phase 3: UAT & Refinement (Planned)
- ⏳ Phase 4: Production Deployment (Planned)

## 👥 Team

- **Development Team**: [Lathifah Sahda] & [Andi Aliyah Nur Inayah]
- **Security Advisor**: [Name]
- **Project Manager**: [Name]

## 📄 License

This project is proprietary software owned by UBS Gold. Unauthorized copying, distribution, or use is strictly prohibited.

**© 2026 UBS Gold. All Rights Reserved.**

*Trust in Gold*

---

# ubs_secure_verification

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
