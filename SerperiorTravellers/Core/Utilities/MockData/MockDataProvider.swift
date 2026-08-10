import Foundation

public enum MockDataProvider {
    // MARK: - Destinations

    public static let destinations: [Destination] = [
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
            name: "Bali",
            country: "Indonesia",
            countryCode: "ID",
            description: "Tropical paradise with lush jungles, sacred temples and world-class surf. Perfect for wellness and adventure.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800")!],
            coordinates: GeoCoordinate(latitude: -8.4095, longitude: 115.1889),
            rating: 4.9,
            reviewCount: 18234,
            isTrending: true,
            tags: ["beach", "tropical", "wellness", "family", "pet_friendly"],
            continent: "Asia",
            bestMonths: [4,5,6,9,10]
        ),
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
            name: "Kyoto",
            country: "Japan",
            countryCode: "JP",
            description: "Ancient temples, bamboo forests and timeless tea houses. Cultural heart of Japan.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800")!],
            coordinates: GeoCoordinate(latitude: 35.0116, longitude: 135.7681),
            rating: 4.9,
            reviewCount: 12483,
            isTrending: true,
            tags: ["cultural", "historic", "nature"],
            continent: "Asia",
            bestMonths: [3,4,10,11]
        ),
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000103")!,
            name: "Santorini",
            country: "Greece",
            countryCode: "GR",
            description: "Whitewashed cliffs, blue domes and sunsets that stop time. Luxury island escape.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=800")!],
            coordinates: GeoCoordinate(latitude: 36.3932, longitude: 25.4615),
            rating: 4.8,
            reviewCount: 9452,
            isTrending: true,
            tags: ["luxury", "beach", "romance"],
            continent: "Europe",
            bestMonths: [5,6,9,10]
        ),
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000104")!,
            name: "Banff",
            country: "Canada",
            countryCode: "CA",
            description: "Majestic Rockies, turquoise lakes and wilderness adventures.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800")!],
            coordinates: GeoCoordinate(latitude: 51.1784, longitude: -115.5708),
            rating: 4.85,
            reviewCount: 7321,
            isTrending: false,
            tags: ["mountain", "adventure", "nature"],
            continent: "North America",
            bestMonths: [6,7,8,12,1,2]
        ),
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000105")!,
            name: "Tulum",
            country: "Mexico",
            countryCode: "MX",
            description: "Mayan ruins, cenotes and boho beach clubs on the Riviera Maya.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1518638150340-f706e86654b8?w=800")!],
            coordinates: GeoCoordinate(latitude: 20.2110, longitude: -87.4654),
            rating: 4.7,
            reviewCount: 6543,
            isTrending: true,
            tags: ["beach", "culture", "budget"],
            continent: "North America",
            bestMonths: [11,12,1,2,3,4]
        ),
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000106")!,
            name: "Swiss Alps",
            country: "Switzerland",
            countryCode: "CH",
            description: "Alpine charm, ski slopes and chocolate-box villages.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1491555103944-7c647fd857e6?w=800")!],
            coordinates: GeoCoordinate(latitude: 46.8182, longitude: 8.2275),
            rating: 4.9,
            reviewCount: 5432,
            isTrending: false,
            tags: ["mountain", "winter", "luxury"],
            continent: "Europe",
            bestMonths: [12,1,2,6,7,8]
        ),
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000107")!,
            name: "New York",
            country: "USA",
            countryCode: "US",
            description: "The city that never sleeps — Broadway, museums and skyline views.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1490644658840-3f2e3f8c5625?w=800")!],
            coordinates: GeoCoordinate(latitude: 40.7128, longitude: -74.0060),
            rating: 4.6,
            reviewCount: 22345,
            isTrending: true,
            tags: ["city", "culture", "luxury"],
            continent: "North America",
            bestMonths: [4,5,9,10,11]
        )
    ]

    // MARK: - Properties

    public static let properties: [Property] = {
        let kyoto = destinations[1].id
        let bali = destinations[0].id
        let santorini = destinations[2].id
        let nyc = destinations[6].id
        return [
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                title: "Machiya Townhouse in Gion",
                destinationId: kyoto,
                type: .villa,
                pricePerNight: Decimal(320),
                currency: .usd,
                rating: 4.96,
                reviewCount: 128,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800")!],
                amenities: [.wifi, .kitchen, .ac, .laundry],
                coordinates: GeoCoordinate(latitude: 35.0016, longitude: 135.7753),
                isSuperhost: true,
                isTrending: true,
                description: "Traditional wooden townhouse with garden, steps from Yasaka Shrine.",
                maxGuests: 4, bedrooms: 2, beds: 3, bathrooms: 1
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                title: "Cliffside Infinity Villa • Oia",
                destinationId: santorini,
                type: .villa,
                pricePerNight: Decimal(890),
                currency: .usd,
                rating: 4.98,
                reviewCount: 87,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800")!],
                amenities: [.pool, .wifi, .kitchen, .beachfront, .spa],
                coordinates: GeoCoordinate(latitude: 36.4618, longitude: 25.3753),
                isSuperhost: true,
                isTrending: true,
                description: "Private pool, caldera view, sunset terrace.",
                maxGuests: 6, bedrooms: 3, beds: 4, bathrooms: 3.5
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                title: "Jungle Treehouse Retreat",
                destinationId: bali,
                type: .cabin,
                pricePerNight: Decimal(185),
                currency: .usd,
                rating: 4.91,
                reviewCount: 342,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800")!],
                amenities: [.wifi, .pool, .kitchen],
                coordinates: GeoCoordinate(latitude: -8.4095, longitude: 115.1889),
                isSuperhost: false,
                isTrending: true,
                description: "Open-air bamboo treehouse in Ubud rice terraces.",
                maxGuests: 2, bedrooms: 1, beds: 1, bathrooms: 1
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                title: "SoHo Loft with Skyline View",
                destinationId: nyc,
                type: .apartment,
                pricePerNight: Decimal(420),
                currency: .usd,
                rating: 4.85,
                reviewCount: 512,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800")!],
                amenities: [.wifi, .workspace, .ac, .kitchen],
                coordinates: GeoCoordinate(latitude: 40.7230, longitude: -74.0020),
                isSuperhost: true,
                isTrending: false,
                description: "Designer loft, exposed brick, 24h doorman.",
                maxGuests: 3, bedrooms: 1, beds: 2, bathrooms: 1
            )
        ]
    }()

    // MARK: - Activities

    public static let activities: [Activity] = {
        let kyoto = destinations[1].id
        let bali = destinations[0].id
        let santorini = destinations[2].id
        return [
            Activity(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
                title: "Fushimi Inari Sunrise Hike",
                destinationId: kyoto,
                description: "Walk through thousands of vermillion torii gates before crowds arrive. Includes tea ceremony.",
                category: .nature,
                price: Decimal(45),
                currency: .usd,
                duration: ActivityDuration(minutes: 180),
                rating: 4.9,
                reviewCount: 892,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?w=800")!],
                coordinates: GeoCoordinate(latitude: 34.9671, longitude: 135.7727),
                isHot: true,
                recommendedSeason: .spring,
                tags: ["hiking", "culture"]
            ),
            Activity(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000002")!,
                title: "Ubud Monkey Forest & Rice Terrace",
                destinationId: bali,
                description: "Private driver tour through sacred monkey forest, Tegallalang terraces and coffee plantation.",
                category: .sightseeing,
                price: Decimal(65),
                currency: .usd,
                duration: ActivityDuration(hours: 8),
                rating: 4.8,
                reviewCount: 723,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=800")!],
                coordinates: GeoCoordinate(latitude: -8.5197, longitude: 115.2633),
                isHot: true,
                recommendedSeason: .allYear,
                tags: ["nature", "family"]
            ),
            Activity(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000003")!,
                title: "Caldera Sailing & Volcano Hot Springs",
                destinationId: santorini,
                description: "Luxury catamaran, BBQ, swim in volcanic hot springs at sunset.",
                category: .adventure,
                price: Decimal(120),
                currency: .usd,
                duration: ActivityDuration(hours: 5),
                rating: 4.95,
                reviewCount: 654,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=800")!],
                coordinates: GeoCoordinate(latitude: 36.3932, longitude: 25.4615),
                isHot: true,
                recommendedSeason: .summer,
                tags: ["sailing", "luxury"]
            ),
            Activity(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000004")!,
                title: "Pet-Friendly Beach Day",
                destinationId: bali,
                description: "Bring your furry friend to a private dog-friendly beach with amenities.",
                category: .family,
                price: Decimal(30),
                currency: .usd,
                duration: ActivityDuration(hours: 4),
                rating: 4.7,
                reviewCount: 210,
                imageURLs: [URL(string: "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=800")!],
                coordinates: GeoCoordinate(latitude: -8.4095, longitude: 115.1889),
                isHot: false,
                recommendedSeason: .allYear,
                tags: ["pet_friendly", "beach"]
            )
        ]
    }()

    // MARK: - Users

    public static let currentUser = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
        name: "Alex Traveller",
        email: "alex@serperior.app",
        avatarURL: nil,
        createdAt: Date().addingTimeInterval(-86400*120),
        preferences: .default,
        isVerified: true,
        isPremium: true
    )

    public static let collaborators: [User] = [
        User(id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!, name: "Sam Lee", email: "sam@example.com"),
        User(id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!, name: "Jordan Silva", email: "jordan@example.com"),
        User(id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!, name: "Maya Patel", email: "maya@example.com")
    ]

    // MARK: - Wishlists

    public static let wishlists: [Wishlist] = [
        Wishlist(
            id: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!,
            userId: currentUser.id,
            title: "Bali Dreams",
            description: "Rice terraces and wellness",
            type: .location,
            items: [
                WishlistItem.destinationItem(destinationId: destinations[0].id),
                WishlistItem.propertyItem(propertyId: properties[2].id, destinationId: destinations[0].id)
            ],
            coverImageURL: destinations[0].coverImageURL,
            createdAt: Date().addingTimeInterval(-86400*10),
            updatedAt: Date().addingTimeInterval(-86400*2)
        ),
        Wishlist(
            id: UUID(uuidString: "30000000-0000-0000-0000-000000000002")!,
            userId: currentUser.id,
            title: "Family Friendly",
            description: "Kid-approved stays including pet friendly",
            type: .vacationType,
            items: [
                WishlistItem.activityItem(activityId: activities[1].id, destinationId: destinations[0].id)
            ],
            coverImageURL: destinations[1].coverImageURL,
            createdAt: Date().addingTimeInterval(-86400*5),
            updatedAt: Date().addingTimeInterval(-86400*1)
        ),
        Wishlist(
            id: UUID(uuidString: "30000000-0000-0000-0000-000000000003")!,
            userId: currentUser.id,
            title: "Pet Adventures",
            description: "Travel with your best friend",
            type: .vacationType,
            items: [
                WishlistItem.activityItem(activityId: activities[3].id, destinationId: destinations[0].id)
            ],
            coverImageURL: destinations[0].coverImageURL,
            createdAt: Date().addingTimeInterval(-86400*2),
            updatedAt: Date().addingTimeInterval(-86400*1)
        )
    ]

    // MARK: - Trips

    public static let trips: [Trip] = {
        let now = Date()
        let start = Calendar.current.date(byAdding: .day, value: 14, to: now)!
        let end = Calendar.current.date(byAdding: .day, value: 21, to: now)!
        return [
            Trip(
                id: UUID(uuidString: "40000000-0000-0000-0000-000000000001")!,
                userId: currentUser.id,
                title: "Kyoto Cherry Blossom Week",
                notes: "Book tea ceremony + ryokan",
                destinationIds: [destinations[1].id],
                startDate: start,
                endDate: end,
                status: .planned,
                days: [
                    TripDay(
                        id: UUID(),
                        date: start,
                        title: "Arrival + Gion",
                        activities: [
                            TripActivity(id: UUID(), activityId: activities[0].id, order: 0)
                        ]
                    ),
                    TripDay(
                        id: UUID(),
                        date: Calendar.current.date(byAdding: .day, value: 1, to: start)!,
                        title: "Arashiyama Day",
                        activities: []
                    )
                ],
                budget: Decimal(3500),
                currency: .usd,
                isShared: true,
                createdAt: now.addingTimeInterval(-86400*3),
                updatedAt: now
            ),
            Trip(
                id: UUID(uuidString: "40000000-0000-0000-0000-000000000002")!,
                userId: currentUser.id,
                title: "Bali Wellness Escape",
                destinationIds: [destinations[0].id],
                startDate: Calendar.current.date(byAdding: .day, value: -5, to: now)!,
                endDate: Calendar.current.date(byAdding: .day, value: 2, to: now)!,
                status: .ongoing,
                days: [],
                budget: Decimal(2800),
                currency: .usd,
                isShared: false
            )
        ]
    }()

    // MARK: - Vacation Options for Carousel (deterministic prices)

    public static let vacationOptions: [VacationOption] = {
        let estimates: [Decimal] = [1800, 2400, 3200, 1200, 2100]
        return destinations.prefix(5).enumerated().map { idx, dest in
            let props = properties.filter { $0.destinationId == dest.id }
            let acts = activities.filter { $0.destinationId == dest.id }
            return VacationOption(
                id: dest.id,
                destination: dest,
                featuredProperties: props,
                featuredActivities: acts,
                totalPriceEstimate: estimates[idx % estimates.count],
                currency: .usd,
                nights: 5,
                tagline: dest.isTrending ? "🔥 Trending • \(dest.name)" : dest.name
            )
        }
    }()

    public static let sampleBookings: [AnyBooking] = {
        var result: [AnyBooking] = []
        let userId = currentUser.id
        if let hotel = MockBookingFactory.makeHotels().first {
            let hb = HotelBooking(hotel: hotel, userId: userId, status: .confirmed, confirmationCode: "HTL-123456")
            result.append(.hotel(hb))
        }
        if let flight = MockBookingFactory.makeFlights().first {
            let fb = FlightBooking(outbound: flight, price: flight.price, userId: userId, status: .confirmed, confirmationCode: "FLT-654321")
            result.append(.flight(fb))
        }
        return result
    }()

    // Helper factory for bookings independent of service
    public enum MockBookingFactory {
        public static func makeHotels() -> [Hotel] {
            return [
                Hotel(
                    id: UUID(uuidString: "50000000-0000-0000-0000-000000000001")!,
                    propertyId: destinations[1].id,
                    name: "Park Hyatt Kyoto",
                    checkIn: Date(),
                    checkOut: Date().addingTimeInterval(86400*2),
                    pricePerNight: Money(amount: Decimal(820), currency: .usd),
                    totalPrice: Money(amount: Decimal(1640), currency: .usd),
                    guests: 2,
                    rooms: 1
                ),
                Hotel(
                    id: UUID(uuidString: "50000000-0000-0000-0000-000000000002")!,
                    propertyId: destinations[6].id,
                    name: "1 Hotel San Francisco",
                    checkIn: Date(),
                    checkOut: Date().addingTimeInterval(86400*3),
                    pricePerNight: Money(amount: Decimal(425), currency: .usd),
                    totalPrice: Money(amount: Decimal(1275), currency: .usd),
                    guests: 2,
                    rooms: 1
                )
            ]
        }

        public static func makeFlights() -> [Flight] {
            let now = Date()
            return [
                Flight(
                    id: UUID(uuidString: "60000000-0000-0000-0000-000000000001")!,
                    airline: "Japan Airlines",
                    flightNumber: "JL001",
                    fromCode: "SFO",
                    toCode: "HND",
                    departureAt: now.addingTimeInterval(86400*7),
                    arrivalAt: now.addingTimeInterval(86400*7 + 3600*11),
                    durationMinutes: 660,
                    price: Money(amount: Decimal(1245), currency: .usd),
                    cabinClass: "Economy",
                    stops: 0
                ),
                Flight(
                    id: UUID(uuidString: "60000000-0000-0000-0000-000000000002")!,
                    airline: "United",
                    flightNumber: "UA837",
                    fromCode: "SFO",
                    toCode: "NRT",
                    departureAt: now.addingTimeInterval(86400*8),
                    arrivalAt: now.addingTimeInterval(86400*8 + 3600*10),
                    durationMinutes: 600,
                    price: Money(amount: Decimal(980), currency: .usd),
                    cabinClass: "Economy",
                    stops: 0
                )
            ]
        }

        public static func makeCars() -> [CarRental] {
            return [
                CarRental(
                    id: UUID(uuidString: "70000000-0000-0000-0000-000000000001")!,
                    company: "Hertz",
                    carModel: "Toyota Camry",
                    carType: "Sedan",
                    pickupLocation: "SFO Airport",
                    dropoffLocation: "SFO Airport",
                    pickupDate: Date(),
                    dropoffDate: Date().addingTimeInterval(86400*3),
                    price: Money(amount: Decimal(189), currency: .usd)
                )
            ]
        }
    }
}
