# Contact Manager App

A full-stack Contact Manager application built with:

* **Frontend:** Flutter
* **Backend:** Django + Django REST Framework
* **Database:** PostgreSQL
* **Authentication:** Token-based authentication
* **State Management:** Provider

---

## 🏗 Architecture Overview

The project follows a **clean layered architecture** with clear separation of concerns.

### 1️⃣ Presentation Layer (UI)

Located in:

```
lib/ui/
```

Contains:

* Login screen
* Contact list screen
* Add/Edit contact dialogs

This layer:

* Displays data
* Sends user actions to Providers
* Reacts to Provider state changes

---

### 2️⃣ State Management Layer (Providers)

Located in:

```
lib/providers/
```

Uses `ChangeNotifier` from Provider package.

#### AuthProvider

Responsible for:

* Login
* Signup
* Logout
* Token storage
* Authentication state

#### ContactProvider

Responsible for:

* Fetching contacts
* Creating contacts
* Updating contacts
* Deleting contacts

#### SearchProvider

Responsible for:

* Managing search query
* Filtering contacts
* Handling "no results" state

---

### 3️⃣ Networking Layer

Handled inside Providers using:

* `http` package
* Token-based authentication
* Base URL configured in `app_config.dart`

All API calls go to Django backend via ngrok (during development).

---

### 4️⃣ Backend (Django)

* Django REST Framework API
* Token Authentication
* PostgreSQL database
* Endpoints:

  * `/signup/`
  * `/login/`
  * `/contacts/`
  * `/contacts/search/`

---

## 🔄 Application Flow

1. App starts → `AuthGate`
2. If user is authenticated → ContactPage
3. If not → LoginPage
4. Providers manage all state and notify UI on changes

---

## 🧠 State Management Strategy

* `MultiProvider` is defined in `main.dart`
* Each provider is globally available
* UI listens using:

  * `context.watch<T>()`
  * `context.read<T>()`

---

## 🚀 Running the App

1. Start Django backend
2. Start ngrok
3. Update `baseUrl` in `app_config.dart`
4. Run:

```bash
flutter run
```

---

## 📦 Future Improvements

* Repository layer abstraction
* Better error handling
* Offline support
* Unit & widget tests
* Linter cleanup
* CI/CD pipeline

```
```
