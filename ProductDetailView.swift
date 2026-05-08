import SwiftUI

struct ProductDetailView: View {
    let initialProduct: ProductItem
    @State private var product: ProductItem?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedURL: URL?
    @State private var activeTab: DetailTab = .offers

    private var current: ProductItem { product ?? initialProduct }
    private var offers: [OfferItem] { current.normalizedOffers }

    enum DetailTab: String, CaseIterable {
        case offers = "Store Offers"
        case about  = "About"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                productTopSection
                tabBar
                tabContent
            }
        }
        .background(PF.bg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Compare prices")
        .task { await loadProduct() }
        .sheet(item: $selectedURL) { url in SafariView(url: url) }
    }

    // MARK: Top section  (mirrors .p-top / .p-grid)
    private var productTopSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // image  (mirrors .p-img  height:420px)
            AsyncImage(url: URL(string: current.image ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFit()
                case .failure: Image(systemName: "photo").font(.system(size: 52)).foregroundStyle(PF.muted)
                default: ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .background(Color(hex: "#f3f4f6"))
            .clipShape(RoundedRectangle(cornerRadius: PF.radius))

            // brand / merchant
            if let brand = current.brand, !brand.isEmpty {
                Text(brand.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(PF.muted)
                    .tracking(1.2)
            }

            // title  (mirrors .p-h1 serif)
            Text(current.title)
                .font(.system(size: 26, weight: .black, design: .serif))
                .foregroundStyle(PF.text)
                .lineSpacing(2)

            // best price bar  (mirrors .bestbar orange tinted)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Best price")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(PF.orange)
                    Text(formatPrice(current.price, currency: current.currency))
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(PF.text)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Offers")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(PF.muted)
                    Text("\(current.displayOfferCount)")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(PF.text)
                }
            }
            .padding(14)
            .background(Color(hex: "#ffe7df"))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#ffd1c2"), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if isLoading { ProgressView("Updating offers…").padding(.top, 4) }
            if let err = errorMessage {
                Text(err).font(.system(size: 13)).foregroundStyle(.red)
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: Tab bar  (mirrors .tabs)
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { activeTab = tab }
                } label: {
                    VStack(spacing: 0) {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(activeTab == tab ? PF.text : PF.muted)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                        // active underline  (mirrors .tab.active border-bottom:3px solid)
                        Rectangle()
                            .fill(activeTab == tab ? PF.text : Color.clear)
                            .frame(height: 3)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .offers: offersSection
        case .about:  aboutSection
        }
    }

    // MARK: Offers list  (mirrors .offer-list)
    private var offersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if offers.isEmpty && !isLoading {
                Text("No offers found for this product.")
                    .foregroundStyle(PF.muted)
                    .padding()
            }
            ForEach(offers) { offer in
                OfferRow(offer: offer) {
                    if let link = offer.link, let url = URL(string: link) {
                        selectedURL = url
                    }
                }
            }
        }
        .padding(16)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let brand = current.brand, !brand.isEmpty {
                InfoRow(label: "Brand", value: brand)
            }
            if let merchant = current.merchantName {
                InfoRow(label: "Merchant", value: merchant)
            }
            if let domain = current.storeDomain {
                InfoRow(label: "Domain", value: domain)
            }
            InfoRow(label: "ID", value: current.id)
        }
        .padding(16)
    }

    private func loadProduct() async {
        guard !initialProduct.id.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await PriceFoxyAPI.shared.product(id: initialProduct.id)
            if response.ok, let p = response.product { product = p }
            else { errorMessage = response.error ?? "Could not update product offers." }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Offer Row  (mirrors .offer card)

struct OfferRow: View {
    let offer: OfferItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // store badge  (mirrors .store-badge  72×44)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PF.line, lineWidth: 1))
                        .frame(width: 62, height: 44)
                    AsyncImage(url: faviconURL(offer)) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFit()
                                .frame(width: 28, height: 28)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            Text(String((offer.shopName ?? "S").prefix(1)))
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(PF.text)
                        }
                    }
                }

                // info  (mirrors .ot + .od)
                VStack(alignment: .leading, spacing: 3) {
                    Text(offer.shopName ?? offer.storeDomain ?? "Store")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(PF.text)
                        .lineLimit(1)
                    if let domain = offer.storeDomain,
                       !domain.isEmpty,
                       !domain.contains("affilizz"),
                       !domain.contains("redirect"),
                       !domain.contains("tracking") {
                        Text(domain)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(PF.muted)
                    }
                    if let cond = offer.condition, !cond.isEmpty {
                        Text(cond)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(PF.muted)
                    }
                }

                Spacer()

                // price + CTA  (mirrors .price + btn-orange)
                VStack(alignment: .trailing, spacing: 8) {
                    Text(formatPrice(offer.price, currency: offer.currency))
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(PF.text)

                    Text("Go to offer →")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(PF.orange)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(PF.line, lineWidth: 1))
            .pfShadow()
        }
        .buttonStyle(.plain)
    }

    private func faviconURL(_ o: OfferItem) -> URL? {
        if let u = o.shopIcon, !u.isEmpty { return URL(string: u) }
        if let d = o.storeDomain, !d.isEmpty {
            return URL(string: "https://www.google.com/s2/favicons?sz=64&domain_url=https://\(d)")
        }
        return nil
    }
}

// MARK: - Helper

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 13, weight: .bold)).foregroundStyle(PF.muted).frame(width: 80, alignment: .leading)
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundStyle(PF.text)
            Spacer()
        }
        .padding(.vertical, 6)
        Divider()
    }
}

// MARK: - Shared helpers (kept from original)

struct StoreIcon: View {
    let url: String?
    let domain: String?
    let size: CGFloat

    var iconURL: URL? {
        if let url, !url.isEmpty { return URL(string: url) }
        if let domain, !domain.isEmpty {
            return URL(string: "https://www.google.com/s2/favicons?sz=64&domain_url=https://\(domain)")
        }
        return nil
    }

    var body: some View {
        AsyncImage(url: iconURL) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFit()
            default: Image(systemName: "storefront").resizable().scaledToFit().foregroundStyle(PF.muted)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

func formatPrice(_ price: Double?, currency: String?) -> String {
    guard let price else { return "See price" }
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = currency ?? "EUR"
    f.maximumFractionDigits = 2
    f.minimumFractionDigits = 2
    return f.string(from: NSNumber(value: price)) ?? "\(price)"
}
