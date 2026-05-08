import SwiftUI

// MARK: - Container (accepts initial query from HomeView)

struct SearchContainerView: View {
    var body: some View {
        SearchView(initialQuery: "")
    }
}

// MARK: - SearchView

struct SearchView: View {
    var initialQuery: String = ""

    @StateObject private var vm = ProductSearchViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Sticky search bar  (mirrors .searchbar)
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                // ── Breadcrumb / title  (mirrors .search-title + .search-meta)
                if !vm.lastQueryPublic.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Home").font(.system(size: 13, weight: .bold)).foregroundStyle(PF.muted)
                            Text("›").foregroundStyle(PF.muted)
                            Text(vm.lastQueryPublic).font(.system(size: 13, weight: .bold)).foregroundStyle(PF.muted)
                        }
                        Text(vm.lastQueryPublic)
                            .font(.system(size: 28, weight: .black, design: .serif))
                            .foregroundStyle(PF.text)
                        if let total = vm.total {
                            Text("\(total) products found")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(PF.muted)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                }

                // ── Toolbar  (mirrors .toolbar)
                if !vm.items.isEmpty || vm.isLoading {
                    toolbar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }

                // ── Error
                if let err = vm.errorMessage {
                    Text(err)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                }

                // ── Grid  (mirrors .grid  4 cols → 2 cols mobile)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(vm.items) { item in
                        NavigationLink(destination: ProductDetailView(initialProduct: item)) {
                            SearchProductCard(item: item)
                        }
                        .buttonStyle(.plain)
                        .task { await vm.loadMoreIfNeeded(current: item) }
                    }
                }
                .padding(.horizontal, 16)

                // ── Loading spinner
                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(20)
                }

                // ── Empty state
                if vm.items.isEmpty && !vm.isLoading {
                    SearchEmptyState()
                }
            }
        }
        .background(PF.bg.ignoresSafeArea())
        .navigationTitle(vm.lastQueryPublic.isEmpty ? "Search" : vm.lastQueryPublic)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !initialQuery.isEmpty {
                vm.query = initialQuery
                await vm.submitSearch()
            }
        }
    }

    // MARK: Search bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(PF.muted)
                TextField("Search iPhone, laptop, TV…", text: $vm.query)
                    .font(.system(size: 16))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit { Task { await vm.submitSearch() } }
                if !vm.query.isEmpty {
                    Button { vm.query = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(PF.muted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(PF.line, lineWidth: 1.5))

            Button { Task { await vm.submitSearch() } } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(PF.orange)
                    .clipShape(Circle())
            }
        }
    }

    // MARK: Toolbar
    private var toolbar: some View {
        HStack {
            Spacer()
            Menu {
                ForEach(SortOption.allCases) { opt in
                    Button(opt.title) {
                        vm.sort = opt
                        Task { await vm.sortChanged() }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(vm.sort.title)
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(PF.line, lineWidth: 1))
            }
            .foregroundStyle(PF.text)
        }
    }
}

extension ProductSearchViewModel {
    var lastQueryPublic: String { lastQuery }
}

// MARK: - Search Product Card  (mirrors .card)

struct SearchProductCard: View {
    let item: ProductItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // thumb  (mirrors .card .thumb  height:220px)
            AsyncImage(url: URL(string: item.image ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFit()
                case .failure: Image(systemName: "photo").font(.title).foregroundStyle(PF.muted)
                default: ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color(hex: "#f3f4f6"))

            // body  (mirrors .card .body)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 13, weight: .black))
                    .lineLimit(2)
                    .foregroundStyle(PF.text)
                    .frame(minHeight: 34, alignment: .top)

                // price  (mirrors .card .price  font-size:22px bold)
                Text(formatPrice(item.price, currency: item.currency))
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(PF.text)

                // store  (mirrors .card .store)
                HStack(spacing: 5) {
                    StoreIcon(url: item.merchantLogo, domain: item.storeDomain, size: 14)
                    Text(item.merchantName ?? item.storeDomain ?? "")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(PF.muted)
                        .lineLimit(1)
                    Spacer()
                    Text("\(item.displayOfferCount) offers")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(PF.muted)
                }
            }
            .padding(12)
        }
        .background(PF.card)
        .clipShape(RoundedRectangle(cornerRadius: PF.radius))
        .overlay(RoundedRectangle(cornerRadius: PF.radius).stroke(PF.line, lineWidth: 1))
        .pfShadow()
    }
}

// MARK: - Empty State

struct SearchEmptyState: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(PF.orange)
            Text("Start with a search")
                .font(.system(size: 18, weight: .black))
            Text("Try iPhones, shoes, TVs, laptops or beauty products.")
                .font(.system(size: 14))
                .foregroundStyle(PF.muted)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}
