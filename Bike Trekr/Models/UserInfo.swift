import SwiftUI
import FirebaseFirestoreSwift

struct UserInfo: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String = ""
    var displayName: String = ""
    var email: String = ""
    var height: Double = 170
    var weight: Double = 70
    var sex: Sex = .male
    var birthday = Date()
}
