import Foundation

public enum Currency: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case aud = "AUD"
    case cad = "CAD"
    case inr = "INR"
    case aed = "AED"

    public var id: String { rawValue }

    public var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .aud: return "A$"
        case .cad: return "C$"
        case .inr: return "₹"
        case .aed: return "AED"
        }
    }

    public var displayName: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .aud: return "Australian Dollar"
        case .cad: return "Canadian Dollar"
        case .inr: return "Indian Rupee"
        case .aed: return "UAE Dirham"
        }
    }
}

public struct Money: Codable, Equatable, Sendable, Hashable {
    public var amount: Decimal
    public var currency: Currency

    public init(amount: Decimal, currency: Currency = .usd) {
        self.amount = amount
        self.currency = currency
    }

    public init(_ double: Double, currency: Currency = .usd) {
        self.amount = Decimal(double)
        self.currency = currency
    }

    public var doubleValue: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }

    public var formatted: String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = currency.rawValue
        fmt.maximumFractionDigits = 2
        return fmt.string(from: NSDecimalNumber(decimal: amount)) ?? "\(currency.symbol)\(amount)"
    }

    public static func + (lhs: Money, rhs: Money) -> Money {
        guard lhs.currency == rhs.currency else { return lhs }
        return Money(amount: lhs.amount + rhs.amount, currency: lhs.currency)
    }

    public static func - (lhs: Money, rhs: Money) -> Money {
        guard lhs.currency == rhs.currency else { return lhs }
        return Money(amount: lhs.amount - rhs.amount, currency: lhs.currency)
    }
}
