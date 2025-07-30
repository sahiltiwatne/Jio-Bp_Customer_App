# ⛽ Jio-BP Customer App

A full-featured Flutter mobile application developed during my internship at **Jio-BP (Reliance BP Mobility Ltd.)**, designed to digitize the fuel station experience for customers across India.

This app enables customers to book fuel slots, view real-time fuel prices, receive instant notifications, manage payments and refunds through an integrated wallet system, and much more — bringing convenience, speed, and transparency to fuel purchasing.

---

## 🏢 About Jio-bp

**Jio-bp** is a joint venture between **Reliance Industries Limited** and **bp (British Petroleum)** aimed at transforming India’s fuel and mobility landscape. The company is focused on redefining fuel retail with a tech-driven approach, offering high-quality fuels, advanced mobility services, and a digital-first experience for customers.

---

## 🌟 Key Features

| Feature | Description |
|--------|-------------|
| 🛢️ **Fuel Slot Booking** | Users can reserve a fuel refill slot at their preferred time and station, reducing wait time. |
| 🔐 **OTP-Based Authentication** | Secure login using phone number + OTP verification via Firebase. |
| 🗺️ **Station Locator** | View nearby Jio-bp stations on Google Maps with distance and directions. |
| 🏷️ **Real-Time Fuel Prices** | Daily updates of fuel rates (petrol, diesel) from stations. |
| 🔔 **Flutter Local Notifications** | Get notified for slot confirmations, reminders, offers, and cancellations. |
| 💳 **Digital Wallet Integration** | Users can pay for fuel bookings and receive refunds directly into the app wallet. |
| 💸 **Refunds on Cancelled Bookings** | Automatic refund process if a user cancels a booking. |
| 📜 **Transaction History** | Complete view of past fuel bookings, cancellations, and wallet usage. |
| 🌐 **Smooth UI/UX** | Responsive and intuitive Flutter UI with animations and seamless navigation. |

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Authentication**: Firebase OTP Auth
- **Backend**: Firebase Firestore (Database)
- **Notifications**: Flutter Local Notifications
- **Maps & Location**: Google Maps API
- **Payment & Wallet**: Simulated wallet logic (can be extended to real payments)
- **State Management**: Provider / SetState (as implemented)

---

## 📂 Project Structure (Simplified)

lib/
├── main.dart
├── screens/
│ ├── login_screen.dart
│ ├── home_screen.dart
│ ├── booking_screen.dart
│ ├── wallet_screen.dart
│ └── fuel_station_map.dart
├── services/
│ ├── auth_service.dart
│ ├── booking_service.dart
│ ├── notification_service.dart
│ └── wallet_service.dart
├── models/
│ └── booking_model.dart
├── widgets/
│ └── custom_button.dart
assets/
├── images/
pubspec.yaml


