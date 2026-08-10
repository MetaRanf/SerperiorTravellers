# Maps Feature — Location Map + Pins + Suggested Route

**Owner:** @team-maps
**Allowed:** Core/Models GeoCoordinate Destination Property Activity Trip, Core/Services/Maps MapPin SuggestedRoute, Core/DesignSystem, MapKit CoreLocation, AppConstants INFOPLIST_KEY

## Files
- MapsView.swift — Picker Destination menu ForEach destinations tag optional id + Map { ForEach pins Annotation pin.title coordinate clCoordinate VStack systemName ticket.fill vs bed.double.fill vs mappin.circle.fill foreground accent vs primary background white circle title caption2 ultraThinMaterial rounded + MapPolyline coordinates polyline map color primary lineWidth4 } mapStyle standard frame maxHeight + route footer VStack suggested route stops distance min + horizontal TagChip pins title + background cardBackground navigationTitle Maps & Routing inline .task configure service dependencies.mapsService onChange selectedDestinationId loadPins.
- MapsViewModel.swift — pins [MapPin] route SuggestedRoute? selectedDestinationId? first dest + isLoading mapsService? configure + loadPins async getPins destinationId + suggestedRoute first trip + loadTripPins tripId getPins trip + suggestedRoute trip.

## Spec
- Location map showing user location + destinations → Map + NSLocationWhenInUseUsageDescription build setting in project.yml GENERATE_INFOPLIST because no Info.plist.
- Pins activity as pins + suggested route connecting → MapPin type property/activity/destination + SuggestedRoute pins polyline totalDistance formattedDistance estimatedDuration.

## DI
configure(service: MapsServiceProtocol) via env dependencies. MockMapsService latency zero distance via GeoCoordinate.distance.

## TODOs
- Show user location dot + request authorization.
- Real routing MKDirections polyline decoding.
- Clustering pins.

## Testing
AIServiceTests testMapsServiceZeroLatency pins non-empty + calculateRoute.
