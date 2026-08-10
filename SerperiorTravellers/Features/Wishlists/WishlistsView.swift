import SwiftUI

public struct WishlistsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var viewModel = WishlistViewModel()
    @State private var showCreate = false

    public init() {}

    public var body: some View {
        Group {
            if viewModel.wishlists.isEmpty {
                EmptyStateView(title: "No wishlists yet", subtitle: "Save destinations organized by Location or Vacation type like family-friendly and pet-friendly.", actionTitle: "Create wishlist") { showCreate = true }
            } else {
                List {
                    Section {
                        ForEach(viewModel.wishlists) { wl in
                            NavigationLink(value: wl) {
                                WishlistRow(wishlist: wl)
                            }
                        }.onDelete { offsets in
                            offsets.forEach { idx in
                                let id = viewModel.wishlists[idx].id
                                viewModel.deleteWishlist(id: id)
                            }
                        }
                    } header: {
                        Text("\(viewModel.wishlists.count) wishlists")
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(AppColors.groupedBackground.ignoresSafeArea())
        .navigationTitle("Wishlists")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showCreate) {
            AddEditWishlistView { title, desc, type in
                viewModel.createWishlist(title: title, description: desc, type: type, userId: appState.currentUser?.id ?? UUID())
            }
        }
        .task { viewModel.configure(storage: dependencies.storageService) }
    }
}

public struct WishlistRow: View {
    let wishlist: Wishlist
    public var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: wishlist.coverImageURL) { phase in
                switch phase { case .success(let img): img.resizable().scaledToFill().frame(width: 64, height: 64).clipped().clipShape(RoundedRectangle(cornerRadius: 10)) default: RoundedRectangle(cornerRadius: 10).fill(AppColors.backgroundSecondary).frame(width: 64, height: 64) }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(wishlist.title).typography(AppTypography.headline)
                Text("\(wishlist.itemCount) saves • \(wishlist.type.displayName)").typography(AppTypography.caption1, color: AppColors.textSecondary)
                HStack(spacing: 4) { BadgeView(text: wishlist.type.displayName, style: .category) }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

public struct WishlistDetailView: View {
    public let wishlist: Wishlist
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var viewModel = WishlistViewModel()

    public init(wishlist: Wishlist) { self.wishlist = wishlist }

    public var body: some View {
        List {
            Section("Items") {
                ForEach(wishlist.items, id: \.id) { item in
                    HStack {
                        Image(systemName: item.kind == .destination ? "map" : item.kind == .property ? "bed.double" : "ticket")
                        Text(item.kind.rawValue.capitalized).typography(AppTypography.body)
                        Spacer()
                        Text(item.addedAt.formatted(date: .abbreviated, time: .omitted)).typography(AppTypography.caption1, color: AppColors.textSecondary)
                    }
                }
            }
        }
        .navigationTitle(wishlist.title)
        .background(AppColors.groupedBackground)
    }
}

public struct AddEditWishlistView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var descriptionText = ""
    @State private var type: WishlistType = .location
    public var onSave: (String, String?, WishlistType) -> Void

    public init(onSave: @escaping (String, String?, WishlistType) -> Void) { self.onSave = onSave }

    public var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $descriptionText)
                Picker("Type", selection: $type) {
                    ForEach(WishlistType.allCases) { t in Text(t.displayName).tag(t) }
                }
                Section("Organization") {
                    Text("Save by Location or Vacation type (family-friendly, pet-friendly)").typography(AppTypography.caption1, color: AppColors.textSecondary)
                }
            }
            .navigationTitle("New Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, descriptionText.isEmpty ? nil : descriptionText, type)
                        dismiss()
                    }.disabled(title.isEmpty)
                }
            }
        }
    }
}