📸 Screenshots
![WhatsApp Image 2025-07-17 at 16 09 54_9d77ae12](https://github.com/user-attachments/assets/f8fe0592-7681-4ef0-90b1-332bf86defd3) Login Page
![WhatsApp Image 2025-07-17 at 16 09 53_dadbd82b](https://github.com/user-attachments/assets/5e2bc01c-9117-448c-9a6c-423dc9331488) Home Page
![WhatsApp Image 2025-07-17 at 16 09 53_0ec6f1ad](https://github.com/user-attachments/assets/55a3b4d2-8ff9-488a-a317-41d7fcd51070) Home Page
![WhatsApp Image 2025-07-17 at 16 09 53_9df0f607](https://github.com/user-attachments/assets/77302e7f-ef4a-46e6-865d-30876a56d586) Integrated InAppWebView
![WhatsApp Image 2025-07-17 at 16 09 52_cfc1a8d1](https://github.com/user-attachments/assets/78e5656c-5992-486f-8337-a88fecee15c7) Chatbox 
![WhatsApp Image 2025-07-17 at 16 09 52_22444703](https://github.com/user-attachments/assets/21d25d94-fd17-4f30-a0a5-5bf7730d0927)
![WhatsApp Image 2025-07-17 at 16 09 51_e8d242fd](https://github.com/user-attachments/assets/171db6bd-52c4-4838-b7db-fbbef17dcae2)
![WhatsApp Image 2025-07-17 at 16 09 51_487b8b20](https://github.com/user-attachments/assets/a44b6cf3-bc61-4a68-90c5-23c2a206342f) wallet
![WhatsApp Image 2025-07-17 at 16 09 51_2c091536](https://github.com/user-attachments/assets/713f1b0f-db38-4ff9-aa83-9f990b156a40) Settings Page
![WhatsApp Image 2025-07-17 at 16 09 50_de11fc67](https://github.com/user-attachments/assets/e590d1d7-afcb-46c6-8e91-31dc1d1f014f)  Profile Page
![WhatsApp Image 2025-07-17 at 16 09 50_c48fe4ce](https://github.com/user-attachments/assets/4a181599-7e50-4116-9ce4-de64b4d48b6d) Integrated Google APIs
![WhatsApp Image 2025-07-17 at 16 09 50_deb170d2](https://github.com/user-attachments/assets/43e144f0-a732-412f-ba9b-30fa2cdd632f) Amenities Screen
![WhatsApp Image 2025-07-31 at 01 17 23_5d78d846](https://github.com/user-attachments/assets/c4188c4e-25d4-44c2-96b5-6f5804a6e851) Booking Screen
![WhatsApp Image 2025-07-31 at 01 17 23_3442d5a2](https://github.com/user-attachments/assets/cdce2c7c-0ae2-4c8b-aef7-37af07b7e681) Booking Screen
![WhatsApp Image 2025-07-31 at 01 17 23_0a074555](https://github.com/user-attachments/assets/fa015f89-92a3-4590-a643-52607598c8d6) Order Summary
![WhatsApp Image 2025-07-31 at 01 17 24_499f7f41](https://github.com/user-attachments/assets/c3db98e2-6823-40f1-9602-4dd475ffee89) Payment Successfull Message with Notification
![WhatsApp Image 2025-07-31 at 01 17 24_ca764aa3](https://github.com/user-attachments/assets/f6fbb2be-4114-4fe3-9f9f-c17ca65645dd) Notification
![WhatsApp Image 2025-07-31 at 01 17 24_3c730b64](https://github.com/user-attachments/assets/ae9b350b-5a17-46e5-81e2-7db3a8b5aba6) My Bookings Page
![WhatsApp Image 2025-07-31 at 01 17 25_fa5e2449](https://github.com/user-attachments/assets/c7ef0f23-d12a-49ce-bed1-283f9d1607f8) Transaction History Page
![WhatsApp Image 2025-07-31 at 01 17 25_8354bc06](https://github.com/user-attachments/assets/6e5da95f-2d25-4db7-b85b-dd841878e0bc) Bookings and Trasactions can be seen in Chatbox also
![WhatsApp Image 2025-07-31 at 01 17 25_392a90a6](https://github.com/user-attachments/assets/11cff668-930e-47a0-9cc2-e520ffbac586) Booking cancellation with Notification
![WhatsApp Image 2025-07-31 at 01 17 26_9dc0919b](https://github.com/user-attachments/assets/73e206c2-218e-4d7a-9ad9-eb9c889aeff6) Refund Notification
![WhatsApp Image 2025-07-31 at 01 17 26_0a68738e](https://github.com/user-attachments/assets/bf6f5636-501b-4e44-ad2e-123b9649615e) Transaction history with Refunded amount
![WhatsApp Image 2025-07-31 at 01 17 26_1f166945](https://github.com/user-attachments/assets/b3e1cfb3-2e02-4432-9b77-38666f95bb89) Session Reminder notification , before 5 minutes of auto logout



## 🚀 Getting Started

### ✅ Prerequisites

- Flutter SDK (>= 3.0)
- Android Studio / VS Code
- Firebase Project Setup
- Google Maps API Key

### 🧪 Installation

```bash
git clone https://github.com/sahiltiwatne/Jio-Bp_Customer_App.git
cd Jio-Bp_Customer_App
flutter pub get

▶️ Run the App
flutter run

📸 Screenshots




