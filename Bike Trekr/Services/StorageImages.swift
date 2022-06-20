

import Foundation
import FirebaseStorage
import FirebaseAuth
import SwiftUI
import Combine

class StorageImages {
    
    static let shared = StorageImages()
    
    @Published var image: Image?
    
    private let storage = Storage.storage()
    
    @Published var isLoading = false
    
    func save(_ url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.save(data)
                }
            }
        }
    }
    
    func save(_ data: Data) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let ref = storage.reference()
        
        ref
            .child("profilePhotos")
            .child(userId + ".jpeg")
            .putData(data, metadata: metadata) { result in
                switch result {
                case .success(let metadata):
                    print(metadata.path ?? "no path")
                    guard let uiImage = UIImage(data: data) else { return }
                    self.image = Image(uiImage: uiImage)
                case .failure(let error): print(error.localizedDescription)
                }
            }
    }
    
    func download(completion: @escaping (Result<Image, Error>) -> Void) {
        guard !isLoading, let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = storage.reference()
        isLoading = true
        ref
            .child("profilePhotos")
            .child(userId + ".jpeg")
            .getData(maxSize: 1024 * 1024 * 5) { data, error in
                defer {
                    self.isLoading = false
                }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let uiImage = UIImage(data: data) else { return }
                self.image = Image(uiImage: uiImage)
                completion(.success(Image(uiImage: uiImage)))
            }
    }
}
