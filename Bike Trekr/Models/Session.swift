import SwiftUI
import FirebaseFirestoreSwift

struct Session: Identifiable, Codable {
    @DocumentID var id: String?
    var distance: Double
    var duration: String
    var date: Date
    var avSpeed: Double
    var maxSpeed: Double
    var typeSession: String
    var userId: String?
    var locations: [Location]
}
