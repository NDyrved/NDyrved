# BoilerplateApp

A native SwiftUI iOS 17 boilerplate app with onboarding, authentication, tabs, profile, settings, and a paywall placeholder.

## Open in Xcode

1. Clone or download this repository on your Mac.
2. Double-click `BoilerplateApp.xcodeproj` in the repository root.
3. In Xcode, select the `BoilerplateApp` scheme.
4. Choose an iPhone Simulator, such as iPhone 15 or newer.
5. Press `Cmd+R` to build and run.

## Project Structure

```text
BoilerplateApp.xcodeproj/
BoilerplateApp/
README.md
.gitignore
```

The Xcode project is committed as real project files:

```text
BoilerplateApp.xcodeproj/project.pbxproj
BoilerplateApp.xcodeproj/project.xcworkspace/contents.xcworkspacedata
BoilerplateApp.xcodeproj/xcshareddata/xcschemes/BoilerplateApp.xcscheme
```

## App Features

- SwiftUI app entry point in `BoilerplateApp/App/BoilerplateAppApp.swift`
- Onboarding flow
- Login and register screens backed by `MockAuthService`
- Home, Profile, and Settings tabs
- Paywall placeholder backed by `MockSubscriptionService`
- Reusable design system components
- Basic app state and navigation flow

## Requirements

- Xcode 15 or newer
- iOS 17 minimum deployment target
- macOS with an installed iPhone Simulator
