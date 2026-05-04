import SwiftUI

struct ClothingInputView: View {
    @EnvironmentObject private var env: AppEnvironment
    var onAdd: (ClothingItem) -> Void

    @State private var urlText = ""
    @State private var selectedCategory: ClothingCategory = .top
    @State private var fetchedMeta: FetchedClothingMeta?
    @State private var isFetching = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // URL input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Product URL")
                            .font(.subheadline.weight(.semibold))
                        HStack(spacing: 10) {
                            DSTextField(title: "Paste link from any online store", text: $urlText)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            Button {
                                Task { await fetchClothing() }
                            } label: {
                                if isFetching {
                                    ProgressView().frame(width: 44, height: 44)
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(urlText.isEmpty ? .secondary : DSColor.accent)
                                }
                            }
                            .disabled(urlText.isEmpty || isFetching)
                        }
                    }

                    // Category picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline.weight(.semibold))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ClothingCategory.allCases, id: \.self) { cat in
                                    categoryChip(cat)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }

                    // Error
                    if let error = errorMessage {
                        ErrorStateView(message: error)
                    }

                    // Preview card
                    if let meta = fetchedMeta {
                        previewCard(meta: meta)
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Add Clothing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Category Chip
    private func categoryChip(_ cat: ClothingCategory) -> some View {
        let isSelected = selectedCategory == cat
        return Button { selectedCategory = cat } label: {
            HStack(spacing: 6) {
                Image(systemName: cat.icon)
                Text(cat.rawValue)
            }
            .font(.subheadline.weight(isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? .white : DSColor.accent)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(isSelected ? DSColor.accent : DSColor.accent.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preview Card
    private func previewCard(meta: FetchedClothingMeta) -> some View {
        DSCard {
            HStack(spacing: 16) {
                // Thumbnail
                Group {
                    if let data = meta.imageData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.secondary.opacity(0.2)
                            .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                    }
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    Text(meta.productName.isEmpty ? "Product" : meta.productName)
                        .font(.headline)
                        .lineLimit(2)
                    Text(selectedCategory.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Add to Outfit") {
                        addItem(meta: meta)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .font(.subheadline)
                }

                Spacer(minLength: 0)
            }
            .padding(4)
        }
    }

    // MARK: - Fetch
    private func fetchClothing() async {
        isFetching = true
        errorMessage = nil
        fetchedMeta = nil
        do {
            fetchedMeta = try await env.clothingFetch.fetch(urlString: urlText)
        } catch {
            errorMessage = error.localizedDescription
        }
        isFetching = false
    }

    // MARK: - Add Item
    private func addItem(meta: FetchedClothingMeta) {
        let item = ClothingItem(
            sourceURL: urlText,
            imageURL: meta.imageURL?.absoluteString,
            imageData: meta.imageData,
            productName: meta.productName,
            category: selectedCategory
        )
        onAdd(item)
        dismiss()
    }
}
