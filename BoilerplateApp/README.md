# BoilerplateApp (iOS 17+ SwiftUI Starter)

Reusable native iOS SwiftUI template optimized for cloning across many apps.

## Architecture decisions
- Feature-first structure: `Features/*` holds user flows; `Core/*` holds cross-cutting concerns.
- Protocol-driven services in `Services/` with app-level injection in `AppEnvironment`.
- App state is centralized and persisted via `SessionStore`.
- Swift concurrency (`async/await`) for service boundaries.

## New App Setup Checklist
1. Rename app target/scheme from `BoilerplateApp`.
2. Replace bundle identifier, signing, and build configs.
3. Update `DesignSystem` colors/typography/components.
4. Replace `Resources` (assets, app icons, launch screen, localization).
5. Swap mock services for production services.
6. Fill legal copy and app-specific onboarding copy.
7. Add app-specific feature flags.
8. Add CI + linting + release automation.

## Replacing Mock Services
- Firebase: create `FirebaseAuthService`, `FirebaseAPIClient`, wire in `AppEnvironment.bootstrap(config:)`.
- Supabase: create `SupabaseAuthService` + PostgREST API implementation.
- Custom backend: implement `AuthService`, `APIClient`, `SubscriptionService`, `AnalyticsService`.

## Launch essentials still app-specific
- Privacy manifest and required entitlements.
- Push notifications/background modes if needed.
- Production Keychain implementation.
- Real StoreKit 2 purchase verification.

## TODO markers
Search for `TODO:` to find integration points for app-specific code.
