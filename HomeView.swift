import SwiftUI

// MARK: - Data

private let CATEGORIES: [(label: String, icon: String, q: String)] = [
    ("Cars & Vehicles",   "car.fill",              "car accessories"),
    ("Computing",         "laptopcomputer",         "laptop"),
    ("Headphones",        "headphones",             "headphones"),
    ("Entertainment",     "gamecontroller.fill",    "lego"),
    ("Fashion",           "tshirt.fill",            "shoes"),
    ("Food & Drink",      "cup.and.saucer.fill",    "coffee"),
    ("Health & Beauty",   "heart.fill",             "skincare"),
    ("Home & Furniture",  "sofa.fill",              "bedding"),
]

private let STORIES: [(name: String, domain: String, q: String)] = [
    ("Samsung",      "samsung.com",      "Samsung"),
    ("Adidas",       "adidas.com",       "Adidas"),
    ("LG",           "lg.com",           "lg"),
    ("Lego",         "lego.com",         "lego"),
    ("Nike",         "nike.com",         "nike"),
    ("Sony",         "sony.com",         "sony"),
    ("Dyson",        "dyson.com",        "dyson"),
    ("Under Armour", "underarmour.com",  "under armour"),
    ("Burberry",     "burberry.com",     "burberry"),
]

private let BANNERS: [(emoji: String, kicker: String, title: String, text: String, q: String)] = [
    ("💻", "Best Deals", "Laptops & Tablets", "Compare hundreds of models across top stores.", "laptop"),
    ("👟", "New Season", "Shoes & Fashion", "Find the best price on the latest styles.", "shoes"),
]

private let FEATURED: [(title: String, q: String)] = [
    ("Bedding & Linen", "duvet"),
    ("Laptops",         "laptop"),
    ("Coffee Machines", "nespresso"),
    ("TVs",             "oled tv"),
    ("Air Conditioners","air conditioner"),
]

// MARK: - HomeView

struct HomeView: View {
    @State private var searchQuery = ""
    @State private var navigate    = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection
                brandStoriesSection
                categoriesSection
                ForEach(FEATURED, id: \.title) { shelf in
                    ShelfSection(title: shelf.title, query: shelf.q)
                }
                footerSection
            }
        }
        .background(PF.bg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) { logoView } }
        .navigationDestination(isPresented: $navigate) {
            SearchView(initialQuery: searchQuery)
        }
    }

    // MARK: Logo
    private var logoView: some View {
        HStack(spacing: 6) {
            Text("🦊")
                .font(.system(size: 26))
            VStack(alignment: .leading, spacing: 0) {
                Text("PriceFoxy")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(PF.orange)
                Text("Compare. Save.")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(PF.muted)
            }
        }
    }

    // MARK: Hero  (mirrors .hero { background:#dbeff0 })
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Find. Compare.\nSave.")
                .font(.system(size: 38, weight: .black, design: .serif))
                .foregroundStyle(Color(hex: "#1f2937"))
                .lineSpacing(2)

            Text("PriceFoxy: Compare prices and go directly to the store.")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "#334155"))

            // Search bar (mirrors .searchbar)
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(PF.muted)
                    TextField("Search iPhone, laptop, TV…", text: $searchQuery)
                        .font(.system(size: 16))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit { if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty { navigate = true } }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(PF.line, lineWidth: 1.5))

                Button {
                    if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty { navigate = true }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(PF.orange)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#dbeff0"))
    }

    // MARK: Brand Stories  (mirrors .brand-stories)
    private var brandStoriesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(STORIES, id: \.name) { s in
                        NavigationLink(destination: SearchView(initialQuery: s.q)) {
                            BrandStoryBubble(name: s.name, domain: s.domain)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
        }
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: Promo Banners  (mirrors .promo-banner dark gradient cards)
    private var promoBannersSection: some View {
        VStack(spacing: 12) {
            ForEach(BANNERS, id: \.title) { b in
                NavigationLink(destination: SearchView(initialQuery: b.q)) {
                    PromoBanner(emoji: b.emoji, kicker: b.kicker, title: b.title, text: b.text)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
    }

    // MARK: Categories  (mirrors .cats-row)
    private var categoriesSection: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(CATEGORIES, id: \.label) { cat in
                        NavigationLink(destination: SearchView(initialQuery: cat.q)) {
                            CategoryChip(icon: cat.icon, label: cat.label)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: Footer
    private var footerSection: some View {
        Text("© PriceFoxy. All rights reserved.")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(PF.muted)
            .padding(.vertical, 24)
    }
}

// MARK: - Brand Story Bubble  (mirrors .story-logo gradient ring)

struct BrandStoryBubble: View {
    let name: String
    let domain: String

    var faviconURL: URL? {
        URL(string: "https://www.google.com/s2/favicons?domain=\(domain)&sz=128")
    }

    var body: some View {
        VStack(spacing: 8) {
            // gradient ring
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [PF.orange, Color(hex: "#ff9a3d")],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: PF.orange.opacity(0.3), radius: 8, x: 0, y: 4)

                Circle()
                    .fill(Color.white)
                    .frame(width: 62, height: 62)

                AsyncImage(url: faviconURL) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFit()
                    } else {
                        Text(String(name.prefix(1)))
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(PF.orange)
                    }
                }
                .frame(width: 42, height: 42)
                .clipShape(Circle())
            }

            Text(name)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Color(hex: "#334155"))
                .lineLimit(1)
                .frame(width: 72)
        }
    }
}

