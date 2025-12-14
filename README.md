# Simple Messenger Pro 🚀

A professional real-time messenger application built with **Flutter** and **Supabase**, following strict **Clean Architecture** principles.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=flat&logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean-green)
![State](https://img.shields.io/badge/State-Provider-orange)
![Backend](https://img.shields.io/badge/Backend-Supabase-green?style=flat&logo=supabase)

## ✨ Features

* **Authentication**: Email/Password Sign Up & Sign In (Supabase Auth).
* **Real-time Chat**: Instant messaging powered by Supabase Realtime (WebSockets).
* **Multimedia**: Send and receive images (Supabase Storage).
* **Performance**:
    * Image Caching (`cached_network_image`).
    * Optimistic UI updates.
    * Message Throttling.
    * Optimized SQL Queries & Indexing.
* **UX Enhancements**:
    * "Typing..." indicators (Realtime Broadcast).
    * Read Receipts (Double ticks ✅✅).
    * Message Deletion (Long press).
    * User Profiles with Avatars.
* **Architecture**: Fully separated Data, Domain, and Presentation layers using `GetIt` for Dependency Injection.

## 📱 Screenshots

| Chat List | Real-time Chat | Profile & Settings |
|:---------:|:--------------:|:------------------:|
| ![Screenshot_20251214-232105](https://github.com/user-attachments/assets/64fdcf11-48a9-4fef-81db-b5e22f4b980b) | ![Screenshot_20251214-232109](https://github.com/user-attachments/assets/c65953be-a132-4d73-989a-a1559c1e77f2) | ![Screenshot_20251214-232113](https://github.com/user-attachments/assets/38e8786c-793d-4270-8ddc-a0db3b82d9a6) |

*(Замени URL_TO_YOUR_SCREENSHOT на ссылки на твои картинки)*

## 🛠 Tech Stack

* **Framework**: Flutter
* **Language**: Dart
* **State Management**: Provider (ChangeNotifier)
* **DI**: GetIt
* **Backend**: Supabase (PostgreSQL)
* **External Packages**: `supabase_flutter`, `cached_network_image`, `image_picker`, `flutter_dotenv`, `intl`, `equatable`.


## 🔒 Security
RLS (Row Level Security) policies are implemented to ensure users can only access their own data or data shared in their rooms.

* **Secure storage of API keys via flutter_dotenv.**

## 📂 Architecture Structure

```text
lib/
├── core/                   # Shared logic (Errors, Utils, Constants)
├── features/               # Feature-based separation
│   ├── auth/               # Authentication Feature
│   ├── chat/               # Chat Feature (Messages, Input, Typing)
│   └── users/              # Users List Feature
│       ├── data/           # Remote Data Sources, Models, Repositories Impl
│       ├── domain/         # Entities, Usecases, Repository Interfaces
│       └── presentation/   # Pages, Widgets, Providers (State)
├── locator_service.dart    # Dependency Injection Setup
└── main.dart               # Entry point
