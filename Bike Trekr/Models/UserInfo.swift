import SwiftUI
import FirebaseFirestoreSwift

struct UserInfo: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var displayName: String
    var email: String
    var height: Int = 170
    var weight: Double = 70
    var sex: Sex = .male
    var birthday = Date()
}
