import Foundation
import ComposableArchitecture

struct WikipediaClient {
    var searchAirlines: () async -> [WikipediaAirline]
}

extension WikipediaClient: DependencyKey {
    static let liveValue = Self(
        searchAirlines: {
            await WikipediaService.shared.searchAirlines()
        }
    )
    
    static let testValue = Self(
        searchAirlines: {
            [
                WikipediaAirline(
                    title: "Lufthansa",
                    extract: "Lufthansa is the largest German airline...",
                    thumbnail: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Lufthansa_logo_2018.svg/200px-Lufthansa_logo_2018.svg.png",
                    url: "https://en.wikipedia.org/wiki/Lufthansa"
                )
            ]
        }
    )
}

extension DependencyValues {
    var wikipediaClient: WikipediaClient {
        get { self[WikipediaClient.self] }
        set { self[WikipediaClient.self] = newValue }
    }
}

// MARK: - Wikipedia Service

final class WikipediaService {
    static let shared = WikipediaService()
    
    private init() {}
    
    func searchAirlines() async -> [WikipediaAirline] {
        print("📚 WikipediaService: Starting to fetch airlines from Wikipedia...")
        
        // For now, return a simple list of known airlines
        let knownAirlines = [
            "Lufthansa",
            "British Airways", 
            "Air France",
            "Emirates",
            "United Airlines",
            "American Airlines",
            "Delta Air Lines",
            "Southwest Airlines",
            "Ryanair",
            "easyJet",
            "Wizz Air",
            "Turkish Airlines",
            "KLM Royal Dutch Airlines",
            "Iberia",
            "Alitalia",
            "Aeroflot",
            "Japan Airlines",
            "Singapore Airlines",
            "Qantas",
            "Air Canada",
            "Ukraine International Airlines",
            "Swiss International Air Lines",
            "Austrian Airlines",
            "SAS",
            "Finnair",
            "Icelandair",
            "Norwegian",
            "Eurowings",
            "Air Berlin",
            "Condor",
            "Transavia",
            "Brussels Airlines",
            "TAP Air Portugal",
            "Vueling",
            "Widerøe"
        ]
        
        let airlines = knownAirlines.map { name in
            WikipediaAirline(
                title: name,
                extract: "\(name) is a commercial airline...",
                thumbnail: nil,
                url: "https://en.wikipedia.org/wiki/\(name.replacingOccurrences(of: " ", with: "_"))"
            )
        }
        
        print("📚 WikipediaService: Created \(airlines.count) airlines from known list")
        return airlines
    }
    
    private func searchWikipedia(searchTerm: String) async -> [WikipediaAirline] {
        let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/\(searchTerm.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? searchTerm)"
        
        guard let url = URL(string: urlString) else {
            print("❌ WikipediaService: Invalid URL for search term: \(searchTerm)")
            return []
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("❌ WikipediaService: Bad response status for: \(searchTerm)")
                return []
            }
            
            let decoder = JSONDecoder()
            let page = try decoder.decode(WikipediaPage.self, from: data)
            
            // Extract airlines from the page content
            let airlines = extractAirlinesFromPage(page)
            print("📚 WikipediaService: Extracted \(airlines.count) airlines from '\(searchTerm)'")
            
            return airlines
            
        } catch {
            print("❌ WikipediaService: Error fetching Wikipedia data: \(error.localizedDescription)")
            return []
        }
    }
    
    private func extractAirlinesFromPage(_ page: WikipediaPage) -> [WikipediaAirline] {
        // This is a simplified extraction - in a real app you'd parse the full page content
        // For now, we'll return the main page if it's about airlines
        if isAirlinePage(page.title) {
            return [WikipediaAirline(
                title: page.title,
                extract: page.extract,
                thumbnail: page.thumbnail?.source,
                url: page.content_urls?.desktop?.page
            )]
        }
        
        return []
    }
    
    private func isAirlinePage(_ title: String) -> Bool {
        let airlineKeywords = [
            "airline", "airways", "air", "aviation", "flight", "aircraft",
            "lufthansa", "british airways", "air france", "emirates", "qantas",
            "united airlines", "american airlines", "delta", "southwest",
            "ryanair", "easyjet", "wizz air", "turkish airlines", "klm"
        ]
        
        let lowercasedTitle = title.lowercased()
        return airlineKeywords.contains { keyword in
            lowercasedTitle.contains(keyword)
        }
    }
}

// MARK: - Models

struct WikipediaAirline: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let extract: String
    let thumbnail: String?
    let url: String?
}

struct WikipediaPage: Codable {
    let title: String
    let extract: String
    let thumbnail: WikipediaThumbnail?
    let content_urls: WikipediaContentUrls?
}

struct WikipediaThumbnail: Codable {
    let source: String
}

struct WikipediaContentUrls: Codable {
    let desktop: WikipediaDesktop?
}

struct WikipediaDesktop: Codable {
    let page: String
}
