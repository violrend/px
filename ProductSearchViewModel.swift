import Foundation

@MainActor
final class ProductSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var sort: SortOption = .relevance
    @Published var items: [ProductItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var total: Int?

    private var page = 1
    private var totalPages = 1
    var lastQuery = ""
    private var canLoadMore = true

    func submitSearch() async {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        lastQuery = clean
        page = 1
        totalPages = 1
        canLoadMore = true
        items.removeAll()
        total = nil
        await loadMore(reset: true)
    }

    func refresh() async {
        guard !lastQuery.isEmpty else { return }
        page = 1
        totalPages = 1
        canLoadMore = true
        items.removeAll()
        await loadMore(reset: true)
    }

    func loadMoreIfNeeded(current item: ProductItem?) async {
        guard let item else { return }
        let threshold = items.index(items.endIndex, offsetBy: -5, limitedBy: items.startIndex) ?? items.startIndex
        if items.firstIndex(where: { $0.id == item.id }) == threshold {
            await loadMore(reset: false)
        }
    }

    func sortChanged() async {
        await refresh()
    }

    private func loadMore(reset: Bool) async {
        guard !isLoading, canLoadMore, !lastQuery.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await PriceFoxyAPI.shared.search(query: lastQuery, page: page, sort: sort)
            guard response.ok else {
                errorMessage = response.error ?? "Search failed"
                canLoadMore = false
                return
            }
            let newItems = response.items ?? []
            total = response.total
            totalPages = response.totalPages ?? page

            let existing = Set(items.map { $0.id })
            items.append(contentsOf: newItems.filter { !existing.contains($0.id) })

            if newItems.isEmpty || page >= totalPages {
                canLoadMore = false
            } else {
                page += 1
            }
        } catch {
            errorMessage = error.localizedDescription
            canLoadMore = false
        }
    }
}
