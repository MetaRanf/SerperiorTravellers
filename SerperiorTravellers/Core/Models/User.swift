import Foundation

public struct User: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var email: String
    public var avatarURL: URL?
    public var createdAt: Date
    public var preferences: UserPreferences
    public var phoneNumber: String?
    public var bio: String?
    public var isVerified: Bool
    public var isPremium: Bool
    public var lastLoginAt: Date?

    public init(
        id: UUID = UUID(),
        name: String,
        email: String,
        avatarURL: URL? = nil,
        createdAt: Date = Date(),
        preferences: UserPreferences = .default,
        phoneNumber: String? = nil,
        bio: String? = nil,
        isVerified: Bool = false,
        isPremium: Bool = false,
        lastLoginAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.preferences = preferences
        self.phoneNumber = phoneNumber
        self.bio = bio
        self.isVerified = isVerified
        self.isPremium = isPremium
        self.lastLoginAt = lastLoginAt
    }

    public var initials: String {
        let parts = name.split(separator: " ")
        let chars = parts.compactMap { $0.first }
        return String(chars.prefix(2)).uppercased()
    }

    public var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }

    public var isNewUser: Bool {
        Date().timeIntervalSince(createdAt) < 60 * 60 * 24 * 7
    }

    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.email == rhs.email && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var isEmailValid: Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
}

#if DEBUG
public extension User {
    static var preview: User {
        User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            name: "Ava Explorer",
            email: "ava@serperior.travel",
            avatarURL: URL(string: "https://example.com/avatar.jpg"),
            createdAt: Date().addingTimeInterval(-60*60*24*30),
            preferences: UserPreferences(currency: .usd, favoriteTypes: [.beach, .luxury]),
            isVerified: true,
            isPremium: true
        )
    }

    static var guest: User {
        User(name: "Guest", email: "guest@serperior.travel", preferences: .default)
    }
}
#endif
