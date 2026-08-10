import SwiftUI

protocol CarouselItem: Identifiable {}

enum PageIndicatorStyle {
    case dots
    case pill
    case number
    case none
}

struct CarouselView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    var spacing: CGFloat = AppLayout.carouselSpacing
    var peek: CGFloat = 0
    var showIndicators: Bool = true
    var indicatorStyle: PageIndicatorStyle = .dots
    @ViewBuilder var content: (Item) -> Content

    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                    content(item)
                        .tag(idx)
                        .padding(.horizontal, peek > 0 ? peek : 0)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 320)

            if showIndicators && items.count > 1 {
                indicators
            }
        }
    }

    @ViewBuilder
    private var indicators: some View {
        switch indicatorStyle {
        case .dots:
            HStack(spacing: 6) {
                ForEach(0..<items.count, id: \.self) { idx in
                    Circle()
                        .fill(idx == currentIndex ? AppColors.textPrimary : AppColors.border)
                        .frame(width: idx == currentIndex ? 20 : 6, height: 6)
                }
            }
        case .pill:
            HStack(spacing: 4) {
                ForEach(0..<items.count, id: \.self) { idx in
                    Capsule().fill(idx == currentIndex ? AppColors.textPrimary : AppColors.border)
                        .frame(width: idx == currentIndex ? 20 : 6, height: 4)
                }
            }
        case .number:
            Text("\(currentIndex + 1) / \(items.count)")
                .font(AppTypography.caption1Semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.black.opacity(0.6)).clipShape(Capsule())
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Image Carousel for property images
struct ImageCarouselView: View {
    let images: [String]
    var cornerRadius: CGFloat = AppCornerRadius.m
    var showWishlist: Bool = true
    var isWishlisted: Bool = false
    var onWishlistTap: (() -> Void)? = nil
    var onImageTap: ((Int) -> Void)? = nil

    @State private var currentIndex = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                    AsyncImage(url: URL(string: img)) { phase in
                        switch phase {
                        case .success(let i): i.resizable().scaledToFill()
                        default: Rectangle().fill(AppColors.backgroundSecondary)
                        }
                    }
                    .tag(idx)
                    .onTapGesture { onImageTap?(idx) }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if images.count > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<min(images.count, 5), id: \.self) { idx in
                        Circle().fill(idx == currentIndex ? .white : Color.white.opacity(0.6)).frame(width: 6, height: 6)
                    }
                    if images.count > 5 {
                        Text("+\(images.count - 5)").font(AppTypography.caption2Medium).foregroundStyle(.white)
                    }
                }.padding(.bottom, 10)
            }

            if showWishlist {
                VStack {
                    HStack {
                        Spacer()
                        Button { onWishlistTap?() } label: {
                            Image(systemName: isWishlisted ? "heart.fill" : "heart")
                                .foregroundStyle(isWishlisted ? AppColors.primary : .white)
                                .padding(8).background(.ultraThinMaterial, in: Circle())
                        }.padding(12)
                    }
                    Spacer()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
