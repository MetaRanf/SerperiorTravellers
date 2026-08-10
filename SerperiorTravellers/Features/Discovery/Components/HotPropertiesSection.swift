import SwiftUI

public struct HotPropertiesSection: View {
    public let properties: [Property]
    public var onTap: (Property) -> Void = { _ in }
    public var onSave: (Property) -> Void = { _ in }

    public init(properties: [Property], onTap: @escaping (Property) -> Void = { _ in }, onSave: @escaping (Property) -> Void = { _ in }) {
        self.properties = properties; self.onTap = onTap; self.onSave = onSave
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            SectionHeader(title: "🔥 Hot stays", subtitle: "Popular homes guests love right now", showSeeAll: false)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(properties) { prop in
                        PropertyCard(property: prop, onTap: { onTap(prop) }, onWishlistTap: { onSave(prop) }).frame(width: 240)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
        }
    }
}

public struct HotActivitiesSection: View {
    public let activities: [Activity]
    public var onTap: (Activity) -> Void = { _ in }
    public init(activities: [Activity], onTap: @escaping (Activity) -> Void = { _ in }) {
        self.activities = activities; self.onTap = onTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            SectionHeader(title: "Trending experiences", subtitle: "Unique activities with local experts", showSeeAll: false)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(activities) { act in
                        ActivityCard(activity: act, onTap: { onTap(act) })
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
        }
    }
}
