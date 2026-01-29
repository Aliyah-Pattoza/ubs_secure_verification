# ubs_secure_verification

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# UBS Gold Secure Verification App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

A secure mobile application for transaction approval with multi-layer authentication including Face Recognition and VPN encryption.

## 📱 Overview

UBS Gold Secure Verification App adalah aplikasi mobile yang dirancang khusus untuk memberikan keamanan maksimal dalam proses verifikasi dan persetujuan transaksi keuangan. Aplikasi ini menggunakan teknologi Face Recognition dan koneksi VPN untuk memastikan setiap transaksi diverifikasi oleh pihak yang berwenang.

## ✨ Key Features

- 🔐 **3-Layer Security Authentication**
  - IMEI Device Verification
  - Password Authentication
  - Face Recognition (Biometric)
- 🔒 **VPN Encryption** - WireGuard protocol untuk komunikasi data yang aman
- 📊 **Real-time Transaction Management** - Approve/Reject transaksi dari mana saja
- 📱 **Cross-Platform** - Support Android & iOS
- 🎯 **User-Friendly Interface** - Clean dan intuitif design
- 📝 **Complete Audit Trail** - Semua aktivitas tercatat dengan timestamp

## 🏗️ Architecture

```
Mobile App (Flutter)
    ↓
VPN Server (WireGuard/MikroTik)
    ↓
Backend APIs (LAN)
    ├── Face Recognition API
    ├── Transaction Service
    └── Auth Service
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 2.19+
- Android Studio / Xcode
- Device dengan kamera untuk Face Recognition

### Installation

1. Clone repository
```bash
git clone https://github.com/your-org/ubs_secure_verification.git
cd ubs_secure_verification
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure API endpoints di `lib/config/api_config.dart`
```dart
class ApiConfig {
  static const String baseUrl = 'http://your-api-url';
  static const String faceRecognitionUrl = 'http://your-fr-api-url';
  static const String vpnServerUrl = 'your-vpn-server';
}
```

4. Run the app
```bash
flutter run
```

## 📦 Dependencies

Key packages used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  face_camera: ^0.1.4          # Face Recognition camera
  provider: ^6.0.0             # State management
  http: ^1.0.0                 # HTTP requests
  shared_preferences: ^2.0.0   # Local storage
  device_info_plus: ^9.0.0     # Device IMEI info
```

## 🔧 Configuration

### 1. IMEI Registration
Setiap device yang akan menggunakan aplikasi harus didaftarkan IMEI-nya ke sistem:
```
Admin Panel → Device Management → Register New Device
```

### 2. VPN Configuration
WireGuard client akan otomatis terkonfigurasi saat login pertama kali. Pastikan VPN server sudah running.

### 3. Face Recognition Setup
- API endpoint harus dikonfigurasi di `api_config.dart`
- Minimal resolusi kamera: 720p
- Format response API: JSON

## 📱 User Flow

1. **Splash Screen** → Loading & sistem check
2. **Login** → User ID + Password + IMEI verification
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

## 🔒 Security Features

- **IMEI-based Device Lock** - Mencegah akses dari device tidak terdaftar
- **Encrypted Communication** - Semua data melewati VPN tunnel
- **JWT Authentication** - Token-based session management
- **Face Recognition** - Biometric verification untuk transaksi critical
- **Audit Logging** - Complete trail semua aktivitas user

## 📸 Screenshots

| Splash Screen | Login | Face Verification |
|--------------|-------|-------------------|
| ![Splash](screenshots/splash.png) | ![Login](screenshots/login.png) | ![Face](screenshots/face_verify.png) |

| Transaction List | Approval | Success |
|-----------------|----------|---------|
| ![List](screenshots/transaction_list.png) | ![Approve](screenshots/approve.png) | ![Success](screenshots/success.png) |

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test
```

## 📝 API Documentation

### Authentication
```http
POST /api/auth/login
Content-Type: application/json

{
  "user_id": "string",
  "password": "string",
  "device_imei": "string"
}
```

### Face Recognition
```http
POST /api/face/verify
Content-Type: application/json

{
  "user_id": "string",
  "face_data": "base64_string"
}
```

### Transaction Management
```http
GET /api/transactions/pending
Authorization: Bearer {token}

POST /api/transactions/{id}/approve
POST /api/transactions/{id}/reject
```

## 🚦 Project Status

- ✅ Phase 1: POC Development (Completed)
- 🔄 Phase 2: Internal Testing (In Progress)
- ⏳ Phase 3: UAT & Refinement (Planned)
- ⏳ Phase 4: Production Deployment (Planned)

## 👥 Team

- **Development Team**: UBS Gold IT Department
- **Security Advisor**: [Name]
- **Project Manager**: [Name]

## 📄 License

This project is proprietary software owned by UBS Gold. Unauthorized copying, distribution, or use is strictly prohibited.

## 📞 Support

Untuk support dan pertanyaan:
- **Email**: support@ubsgold.com
- **Phone**: +62 31 XXXX XXXX
- **Website**: https://ubsgold.com

## 🙏 Acknowledgments

- Flutter Team untuk framework yang powerful
- WireGuard untuk VPN protocol
- Face Recognition API provider

---

**© 2026 UBS Gold. All Rights Reserved.**

*Trust in Gold*
