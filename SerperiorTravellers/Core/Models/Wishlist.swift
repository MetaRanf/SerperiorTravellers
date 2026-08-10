import Foundation

public enum WishlistType: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case location = "location", vacationType = "vacation_type", custom = "custom"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .location: return "Location"
        case .vacationType: return "Vacation Type"
        case .custom: return "Custom"
        }
    }
    public var systemIcon: String {
        switch self {
        case .location: return "map"
        case .vacationType: return "airplane"
        case .custom: return "heart"
        }
    }
}

public enum WishlistItem: Identifiable, Codable, Equatable, Sendable, Hashable {
    case destination(id: UUID, destinationId: UUID, addedAt: Date)
    case property(id: UUID, propertyId: UUID, destinationId: UUID, addedAt: Date)
    case activity(id: UUID, activityId: UUID, destinationId: UUID, addedAt: Date)

    public var id: UUID {
        switch self {
        case .destination(let id, _, _): return id
        case .property(let id, _, _, _): return id
        case .activity(let id, _, _, _): return id
        }
    }

    public var referencedDestinationId: UUID {
        switch self {
        case .destination(_, let destinationId, _): return destinationId
        case .property(_, _, let destinationId, _): return destinationId
        case .activity(_, _, let destinationId, _): return destinationId
        }
    }

    public var addedAt: Date {
        switch self {
        case .destination(_, _, let d): return d
        case .property(_, _, _, let d): return d
        case .activity(_, _, _, let d): return d
        }
    }

    public enum Kind: String, Codable, Equatable, Sendable {
        case destination, property, activity
    }

    public var kind: Kind {
        switch self {
        case .destination: return .destination
        case .property: return .property
        case .activity: return .activity
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind, id, destinationId, propertyId, activityId, addedAt
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        let id = try c.decode(UUID.self, forKey: .id)
        let addedAt = try c.decodeIfPresent(Date.self, forKey: .addedAt) ?? Date()
        let destId = try c.decodeIfPresent(UUID.self, forKey: .destinationId) ?? UUID()
        switch kind {
        case .destination:
            self = .destination(id: id, destinationId: destId, addedAt: addedAt)
        case .property:
            let propId = try c.decode(UUID.self, forKey: .propertyId)
            self = .property(id: id, propertyId: propId, destinationId: destId, addedAt: addedAt)
        case .activity:
            let actId = try c.decode(UUID.self, forKey: .activityId)
            self = .activity(id: id, activityId: actId, destinationId: destId, addedAt: addedAt)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind, forKey: .kind)
        try c.encode(id, forKey: .id)
        try c.encode(addedAt, forKey: .addedAt)
        try c.encode(referencedDestinationId, forKey: .destinationId)
        switch self {
        case .destination: break
        case .property(_, let propertyId, _, _):
            try c.encode(propertyId, forKey: .propertyId)
        case .activity(_, let activityId, _, _):
            try c.encode(activityId, forKey: .activityId)
        }
    }

    public static func destinationItem(destinationId: UUID) -> WishlistItem {
        .destination(id: UUID(), destinationId: destinationId, addedAt: Date())
    }

    public static func propertyItem(propertyId: UUID, destinationId: UUID) -> WishlistItem {
        .property(id: UUID(), propertyId: propertyId, destinationId: destinationId, addedAt: Date())
    }

    public static func activityItem(activityId: UUID, destinationId: UUID) -> WishlistItem {
        .activity(id: UUID(), activityId: activityId, destinationId: destinationId, addedAt: Date())
    }
}

public struct Wishlist: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var userId: UUID
    public var title: String
    public var description: String?
    public var type: WishlistType
    public var items: [WishlistItem]
    public var coverImageURL: URL?
    public var createdAt: Date
    public var updatedAt: Date
    public var isPrivate: Bool

    public init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        description: String? = nil,
        type: WishlistType,
        items: [WishlistItem] = [],
        coverImageURL: URL? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPrivate: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.type = type
        self.items = items
        self.coverImageURL = coverImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPrivate = isPrivate
    }

    public var itemCount: Int { items.count }
    public var isEmpty: Bool { items.isEmpty }
    public var destinations: [WishlistItem] { items.filter { if case .destination = $0 { return true }; return false } }
    public var properties: [WishlistItem] { items.filter { if case .property = $0 { return true }; return false } }
    public var activities: [WishlistItem] { items.filter { if case .activity = $0 { return true }; return false } }
    public var lastAddedAt: Date? { items.map(\.addedAt).max() }

    public mutating func addItem(_ item: WishlistItem) {
        guard !items.contains(where: { $0.id == item.id }) else { return }
        items.append(item)
        updatedAt = Date()
    }

    public mutating func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
        updatedAt = Date()
    }

    public static func == (lhs: Wishlist, rhs: Wishlist) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt && lhs.items == rhs.items
    }

    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
