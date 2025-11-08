# Changelog

## 2.0.7
- Fixed plugin score issues

## 2.0.6

### 🚀 Major Refactoring: Modular Architecture
- **⚠️ Breaking Change:** The plugin has been completely refactored into a modular architecture for better scalability and maintenance.  
- Introduced new packages:
  - **`credential_manager`** – Main package containing shared logic, models, and utilities.  
  - **`credential_manager_platform_interface`** – Platform-agnostic interface for consistent API definitions.  
  - **`credential_manager_android`** – Android-specific implementation.  
  - **`credential_manager_ios`** – iOS-specific implementation.  
- All packages are now organized under the `packages/` directory.  
- Greatly improved maintainability, clarity, and extensibility for future updates.

### 🧠 Code Optimization
- Removed **300+ lines of duplicate code** between Android and iOS implementations.  
- Introduced shared utilities:
  - `CredentialType` – Centralized credential type definitions.  
  - `PlatformExceptionHandler` – Unified platform error handling.  
  - `CredentialResponseParser` – Shared response parsing logic for all platforms.  
- File size reduction highlights:
  - Android implementation: **~326 → 177 lines**  
  - iOS implementation: **~410 → 250 lines**

### 🐞 Bug Fixes
- Fixed `AssertionError` for uninitialized `CredentialManagerPlatform.instance`.  
- Added **automatic platform registration** within the `CredentialManager` constructor.  
- Fixed platform implementations not being registered automatically.

### ⚙️ Platform Registration Improvements
- Platform implementations now **auto-register** when `CredentialManager` is instantiated.  
- Improved error messages for uninitialized platform instances.

### ✅ Testing & Migration
- Migration verified and tested on both platforms:
  - ✅ iOS  
  - ✅ Android  
- All platform implementations are stable and functional.

### 🧩 Developer Experience
- Added `analysis_error.sh` script for static analysis and code health checks.  
- Enforced better separation of concerns across all packages.  
- All packages pass static analysis with **zero errors**.

### 📚 Documentation
- Updated **README** and package documentation to reflect the modular structure.  
- Added in-code documentation for maintainers and contributors.  
- Improved migration guide and changelog clarity.

---

## 2.0.4

### Dependencies
- Updated Android and Flutter dependencies for improved stability and compatibility. ([3a870fa](https://github.com/your-repo/commit/3a870fa))
- Updated Android Gradle plugin version to 8.4.2.
- Upgraded package versions and fixed iOS-related errors.

### iOS Fixes
- Refactored UIWindow retrieval logic in `PasskeyAuthentication` and `PasskeyRegistration`.
- Fixed iOS build issues in the example project.

### Documentation & CI
- Enhanced README and overall documentation.
- Updated static analysis and caching workflows in `static.yml` for improved CI performance.

---

## 2.0.3

- Migrated example application to Gradle 8.10.2.  
- Updated dependencies.  
- Added decoding of `attestationObject` to extract `publicKey` and `authenticatorData` for passkey credential registration (iOS only).  
- Improved example application.

---

## 2.0.2

- Updated documentation.

---

## 2.0.1

- Fixed example application (`enableInlineAutofill`) for iOS by default.

---

## 2.0.0

- Added Password Credentials and Passkey Credentials support for iOS.  
- **Breaking Changes** on Android.  
- Removed Encrypted Credentials (password-based) from both platforms.

---

## 1.0.4+1

- Updated documentation and example application.  
- Updated dependencies, README, CHANGELOG, LICENSE, and `pubspec.yaml`.  
- Updated `errors.md`.

---

## 1.0.4

- Added logout functionality using `clearCredential()`.  
- Updated example application, documentation, and dependencies.

---

## 1.0.3

- Added Google button flow for Google login.  
  Thanks to [@wildsylvan](https://github.com/wildsylvan).

---

## 1.0.2

- Added missing fields to `Response` object for `PublicKeyCredential`.

---

## 1.0.1

- Fixed example application (package ID).  
- Provided `rpId` for testing purposes.

---

## 1.0.0

- Added Passkey support.  
- Autofill from website.  
- Fixed bugs and improved code.

---

## 0.0.5

- Updated all dependencies to latest versions.  
  Thanks to [@jlafazia-figure](https://github.com/jlafazia-figure).  
- Bug fixes and improvements in example app.  
- Updated README.md with latest info.

---

## 0.0.4

- Migrated to latest Jetpack library version ([release notes](https://developer.android.com/jetpack/androidx/releases/credentials#groovy)).  
- Added Google Sign-in with Credential Manager.

---

## 0.0.3

- Implemented remaining `ActivityAware` lifecycle methods.  
  Thanks to [Granfalloner](https://github.com/Granfalloner).

---

## 0.0.2

- Added encryption.  
- Added documentation.  
- No breaking changes.

---

## 0.0.1

- Initial release.
