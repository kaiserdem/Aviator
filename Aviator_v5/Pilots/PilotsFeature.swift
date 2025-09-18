import ComposableArchitecture
import Foundation

@Reducer
struct PilotsFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
        var pilots: [Pilot] = []
        var selectedPilot: Pilot?
        var selectedEra: PilotEra?
        var selectedCategory: PilotCategory?
    }
    
    enum Action: Equatable {
        case onAppear
        case pilotsLoaded([Pilot])
        case pilotsLoadFailed(String)
        case selectPilot(Pilot?)
        case selectEra(PilotEra?)
        case selectCategory(PilotCategory?)
    }
    
    @Dependency(\.wikipediaImageClient) var wikipediaImageClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        // Завантажуємо базові дані про пілотів
                        let basePilots = Self.loadPilotsData()
                        
                        // Завантажуємо зображення для кожного пілота
                        var pilotsWithImages: [Pilot] = []
                        
                        for pilot in basePilots {
                            let imageURL = try? await wikipediaImageClient.fetchPilotImage(pilot.name)
                            
                            let updatedPilot = Pilot(
                                name: pilot.name,
                                fullName: pilot.fullName,
                                nationality: pilot.nationality,
                                birthDate: pilot.birthDate,
                                deathDate: pilot.deathDate,
                                achievements: pilot.achievements,
                                biography: pilot.biography,
                                imageName: pilot.imageName,
                                imageURL: imageURL,
                                era: pilot.era,
                                category: pilot.category
                            )
                            
                            pilotsWithImages.append(updatedPilot)
                        }
                        
                        await send(.pilotsLoaded(pilotsWithImages))
                    } catch {
                        await send(.pilotsLoadFailed(error.localizedDescription))
                    }
                }
                
            case let .pilotsLoaded(pilots):
                state.isLoading = false
                state.pilots = pilots
                return .none
                
            case let .pilotsLoadFailed(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
                
            case let .selectPilot(pilot):
                state.selectedPilot = pilot
                return .none
                
            case let .selectEra(era):
                state.selectedEra = era
                return .none
                
            case let .selectCategory(category):
                state.selectedCategory = category
                return .none
            }
        }
    }
    
    // MARK: - Static Data
    static func loadPilotsData() -> [Pilot] {
        return [
            // Pioneers
            Pilot(
                name: "Wright Brothers",
                fullName: "Orville & Wilbur Wright",
                nationality: "American",
                birthDate: "1871 & 1867",
                deathDate: "1948 & 1912",
                achievements: [
                    "First powered flight (1903)",
                    "Invented aircraft control system",
                    "Founded aviation industry"
                ],
                biography: "The Wright brothers were American aviation pioneers credited with inventing, building, and flying the world's first successful motor-operated airplane.",
                imageName: "wright_brothers",
                imageURL: nil,
                era: .pioneers,
                category: .test
            ),
            
            Pilot(
                name: "Amelia Earhart",
                fullName: "Amelia Mary Earhart",
                nationality: "American",
                birthDate: "1897",
                deathDate: "1937 (disappeared)",
                achievements: [
                    "First woman to fly solo across Atlantic",
                    "First woman to fly solo nonstop coast-to-coast",
                    "Aviation pioneer and women's rights advocate"
                ],
                biography: "Amelia Earhart was an American aviation pioneer and author. She was the first female aviator to fly solo across the Atlantic Ocean.",
                imageName: "amelia_earhart",
                imageURL: nil,
                era: .pioneers,
                category: .recordBreaker
            ),
            
            Pilot(
                name: "Charles Lindbergh",
                fullName: "Charles Augustus Lindbergh",
                nationality: "American",
                birthDate: "1902",
                deathDate: "1974",
                achievements: [
                    "First solo transatlantic flight (1927)",
                    "Won Orteig Prize",
                    "Developed artificial heart"
                ],
                biography: "Charles Lindbergh was an American aviator, military officer, author, inventor, and activist. He made the first solo nonstop flight across the Atlantic Ocean.",
                imageName: "charles_lindbergh",
                imageURL: nil,
                era: .pioneers,
                category: .recordBreaker
            ),
            
            // World War Era
            Pilot(
                name: "Chuck Yeager",
                fullName: "Charles Elwood Yeager",
                nationality: "American",
                birthDate: "1923",
                deathDate: "2020",
                achievements: [
                    "First pilot to break sound barrier",
                    "WWII ace with 11.5 victories",
                    "Test pilot for X-1 rocket plane"
                ],
                biography: "Chuck Yeager was a United States Air Force officer, flying ace, and record-setting test pilot. He became the first pilot confirmed to have exceeded the speed of sound.",
                imageName: "chuck_yeager",
                imageURL: nil,
                era: .worldWar,
                category: .test
            ),
            
            Pilot(
                name: "Erich Hartmann",
                fullName: "Erich Alfred Hartmann",
                nationality: "German",
                birthDate: "1922",
                deathDate: "1993",
                achievements: [
                    "Highest-scoring fighter ace in history (352 victories)",
                    "Flew over 1,400 combat missions",
                    "Never shot down in air-to-air combat"
                ],
                biography: "Erich Hartmann was a German fighter pilot during World War II and the most successful fighter ace in the history of aerial warfare.",
                imageName: "erich_hartmann",
                imageURL: nil,
                era: .worldWar,
                category: .military
            ),
            
            // Space Era
            Pilot(
                name: "Yuri Gagarin",
                fullName: "Yuri Alekseyevich Gagarin",
                nationality: "Soviet",
                birthDate: "1934",
                deathDate: "1968",
                achievements: [
                    "First human in space (1961)",
                    "First human to orbit Earth",
                    "Hero of the Soviet Union"
                ],
                biography: "Yuri Gagarin was a Soviet pilot and cosmonaut who became the first human to journey into outer space, achieving a major milestone in the Space Race.",
                imageName: "yuri_gagarin",
                imageURL: nil,
                era: .space,
                category: .astronaut
            ),
            
            Pilot(
                name: "Neil Armstrong",
                fullName: "Neil Alden Armstrong",
                nationality: "American",
                birthDate: "1930",
                deathDate: "2012",
                achievements: [
                    "First human to walk on Moon (1969)",
                    "Test pilot for X-15 rocket plane",
                    "Commander of Apollo 11"
                ],
                biography: "Neil Armstrong was an American astronaut and aeronautical engineer who was the first person to walk on the Moon.",
                imageName: "neil_armstrong",
                imageURL: nil,
                era: .space,
                category: .astronaut
            ),
            
            // Modern Era
            Pilot(
                name: "Chesley Sullenberger",
                fullName: "Chesley Burnett Sullenberger III",
                nationality: "American",
                birthDate: "1951",
                deathDate: nil,
                achievements: [
                    "Miracle on the Hudson landing (2009)",
                    "US Airways Flight 1549 hero",
                    "Air Force Academy graduate"
                ],
                biography: "Chesley Sullenberger is an American retired airline captain who is best known for his role in the emergency landing of US Airways Flight 1549.",
                imageName: "chesley_sullenberger",
                imageURL: nil,
                era: .modern,
                category: .commercial
            ),
            
            Pilot(
                name: "Valentina Tereshkova",
                fullName: "Valentina Vladimirovna Tereshkova",
                nationality: "Soviet/Russian",
                birthDate: "1937",
                deathDate: nil,
                achievements: [
                    "First woman in space (1963)",
                    "Only woman to fly solo in space",
                    "Politician and engineer"
                ],
                biography: "Valentina Tereshkova is a Russian engineer, member of the State Duma, and former Soviet cosmonaut, being the first and youngest woman to have flown in space.",
                imageName: "valentina_tereshkova",
                imageURL: nil,
                era: .space,
                category: .astronaut
            )
        ]
    }
}
