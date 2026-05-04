import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(icon: "hanger",
                       title: "Your Virtual\nFitting Room",
                       subtitle: "See any outfit on your body before you buy — no guesswork, no returns."),
        OnboardingPage(icon: "link",
                       title: "Paste Any\nProduct URL",
                       subtitle: "Copy a link from any online store. We pull the item and place it on your photo instantly."),
        OnboardingPage(icon: "rectangle.stack.fill",
                       title: "Build Full\nOutfits",
                       subtitle: "Layer tops, bottoms, shoes and accessories to mix and match the perfect look."),
        OnboardingPage(icon: "heart.fill",
                       title: "Save &\nRevisit",
                       subtitle: "Save your favourite outfit combinations and let AI suggest new ones from your wardrobe."),
    ]

    var body: some View {
        ZStack {
            DSColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { i, p in
                        OnboardingPageView(page: p).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                // Dots
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? DSColor.accent : DSColor.border)
                            .frame(width: i == page ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }
                .padding(.bottom, 28)

                // CTAs
                VStack(spacing: 12) {
                    if page < pages.count - 1 {
                        Button("Continue") { withAnimation { page += 1 } }
                            .buttonStyle(PrimaryButtonStyle())
                        Button("Skip") { env.completeOnboarding() }
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textTertiary)
                    } else {
                        Button("Get Started") { env.completeOnboarding() }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }
}

struct OnboardingPage { let icon: String; let title: String; let subtitle: String }

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(DSColor.accentMuted)
                    .frame(width: 160, height: 160)
                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(DSColor.accent)
            }
            VStack(spacing: 14) {
                Text(page.title)
                    .font(DSTypography.title)
                    .foregroundStyle(DSColor.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(DSTypography.body)
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            Spacer()
        }
    }
}
