import Foundation
import SwiftData

@Model
final class YohakuBlock {
    var id: UUID
    var title: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