// MARK: - Promo Banner  (mirrors .promo-banner dark gradient)

struct PromoBanner: View {
    let emoji: String
    let kicker: String
    let title: String
    let text: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // dark gradient background
            RoundedRectangle(cornerRadius: PF.radiusLg)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "#111827"), location: 0),
                            .init(color: Color(hex: "#26364f"), location: 0.55),
                            .init(color: PF.orange,             location: 1.3),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // emoji top-right
            Text(emoji)
                .font(.system(size: 64))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 20)
                .padding(.top, 18)
                .shadow(radius: 8)

            // content
            VStack(alignment: .leading, spacing: 8) {
                Text(kicker.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)

                Text(title)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)
                    .lineSpacing(1)

                Text(text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .lineLimit(2)

                Text("Compare now →")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Color(hex: "#111827"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(22)
            .frame(maxWidth: .infinity * 0.72, alignment: .leading)
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: PF.radiusLg))
        .pfShadow()
    }
}

// MARK: - Category Chip  (mirrors .cat)

struct CategoryChip: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(PF.text)
                .frame(height: 28)

            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(PF.text)
                .underline()
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 90)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Shelf Section  (mirrors homepage product shelves)

struct ShelfSection: View {
    let title: String
    let query: String
    @StateObject private var vm = ProductSearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // section head  (mirrors .section-head)
            HStack {
                Text(title)
                    .font(.system(size: 24, weight: .black, design: .serif))
                    .foregroundStyle(PF.text)
                Spacer()
                NavigationLink(destination: SearchView(initialQuery: query)) {
                    Text("See all →")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(PF.muted)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 22)
            .padding(.bottom, 10)

            if vm.isLoading && vm.items.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(0..<4, id: \.self) { _ in ShelfCardSkeleton() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(vm.items.prefix(12)) { item in
                            NavigationLink(destination: ProductDetailView(initialProduct: item)) {
                                ShelfCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                }
            }
        }
        .background(PF.bg)
        .task {
            vm.query = query
            await vm.submitSearch()
        }
    }
}

// MARK: - Shelf Card  (mirrors .s-card  220px wide)

struct ShelfCard: View {
    let item: ProductItem

    private var totalOffers: Int {
        if let nb = item.nbOffers, nb > 0 {
            return nb
        }

        if let offers = item.offers, !offers.isEmpty {
            return offers.count
        }

        return 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: item.image ?? "")) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(PF.muted)
                default:
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color(hex: "#f8fafc"))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 13, weight: .black))
                    .lineLimit(2)
                    .foregroundStyle(PF.text)
                    .frame(minHeight: 34, alignment: .top)

                Text(formatPrice(item.price, currency: item.currency))
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(PF.text)

                Text("\(totalOffers) offers")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(PF.orange)

                HStack(spacing: 6) {
                    StoreIcon(url: item.merchantLogo, domain: item.storeDomain, size: 16)

                    Text(item.merchantName ?? item.storeDomain ?? "")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(PF.muted)
                        .lineLimit(1)
                }
            }
            .padding(11)
        }
        .frame(width: 170)
        .background(PF.card)
        .clipShape(RoundedRectangle(cornerRadius: PF.radius))
        .overlay(RoundedRectangle(cornerRadius: PF.radius).stroke(PF.line, lineWidth: 1))
        .pfShadow()
    }
}
struct ShelfCardSkeleton: View {
    @State private var anim = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(Color(hex: "#f1f5f9")).frame(width: 170, height: 150)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6).fill(Color(hex: "#e5e7eb")).frame(height: 12)
                RoundedRectangle(cornerRadius: 6).fill(Color(hex: "#e5e7eb")).frame(width: 90, height: 12)
            }
            .padding(11)
        }
        .frame(width: 170)
        .clipShape(RoundedRectangle(cornerRadius: PF.radius))
        .overlay(RoundedRectangle(cornerRadius: PF.radius).stroke(PF.line, lineWidth: 1))
        .opacity(anim ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.9).repeatForever(), value: anim)
        .onAppear { anim = true }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // hero strip
                VStack(alignment: .leading, spacing: 8) {
                    Text("🦊 PriceFoxy")
                        .font(.system(size: 32, weight: .black))
                    Text("Compare prices across stores and jump directly to the best offer.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PF.muted)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#dbeff0"))
                .clipShape(RoundedRectangle(cornerRadius: PF.radiusLg))

                AboutFeatureRow(icon: "bolt.fill",          title: "Fast search",   text: "Search product results in real time.")
                AboutFeatureRow(icon: "building.2.fill",    title: "Store offers",  text: "See multiple store prices for the same product side by side.")
                AboutFeatureRow(icon: "safari.fill",        title: "Open offer",    text: "Open retailer pages securely inside Safari.")
                AboutFeatureRow(icon: "arrow.2.squarepath", title: "Always fresh",  text: "Live prices — no outdated or stale data.")
            }
            .padding(16)
        }
        .background(PF.bg.ignoresSafeArea())
        .navigationTitle("About")
    }
}

struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(PF.orange)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 15, weight: .black))
                Text(text).font(.system(size: 14)).foregroundStyle(PF.muted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: PF.radiusLg))
    }
}
