import Foundation

struct ProductSearchResponse: Codable {
    let ok: Bool
    let page: Int?
    let limit: Int?
    let total: Int?
    let totalPages: Int?
    let items: [ProductItem]?
    let error: String?
}

struct ProductDetailResponse: Codable {
    let ok: Bool
    let product: ProductItem?
    let error: String?
}

struct ProductItem: Identifiable, Codable, Hashable {
    let source: String?
    let id: String
    let productLocalizedId: String?
    let productId: String?
    let title: String
    let image: String?
    let brand: String?
    let price: Double?
    let minPrice: Double?
    let maxPrice: Double?
    let currency: String?
    let merchantName: String?
    let merchantLogo: String?
    let storeDomain: String?
    let externalURL: String?
    let nbOffers: Int?
    let offers: [OfferItem]?
}

struct OfferItem: Identifiable, Codable, Hashable {
    let id: String
    let shopName: String?
    let shopIcon: String?
    let link: String?
    let storeDomain: String?
    let price: Double?
    let currency: String?
    let stock: Bool?
    let condition: String?
}

enum SortOption: String, CaseIterable, Identifiable {
    case relevance
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case offers

    var id: String { rawValue }
    var title: String {
        switch self {
        case .relevance: return "Relevance"
        case .priceAsc: return "Price: Low to High"
        case .priceDesc: return "Price: High to Low"
        case .offers: return "Most Offers"
        }
    }
}

// MARK: - Offer normalization

extension OfferItem {
    /// Stable key used to remove duplicate offers returned by the API.
    /// Some product detail responses can include the same merchant/offer twice,
    /// while search results only count it once.
    var normalizedOfferKey: String {
        let cleanLink = (link ?? "")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "?").first ?? ""

        let cleanDomain = (storeDomain ?? "")
            .lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/ "))

        let cleanShop = (shopName ?? "")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let cleanPrice = price.map { String(format: "%.2f", $0) } ?? ""

        if !cleanLink.isEmpty { return "link:\(cleanLink)" }
        if !cleanDomain.isEmpty { return "domain:\(cleanDomain)|price:\(cleanPrice)" }
        return "shop:\(cleanShop)|price:\(cleanPrice)"
    }
}

extension ProductItem {
    /// Detail endpoint can return duplicate/empty offers. Use this everywhere
    /// so grid count and detail count follow the same rule.
    var normalizedOffers: [OfferItem] {
        guard let offers else { return [] }

        var seen = Set<String>()
        return offers.filter { offer in
            // Keep only usable offers. This prevents hidden/broken rows from changing the count.
            let hasStore = !(offer.shopName ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                           !(offer.storeDomain ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasPrice = offer.price != nil
            guard hasStore || hasPrice else { return false }

            let key = offer.normalizedOfferKey
            guard !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }
    }

    var displayOfferCount: Int {
        let normalizedCount = normalizedOffers.count
        if normalizedCount > 0 { return normalizedCount }
        return nbOffers ?? 0
    }
}

