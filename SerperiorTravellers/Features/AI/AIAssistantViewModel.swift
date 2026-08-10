import Foundation

@MainActor
public final class AIAssistantViewModel: ObservableObject {
    @Published public var messages: [ChatMessage] = []
    @Published public var inputText: String = ""
    @Published public var isThinking = false

    private var aiService: AIServiceProtocol?

    public struct ChatMessage: Identifiable, Equatable {
        public let id: UUID; public var text: String; public var isUser: Bool; public var detail: AIDetailResponse?
        public init(id: UUID = UUID(), text: String, isUser: Bool, detail: AIDetailResponse? = nil) { self.id = id; self.text = text; self.isUser = isUser; self.detail = detail }
    }

    public init() {
        messages = [ChatMessage(text: "Hi! I'm your Serperior AI travel assistant ✨ Ask me about any flight, booking, or activity.", isUser: false)]
    }

    public func configure(aiService: AIServiceProtocol) { self.aiService = aiService }

    public func send() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let text = inputText
        messages.append(ChatMessage(text: text, isUser: true))
        inputText = ""
        Task { await fetchDetails(for: text) }
    }

    public func fetchDetails(for query: String) async {
        guard let aiService else { return }
        isThinking = true
        // Simple heuristic: if query mentions destination
        if let dest = MockDataProvider.destinations.first(where: { query.localizedCaseInsensitiveContains($0.name) }) {
            if let detail = try? await aiService.fetchDestinationDetails(destination: dest) {
                messages.append(ChatMessage(text: detail.markdown, isUser: false, detail: detail))
            }
        } else if let act = MockDataProvider.activities.first(where: { query.localizedCaseInsensitiveContains($0.title) }) {
            if let detail = try? await aiService.fetchActivityDetails(activity: act) {
                messages.append(ChatMessage(text: detail.markdown, isUser: false, detail: detail))
            }
        } else {
            messages.append(ChatMessage(text: "I can fetch richer details on flights, bookings, or activities on demand. Try asking 'Tell me about Kyoto' or 'Details for Fushimi hike'.", isUser: false))
        }
        isThinking = false
    }

    public var suggestions: [String] = ["Tell me about Kyoto", "Details for Bali properties", "Surprise me trip under $2000", "Fushimi Inari hike details"]
}
