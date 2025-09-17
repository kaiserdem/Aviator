import Foundation
import ComposableArchitecture

struct WikipediaClient {
    var getSportDescription: (String) async -> String?
}

extension WikipediaClient: DependencyKey {
    static let liveValue = Self(
        getSportDescription: { sportName in
            await WikipediaService.shared.getSportDescription(sportName: sportName)
        }
    )
}

extension DependencyValues {
    var wikipediaClient: WikipediaClient {
        get { self[WikipediaClient.self] }
        set { self[WikipediaClient.self] = newValue }
    }
}


final class WikipediaService {
    static let shared = WikipediaService()
    
    private init() {}
    
    func getSportDescription(sportName: String) async -> String? {
        do {
            
            let wikipediaTitle = mapSportNameToWikipediaTitle(sportName)
            let encodedTitle = wikipediaTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? wikipediaTitle
            
            let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encodedTitle)")!
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Wikipedia API error: \(response)")
                return nil
            }
            
            let wikipediaResponse = try JSONDecoder().decode(WikipediaResponse.self, from: data)
            return wikipediaResponse.extract
        } catch {
            print("❌ Wikipedia API error: \(error)")
            return nil
        }
    }
    
    private func mapSportNameToWikipediaTitle(_ sportName: String) -> String {
        switch sportName.lowercased() {
        case let name where name.contains("aerobatic"):
            return "Aerobatics"
        case let name where name.contains("glider"):
            return "Gliding"
        case let name where name.contains("skydiving") || name.contains("parachut"):
            return "Parachuting"
        case let name where name.contains("balloon"):
            return "Hot air balloon"
        case let name where name.contains("racing"):
            return "Air racing"
        case let name where name.contains("formation"):
            return "Formation flying"
        case let name where name.contains("precision"):
            return "Precision flying"
        case let name where name.contains("wing walking"):
            return "Wing walking"
        case let name where name.contains("helicopter"):
            return "Helicopter"
        case let name where name.contains("ultralight"):
            return "Ultralight aviation"
        case let name where name.contains("paragliding"):
            return "Paragliding"
        case let name where name.contains("base jumping"):
            return "BASE jumping"
        case let name where name.contains("hang gliding"):
            return "Hang gliding"
        case let name where name.contains("slalom"):
            return "Slalom"
        case let name where name.contains("solo"):
            return "Solo flight"
        default:
            return "Aviation"
        }
    }
}


struct WikipediaResponse: Codable {
    let extract: String?
    let title: String?
    let thumbnail: WikipediaThumbnail?
}

struct WikipediaThumbnail: Codable {
    let source: String?
    let width: Int?
    let height: Int?
}
