import SwiftUI

struct TryOnView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var session: TryOnSession
    @State private var showPhotoSheet = false

    /// Default init — empty session (normal Builder tab)
    init(initialItems: [ClothingItem] = []) {
        var s = TryOnSession()
        s.items = initialItems
        s.activeItemID = initialItems.first?.id
        _session = State(initialValue: s)
    }
    @State private var showClothingSheet = false
    @State private var showPaywall = false
    @State private var showSaveAlert = false
    @State private var outfitName = "My Outfit"

    var body: some View {
        NavigationStack {
            ZStack {
                DSColor.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Canvas
                    canvasArea
                        .frame(maxWidth: .infinity)
                        .frame(height: 460)

                    Divider()

                    // Item tray
                    clothingTray
                        .frame(height: 110)

                    // Action row
                    actionRow
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
            .navigationTitle("Try On")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .sheet(isPresented: $showPhotoSheet) {
                photoPickerSheet
            }
            .sheet(isPresented: $showClothingSheet) {
                ClothingInputView { item in
                    session.items.append(item)
                    session.activeItemID = item.id
                }
                .environmentObject(env)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(env)
            }
            .alert("Save Outfit", isPresented: $showSaveAlert) {
                TextField("Outfit name", text: $outfitName)
                Button("Save") { saveOutfit() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Canvas
    private var canvasArea: some View {
        ZStack {
            if let bodyPhoto = session.bodyPhoto {
                Image(uiImage: bodyPhoto)
                    .resizable()
                    .scaledToFill()
                    .clipped()

                // Clothing overlays
                ForEach(session.items, id: \.id) { item in
                    DraggableClothingOverlay(
                        item: item,
                        isActive: session.activeItemID == item.id,
                        onTap: { session.activeItemID = item.id }
                    )
                }
            } else {
                emptyCanvasPlaceholder
            }
        }
        .clipShape(Rectangle())
        .contentShape(Rectangle())
        .onTapGesture { session.activeItemID = nil }
    }

    private var emptyCanvasPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.fill.viewfinder")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundStyle(DSColor.accent.opacity(0.4))
            Text("Tap below to add your photo")
                .font(DSTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.card)
    }

    // MARK: - Clothing Tray
    private var clothingTray: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Add new item button
                Button { handleAddClothing() } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle().fill(DSColor.accent.opacity(0.12)).frame(width: 60, height: 60)
                            Image(systemName: "plus").font(.title2).foregroundStyle(DSColor.accent)
                        }
                        Text("Add Item").font(.caption2).foregroundStyle(DSColor.accent)
                    }
                }

                ForEach(session.items, id: \.id) { item in
                    ClothingTrayItem(
                        item: item,
                        isActive: session.activeItemID == item.id,
                        onTap: {
                            session.activeItemID = item.id == session.activeItemID ? nil : item.id
                        },
                        onRemove: {
                            session.items.removeAll { $0.id == item.id }
                            if session.activeItemID == item.id { session.activeItemID = nil }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Action Row
    private var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                if session.bodyPhoto == nil { showPhotoSheet = true }
                else { showPhotoSheet = true }
            } label: {
                Label("Photo", systemImage: session.bodyPhoto == nil ? "camera.fill" : "camera.badge.ellipsis")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())

            Button {
                guard !session.isEmpty else { return }
                showSaveAlert = true
            } label: {
                Label("Save", systemImage: "heart.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(session.isEmpty)
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { session = TryOnSession() } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .disabled(session.isEmpty)
        }
    }

    // MARK: - Photo Picker Sheet
    private var photoPickerSheet: some View {
        NavigationStack {
            ScrollView {
                PhotoUploadView(selectedImage: Binding(
                    get: { session.bodyPhoto },
                    set: { session.bodyPhoto = $0 }
                ))
                .padding()
            }
            .navigationTitle("Choose Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showPhotoSheet = false }
                }
            }
        }
    }

    // MARK: - Helpers
    private func handleAddClothing() {
        guard canAddMoreTryOns else {
            showPaywall = true
            return
        }
        env.outfitStore.incrementTryOnCount()
        showClothingSheet = true
    }

    private var canAddMoreTryOns: Bool {
        if env.isPremium { return true }
        return env.outfitStore.tryOnCountThisMonth < 3
    }

    private func saveOutfit() {
        guard env.isPremium else { showPaywall = true; return }
        let photoData = session.bodyPhoto?.jpegData(compressionQuality: 0.8)
        let outfit = Outfit(name: outfitName, bodyPhotoData: photoData, items: session.items)
        env.outfitStore.saveOutfit(outfit)
    }
}

// MARK: - Draggable Clothing Overlay
struct DraggableClothingOverlay: View {
    let item: ClothingItem
    let isActive: Bool
    let onTap: () -> Void

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        Group {
            if let data = item.imageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160 * scale, height: 160 * scale)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 120 * scale, height: 120 * scale)
                    .overlay(
                        Image(systemName: item.category.icon)
                            .foregroundStyle(.secondary)
                    )
            }
        }
        .overlay(
            isActive ? RoundedRectangle(cornerRadius: 6)
                .stroke(DSColor.accent, lineWidth: 2)
                .padding(-4) : nil
        )
        .offset(offset)
        .gesture(
            SimultaneousGesture(
                DragGesture()
                    .onChanged { val in offset = CGSize(width: lastOffset.width + val.translation.width,
                                                        height: lastOffset.height + val.translation.height) }
                    .onEnded { _ in lastOffset = offset },
                MagnificationGesture()
                    .onChanged { val in scale = lastScale * val }
                    .onEnded { _ in lastScale = scale }
            )
        )
        .onTapGesture { onTap() }
        .animation(.interactiveSpring(), value: isActive)
    }
}

// MARK: - Clothing Tray Item
struct ClothingTrayItem: View {
    let item: ClothingItem
    let isActive: Bool
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                VStack(spacing: 4) {
                    Group {
                        if let data = item.imageData, let ui = UIImage(data: data) {
                            Image(uiImage: ui).resizable().scaledToFill()
                        } else {
                            Color.secondary.opacity(0.2)
                                .overlay(Image(systemName: item.category.icon).foregroundStyle(.secondary))
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isActive ? DSColor.accent : .clear, lineWidth: 2)
                    )

                    Text(item.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(isActive ? DSColor.accent : .secondary)
                }
            }
            .buttonStyle(.plain)

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white, .red)
                    .font(.system(size: 18))
            }
            .offset(x: 4, y: -4)
        }
    }
}
