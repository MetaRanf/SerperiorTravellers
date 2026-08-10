# AI Feature — AIAssistant Richer Details + Surprise Me

**Owner:** @team-ai
**Allowed:** Core/Models Destination Activity Flight AnyBooking VacationOption, Core/Services/AI AIServiceProtocol AIDetailResponse SurpriseMeRequest/Response, Core/DesignSystem

## Files
- AIAssistantViewModel.swift — @MainActor @Published messages [ChatMessage id text isUser detail? AIDetailResponse] + inputText isThinking aiService? init 1 welcome message ✨ + configure aiService + send() guards non-empty trim appends user msg clear input Task fetchDetails + fetchDetails for query heuristic if query contains destination name first -> fetchDestinationDetails else activity title -> fetchActivityDetails else generic hint + suggestions array 4 strings Kyoto etc.
- AIAssistantView.swift — env dependencies VM AIAssistantViewModel VStack ScrollView LazyVStack messages HStack leading trailing maxWidth 300 padding 12 background primary vs card shadow highlights ForEach highlights TagChip + isThinking ProgressView padding + suggestions ScrollView H TagChip tappable sets input send + HStack TextField Ask about flights bookings roundedBorder onSubmit send + arrow button arrow.up.circle.fill primary disabled empty background ignoraSafeArea navTitle AI Assistant inline .task configure aiService dependencies.aiService.

## Spec
- AI agent integration fetches richer details on given flight/booking/activity on demand → fetchFlightDetails markdown highlights + fetchBooking switch + fetchActivity + fetchDestination + generateTripSuggestions trip.
- Surprise Me also in Discovery but logic lives in MockAIService.

## DI
configure aiService latency zero. No default container.

## Testing
AIServiceTests testAIServiceZeroLatency destination markdown non-empty title, surpriseMe pet_friendly budget.

## TODOs
- Real LLM Claude API streaming, markdown rendering rich, confidence display, sources URLs tappable.
- Surprise Me UI with location + date pickers + travelers stepper + reasoning view.
