# Publishing Guide

## Publishing Order

For federated plugins, packages must be published in a specific order:

1. **credential_manager_platform_interface** (2.0.5)
2. **credential_manager_android** (2.0.5)
3. **credential_manager_ios** (2.0.5)
4. **credential_manager** (2.0.5) - Main package

## Required Changes for Publishing

### 1. credential_manager_platform_interface

**Current issues:**
- ✅ LICENSE file added
- ✅ CHANGELOG.md added
- ❌ Path dependency on `credential_manager` needs to be replaced

**For publishing, update `pubspec.yaml`:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  plugin_platform_interface: ^2.0.2
  credential_manager: ^2.0.5  # Change from path to version
```

**Note:** This creates a circular dependency since `credential_manager` depends on `credential_manager_platform_interface`. This needs architectural refactoring.

### 2. credential_manager_android

**Current issues:**
- ✅ LICENSE file added
- ✅ CHANGELOG.md added
- ❌ Path dependencies need to be replaced

**For publishing, update `pubspec.yaml`:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  credential_manager_platform_interface: ^2.0.5
  credential_manager: ^2.0.5
  plugin_platform_interface: ^2.0.2
```

### 3. credential_manager_ios

**Current issues:**
- ✅ LICENSE file added
- ✅ CHANGELOG.md added
- ❌ Path dependencies need to be replaced

**For publishing, update `pubspec.yaml`:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  credential_manager_platform_interface: ^2.0.5
  credential_manager: ^2.0.5
  plugin_platform_interface: ^2.0.2
  cbor: ^6.3.5
```

### 4. credential_manager (Main Package)

**Current issues:**
- ❌ Path dependencies need to be replaced

**For publishing, update `pubspec.yaml`:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  credential_manager_platform_interface: ^2.0.5
  credential_manager_android: ^2.0.5
  credential_manager_ios: ^2.0.5
  plugin_platform_interface: ^2.0.2
  cbor: ^6.3.5
```

## Circular Dependency Issue

**Problem:** `credential_manager_platform_interface` depends on `credential_manager` for model types, but `credential_manager` also depends on `credential_manager_platform_interface`.

**Solutions:**
1. **Option 1:** Move model types to `credential_manager_platform_interface` package
2. **Option 2:** Create a separate `credential_manager_models` package
3. **Option 3:** Use type-only imports in platform interface (not recommended)

## Publishing Commands

```bash
# 1. Publish platform interface
cd packages/credential_manager_platform_interface
# Update pubspec.yaml dependencies (remove path, use versions)
flutter pub publish --dry-run
flutter pub publish

# 2. Publish Android implementation
cd ../credential_manager_android
# Update pubspec.yaml dependencies
flutter pub publish --dry-run
flutter pub publish

# 3. Publish iOS implementation
cd ../credential_manager_ios
# Update pubspec.yaml dependencies
flutter pub publish --dry-run
flutter pub publish

# 4. Publish main package
cd ../credential_manager
# Update pubspec.yaml dependencies
flutter pub publish --dry-run
flutter pub publish
```

## After Publishing

Remember to:
1. Restore `publish_to: none` if you want to prevent accidental republishing
2. Restore path dependencies for local development
3. Update version numbers for next release

