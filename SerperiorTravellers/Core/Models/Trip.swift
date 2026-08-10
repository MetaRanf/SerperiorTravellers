import Foundation

public enum TripStatus: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case planned = "planned", ongoing = "ongoing", completed = "completed", cancelled = "cancelled"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .planned: return "Planned"
        case .ongoing: return "Ongoing"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    public var systemIcon: String {
        switch self {
        case .planned: return "calendar"
        case .ongoing: return "airplane.departure"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
}

public struct TimeSlot: Codable, Equatable, Sendable, Hashable {
    public var start: Date
    public var end: Date?
    public init(start: Date, end: Date? = nil) { self.start = start; self.end = end }
    public var durationMinutes: Int? {
        guard let end else { return nil }
        return Int(end.timeIntervalSince(start) / 60)
    }
}

public struct TripActivity: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var activityId: UUID
    public var notes: String?
    public var timeSlot: TimeSlot?
    public var isCompleted: Bool
    public var order: Int
    public var cost: Decimal?
    public var assignedMemberIds: [UUID]

    public init(
        id: UUID = UUID(),
        activityId: UUID,
        notes: String? = nil,
        timeSlot: TimeSlot? = nil,
        isCompleted: Bool = false,
        order: Int = 0,
        cost: Decimal? = nil,
        assignedMemberIds: [UUID] = []
    ) {
        self.id = id
        self.activityId = activityId
        self.notes = notes
        self.timeSlot = timeSlot
        self.isCompleted = isCompleted
        self.order = order
        self.cost = cost
        self.assignedMemberIds = assignedMemberIds
    }
}

public struct TripDay: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var date: Date
    public var title: String?
    public var activities: [TripActivity]
    public var notes: String?
    public var isLocked: Bool

    public init(
        id: UUID = UUID(),
        date: Date,
        title: String? = nil,
        activities: [TripActivity] = [],
        notes: String? = nil,
        isLocked: Bool = false
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.activities = activities
        self.notes = notes
        self.isLocked = isLocked
    }

    public var sortedActivities: [TripActivity] { activities.sorted { $0.order < $1.order } }
    public var completedCount: Int { activities.filter(\.isCompleted).count }
    public var totalCost: Decimal { activities.compactMap(\.cost).reduce(Decimal.zero, +) }
}

public struct Trip: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var userId: UUID
    public var title: String
    public var notes: String?
    public var destinationIds: [UUID]
    public var startDate: Date
    public var endDate: Date
    public var status: TripStatus
    public var days: [TripDay]
    public var bookingIds: [UUID]
    public var memberIds: [UUID]
    public var coverImageURL: URL?
    public var budget: Decimal?
    public var currency: Currency
    public var isShared: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        notes: String? = nil,
        destinationIds: [UUID] = [],
        startDate: Date,
        endDate: Date,
        status: TripStatus = .planned,
        days: [TripDay] = [],
        bookingIds: [UUID] = [],
        memberIds: [UUID]? = nil,
        coverImageURL: URL? = nil,
        budget: Decimal? = nil,
        currency: Currency = .usd,
        isShared: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.notes = notes
        self.destinationIds = destinationIds
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.days = days
        self.bookingIds = bookingIds
        self.memberIds = memberIds ?? [userId]
        self.coverImageURL = coverImageURL
        self.budget = budget
        self.currency = currency
        self.isShared = isShared
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var durationDays: Int {
        let cal = Calendar.current
        let comps = cal.dateComponents([.day], from: cal.startOfDay(for: startDate), to: cal.startOfDay(for: endDate))
        return max(0, comps.day ?? 0)
    }

    public var durationDisplay: String { durationDays <= 1 ? "\(durationDays) day" : "\(durationDays) days" }

    public var dateRangeDisplay: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return "\(fmt.string(from: startDate)) – \(fmt.string(from: endDate))"
    }

    public var allActivities: [TripActivity] { days.flatMap(\.activities) }

    public var progress: Double {
        guard !allActivities.isEmpty else { return 0 }
        return Double(allActivities.filter(\.isCompleted).count) / Double(allActivities.count)
    }

    public var isUpcoming: Bool { startDate > Date() && status == .planned }
    public var isActive: Bool { status == .ongoing || (Date() >= startDate && Date() <= endDate && status != .cancelled && status != .completed) }
    public var totalEstimatedCost: Decimal { days.flatMap(\.activities).compactMap(\.cost).reduce(Decimal.zero, +) }
    public var remainingBudget: Decimal? {
        guard let budget else { return nil }
        return budget - totalEstimatedCost
    }
    public var daysSorted: [TripDay] { days.sorted { $0.date < $1.date } }

    public mutating func addDay(_ day: TripDay) { days.append(day); updatedAt = Date() }
    public mutating func updateStatus(_ newStatus: TripStatus) { status = newStatus; updatedAt = Date() }

    public static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt && lhs.status == rhs.status
    }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
