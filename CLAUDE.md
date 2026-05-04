# Outfit App — Architecture & File Structure

Branch: `outfit-app`
Boilerplate base: `main` (do not modify)

---

## Overview

A SwiftUI iOS app that lets users upload a full-body photo, paste product URLs from any online store, and preview clothing items overlaid on their body. Users can layer multiple items to build full outfits, save them, and get AI-generated outfit suggestions from their wardrobe and from curated store catalogues.

**Architecture:** MVVM — one ViewModel per screen, no logic in Views
**Persistence:** SwiftData (`Outfit`, `ClothingItem`)
**Subscriptions:** StoreKit 2 (`com.appname.monthly` / `com.appname.annual`)
**Auth:** Sign in with Apple + email/password (mock)
**Min target:** iOS 17

---

## Design System

All tokens live in `DesignSystem/`. Warm editorial palette — cream/espresso in light, near-black/caramel in dark. No asset catalogue required; colours use inline `UIColor` adaptive initialisers.

| Token | Purpose |
|---|---|
| `DSColor.background` | Page background (cream / near-black) |
| `DSColor.card` | Elevated surface |
| `DSColor.accent` | CTA espresso brown / caramel |
| `DSColor.textPrimary/Secondary/Tertiary` | Text hierarchy |
| `DSTypography.display` | 48pt black hero text |
| `DSTypography.title/title2/title3` | Heading scale |
| `DSTypography.body/bodyMedium` | Body copy |
| `DSTypography.caption/caption2` | Supporting text |
| `DSTypography.price/score` | Monospaced numbers |

### Shared Components
- `DSTag` — pill-shaped occasion tag, selectable
- `DSTagRow` — horizontal scrollable tag filter
- `DSMatchBadge` — dark badge showing AI Match %
- `DSOutfitCard` — card shell with shadow
- `DSItemThumbnailStrip` — horizontal clothing image row
- `DSColorPaletteStrip` — colour swatch dots

---

## File Structure

```
BoilerplateApp/
├── App/
│   ├── BoilerplateAppApp.swift
│   ├── AppEnvironment.swift         DI container — all services injected here
│   └── AppRouter.swift
│
├── Models/
│   ├── ClothingItem.swift           SwiftData — brand, category, occasionTags, colorHex
│   ├── Outfit.swift                 SwiftData — tags, styleScore, colorPalette
│   ├── TryOnSession.swift           Transient in-memory session
│   ├── OccasionTag.swift            Enum: casual/smartCasual/formal/weekend/work/sport/evening
│   └── DiscoveryOutfit.swift        Transient struct for store-sourced outfits + RetailStore enum
│
├── Services/
│   ├── StoreKitService.swift        StoreKit 2 purchases + subscription status
│   ├── ClothingFetchService.swift   OpenGraph scraper → product image + name
│   ├── OutfitStore.swift            SwiftData CRUD + free-tier counter + standalone items
│   ├── AIStyleService.swift         Local colour-harmony engine → OutfitSuggestion[]
│   ├── DiscoveryService.swift       Mock catalogue of store outfits (swap for real API)
│   ├── Protocols.swift
│   └── Mocks.swift
│
├── Features/
│   ├── Home/
│   │   └── MainTabView.swift        5 tabs: Home | Search | Builder | Wardrobe | Profile
│   │                                HomeHubView lives here (quick actions, plan status)
│   ├── Onboarding/
│   │   └── OnboardingView.swift     4-page editorial onboarding
│   ├── Authentication/
│   │   └── AuthViews.swift          Sign in with Apple + email/password
│   ├── Paywall/
│   │   ├── PaywallView.swift        3-day trial, annual pre-selected, perks list
│   │   └── PaywallViewModel.swift
│   ├── TryOn/
│   │   └── TryOnView.swift          Canvas + draggable garment overlays + tray
│   ├── ClothingInput/
│   │   └── ClothingInputView.swift  URL → OpenGraph → preview → add
│   ├── PhotoUpload/
│   │   └── PhotoUploadView.swift    Camera + library + crop guide
│   ├── Wardrobe/
│   │   ├── WardrobeView.swift       Tab shell with 3-segment picker
│   │   ├── MyClothingView.swift     Grid of all ClothingItems + stats header
│   │   ├── MyClothingViewModel.swift
│   │   ├── WardrobeSavedOutfitsView.swift    Gallery with stats + tag filter
│   │   ├── WardrobeSavedOutfitsViewModel.swift
│   │   ├── AIWardrobeSuggestionsView.swift   AI combos from user's own items
│   │   └── AIWardrobeSuggestionsViewModel.swift
│   ├── Discovery/
│   │   ├── DiscoveryView.swift      Search tab — store filter + occasion filter + sort
│   │   ├── DiscoveryViewModel.swift
│   │   └── OutfitDetailView.swift   Item list + price + add to wardrobe + buy link
│   ├── SavedOutfits/
│   │   └── SavedOutfitsView.swift   (legacy — superseded by Wardrobe tab)
│   ├── Subscription/
│   │   └── SubscriptionView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Legal/
│       └── LegalViews.swift
│
├── DesignSystem/
│   ├── Colors/DSColor.swift
│   ├── Typography/DSTypography.swift
│   ├── Buttons/PrimaryButton.swift
│   ├── Buttons/SecondaryButton.swift
│   ├── Components/DSTag.swift
│   ├── Components/DSMatchBadge.swift
│   ├── Components/DSOutfitCard.swift
│   ├── Inputs/DSTextField.swift
│   ├── Layout/DSCard.swift
│   ├── Loading/LoadingView.swift
│   └── States/EmptyStateView.swift, ErrorStateView.swift
│
└── Core/
    ├── Keychain/KeychainStore.swift
    ├── Logger/AppLogger.swift
    ├── Storage/SessionStore.swift
    ├── Networking/NetworkModels.swift
    ├── Utilities/AppConfig.swift
    ├── ErrorHandling/AppError.swift
    └── FeatureFlags/FeatureFlagService.swift
```

---

## Key Decisions

### Free vs Premium gating
- Free: 3 try-ons/month (`OutfitStore.tryOnCountThisMonth`)
- Premium gates: outfit saving, AI wardrobe suggestions, AI discovery
- `AppEnvironment.isPremium` = single source of truth

### AI Style Engine (local)
- `AIStyleService` — pure Swift, no external API
- Scores based on colour harmony (neutral/warm/cool/dark groups) + category completeness
- Deterministic jitter from item ID hashes prevents all scores looking identical

### Discovery Service
- `DiscoveryService` returns mock `[DiscoveryOutfit]`
- Filterable by store (`RetailStore`), occasion (`OccasionTag`), sortable
- Replace `catalogue` array with a real API call — zero view changes needed

### StoreKit 2 product IDs
- `com.appname.monthly` — €19.99/month
- `com.appname.annual` — €199.99/year (~€16.67/month)
- Both gated behind a 3-day free trial

### Xcode setup required
- Add **Sign in with Apple** capability
- Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to Info.plist

---

## Branch Rules
- `main` — clean boilerplate, never modified
- `outfit-app` — all development here
- Commit after each task with clear messages
