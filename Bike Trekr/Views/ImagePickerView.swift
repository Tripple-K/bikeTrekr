import SwiftUI
import UIKit
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    
    
    let configuration: PHPickerConfiguration
    @Binding var isPresented: Bool
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
        
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            parent.isPresented = false
            
            guard let image = results.first else { return }
            if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] newImage, error in
                    if let error = error {
                        print("Can't load image \(error.localizedDescription)")
                    } else if let image = newImage as? UIImage {
                        self?.parent.onImagePicked(image)
                    }
                }
            } else {
                print("Can't load asset")
            }
            
            
        }
    }
}


public struct CameraPicker: UIViewControllerRepresentable {
    
    private let sourceType: UIImagePickerController.SourceType = .camera
    private let onImagePicked: (UIImage) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    public init(onImagePicked: @escaping (UIImage) -> Void) {
        self.onImagePicked = onImagePicked
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void
        
        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }
        
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
        
    }
    
}
