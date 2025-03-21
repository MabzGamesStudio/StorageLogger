import Foundation

struct Entry: Identifiable, Codable {
    var id: String
    var imageFilename: String?
    var name: String?
    var price: Double?
    var quantity: Int?
    var description: String?
    var notes: String?
    var tags: String?
    var buyDate: Date?
}
