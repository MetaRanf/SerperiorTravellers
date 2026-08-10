# Alerts Feature — Weather & News + Price + Booking

**Owner:** @team-alerts
**Allowed:** Core/Models AlertType AlertSeverity WeatherAlert NewsAlert AppAlert SimpleAppAlert, Core/Services/Alerts AlertServiceProtocol, Core/DesignSystem TagChip

## Files
- AlertsView.swift — env dependencies alerts [AppAlert] filter AlertType? filtered computed if filter nil else filter type, load async via MockAlertService fetchAllAlerts userId currentUser id, markRead via dependencies.alertService markAsRead + reload, severityColor mapping info blue low success green medium warning orange high orange critical error, ScrollView H filter chips All isSelected nil + AlertType.allCases title icon isSelected filter==type + List ForEach filtered VStack HStack Image systemName severity color title headlineSmall Spacer if !isRead Circle primary 8 + message subheadline secondary + timestamp caption2 tertiary padding vertical swipeActions Read tint blue background grouped navTitle Alerts inline .task load.

## Spec
- Weather and news alerts for vacation location → fetchWeatherAlerts destinationId + fetchNewsAlerts.
- Alerts also booking price drop trip system.

## DI
MockAlertService latency zero. Preload 4 alerts weather high Bali, news low Kyoto cherry blossom, booking medium check-in reminder, price low -12%.

## Testing
AIServiceTests testAlertServiceZeroLatency all non-empty contains weather price.

## TODOs
- Real OpenWeather API + News API, severity icons, grouping by trip, unread count badge, notifications enable toggle via UserPreferences.
