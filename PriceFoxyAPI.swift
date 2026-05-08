import Foundation

final class PriceFoxyAPI {
    static let shared = PriceFoxyAPI()

    // Change this to your real domain.
    private let baseURL = URL(string: "https://pricefoxy.com/app_api.php")!
    private let country = "US"

    private init() {}

    func search(query: String, page: Int, limit: Int = 24, sort: SortOption = .relevance) async throws -> ProductSearchResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "action", value: "search"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sort", value: sort.rawValue),
            URLQueryItem(name: "country", value: country)
        ]
        return try await request(components.url!)
    }

    func product(id: String) async throws -> ProductDetailResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "action", value: "product"),
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "country", value: country)
        ]
        return try await request(components.url!)
    }

    private func request<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 35

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
