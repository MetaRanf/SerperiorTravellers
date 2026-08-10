import Foundation

public enum Permission: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case view = "view", comment = "comment", edit = "edit", admin = "admin"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .view: return "View Only"
        case .comment: return "Can Comment"
        case .edit: return "Can Edit"
        case .admin: return "Admin"
        }
    }
    public var rank: Int {
        switch self { case .view: return 0; case .comment: return 1; case .edit: return 2; case .admin: return 3 }
    }
    public func canPerform(_ required: Permission) -> Bool { rank >= required.rank }
}

public enum TripMemberRole: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case owner = "owner", editor = "editor", viewer = "viewer"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .owner: return "Owner"
        case .editor: return "Editor"
        case .viewer: return "Viewer"
        }
    }
    public var permission: Permission {
        switch self { case .owner: return .admin; case .editor: return .edit; case .viewer: return .view }
    }
}

public struct TripMember: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var userId: UUID
    public var tripId: UUID
    public var role: TripMemberRole
    public var permission: Permission
    public var displayName: String?
    public var email: String?
    public var avatarURL: URL?
    public var joinedAt: Date
    public var invitedBy: UUID?

    public init(
        id: UUID = UUID(),
        userId: UUID,
        tripId: UUID,
        role: TripMemberRole = .viewer,
        permission: Permission? = nil,
        displayName: String? = nil,
        email: String? = nil,
        avatarURL: URL? = nil,
        joinedAt: Date = Date(),
        invitedBy: UUID? = nil
    ) {
        self.id = id; self.userId = userId; self.tripId = tripId; self.role = role
        self.permission = permission ?? role.permission
        self.displayName = displayName; self.email = email; self.avatarURL = avatarURL
        self.joinedAt = joinedAt; self.invitedBy = invitedBy
    }

    public var isOwner: Bool { role == .owner }
    public func canEditTrip() -> Bool { permission.canPerform(.edit) }
    public func canManageMembers() -> Bool { permission.canPerform(.admin) }
}

public enum InviteStatus: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case pending = "pending", accepted = "accepted", declined = "declined", expired = "expired", revoked = "revoked"
    public var id: String { rawValue }
    public var displayName: String { rawValue.capitalized }
}

public struct Invite: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var tripId: UUID
    public var inviterId: UUID
    public var inviteeEmail: String
    public var inviteeUserId: UUID?
    public var role: TripMemberRole
    public var permission: Permission
    public var status: InviteStatus
    public var message: String?
    public var createdAt: Date
    public var expiresAt: Date?
    public var respondedAt: Date?

    public init(
        id: UUID = UUID(),
        tripId: UUID,
        inviterId: UUID,
        inviteeEmail: String,
        inviteeUserId: UUID? = nil,
        role: TripMemberRole = .viewer,
        permission: Permission? = nil,
        status: InviteStatus = .pending,
        message: String? = nil,
        createdAt: Date = Date(),
        expiresAt: Date? = Calendar.current.date(byAdding: .day, value: 7, to: Date()),
        respondedAt: Date? = nil
    ) {
        self.id = id; self.tripId = tripId; self.inviterId = inviterId
        self.inviteeEmail = inviteeEmail; self.inviteeUserId = inviteeUserId
        self.role = role; self.permission = permission ?? role.permission
        self.status = status; self.message = message; self.createdAt = createdAt
        self.expiresAt = expiresAt; self.respondedAt = respondedAt
    }

    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() > expiresAt && status == .pending
    }
    public var isPending: Bool { status == .pending && !isExpired }
}

public struct TripShareLink: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var tripId: UUID
    public var createdBy: UUID
    public var url: URL
    public var permission: Permission
    public var isActive: Bool
    public var expiresAt: Date?
    public var maxUses: Int?
    public var useCount: Int
    public var createdAt: Date
    public var title: String?

    public init(
        id: UUID = UUID(),
        tripId: UUID,
        createdBy: UUID,
        url: URL,
        permission: Permission = .view,
        isActive: Bool = true,
        expiresAt: Date? = nil,
        maxUses: Int? = nil,
        useCount: Int = 0,
        createdAt: Date = Date(),
        title: String? = nil
    ) {
        self.id = id; self.tripId = tripId; self.createdBy = createdBy; self.url = url
        self.permission = permission; self.isActive = isActive; self.expiresAt = expiresAt
        self.maxUses = maxUses; self.useCount = useCount; self.createdAt = createdAt; self.title = title
    }

    public var isExpired: Bool {
        if let expiresAt, Date() > expiresAt { return true }
        if let maxUses, useCount >= maxUses { return true }
        return false
    }
    public var isValid: Bool { isActive && !isExpired }
    public var shareableString: String { url.absoluteString }
}

public struct CollaborationSummary: Codable, Equatable, Sendable {
    public var tripId: UUID
    public var members: [TripMember]
    public var pendingInvites: [Invite]
    public var activeLinks: [TripShareLink]

    public init(tripId: UUID, members: [TripMember] = [], pendingInvites: [Invite] = [], activeLinks: [TripShareLink] = []) {
        self.tripId = tripId; self.members = members; self.pendingInvites = pendingInvites; self.activeLinks = activeLinks
    }

    public var totalCollaborators: Int { members.count }
    public var owner: TripMember? { members.first(where: \.isOwner) }
}
