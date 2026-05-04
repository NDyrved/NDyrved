import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @Binding var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showPicker = false
    @State private var cameraImage: UIImage?

    var body: some View {
        VStack(spacing: 24) {
            // Preview / placeholder
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(cropGuidanceOverlay, alignment: .center)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(DSColor.card)
                        .frame(maxWidth: .infinity)
                        .frame(height: 420)
                        .overlay(emptyPlaceholder)
                }
            }
            .padding(.horizontal, 16)

            // Action buttons
            HStack(spacing: 16) {
                photoPickerButton
                cameraButton
            }
            .padding(.horizontal, 24)

            if selectedImage != nil {
                Button(role: .destructive) {
                    selectedImage = nil
                } label: {
                    Label("Remove Photo", systemImage: "trash")
                        .font(.caption)
                }
                .foregroundStyle(.red)
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) {
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(capturedImage: $cameraImage)
                .ignoresSafeArea()
        }
        .onChange(of: cameraImage) {
            if let img = cameraImage { selectedImage = img }
        }
    }

    // MARK: - Subviews

    private var emptyPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.fill.viewfinder")
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(DSColor.accent.opacity(0.6))
            VStack(spacing: 4) {
                Text("Upload a full-body photo")
                    .font(.headline)
                Text("Stand back from the camera so your\nwhole body is visible")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var cropGuidanceOverlay: some View {
        GeometryReader { geo in
            // Silhouette outline as guidance
            ZStack {
                // Outer dimming area
                Color.black.opacity(0.25)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: geo.size.width * 0.55,
                                           height: geo.size.height * 0.92)
                                    .blendMode(.destinationOut)
                            )
                    )
                // Guide rectangle
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.92)

                // Label
                VStack {
                    Spacer()
                    Text("Align body within guide")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(.black.opacity(0.5), in: Capsule())
                        .padding(.bottom, 8)
                }
                .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.92)
            }
        }
    }

    private var photoPickerButton: some View {
        Button { showPicker = true } label: {
            Label("Photo Library", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var cameraButton: some View {
        Button { showCamera = true } label: {
            Label("Camera", systemImage: "camera")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

// MARK: - Camera View (UIViewControllerRepresentable)
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.capturedImage = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
