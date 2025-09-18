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
            ),
            
            // Додаткові піонери
            Pilot(
                name: "Bessie Coleman",
                fullName: "Elizabeth Coleman",
                nationality: "American",
                birthDate: "1892",
                deathDate: "1926",
                achievements: [
                    "First African-American woman pilot",
                    "First Native American woman pilot",
                    "Stunt pilot and barnstormer"
                ],
                biography: "Bessie Coleman was an early American civil aviator. She was the first African-American woman and first Native American to hold a pilot license.",
                imageName: "bessie_coleman",
                imageURL: nil,
                era: .pioneers,
                category: .recordBreaker
            ),
            
            Pilot(
                name: "Howard Hughes",
                fullName: "Howard Robard Hughes Jr.",
                nationality: "American",
                birthDate: "1905",
                deathDate: "1976",
                achievements: [
                    "Transcontinental speed record (1937)",
                    "Around-the-world flight record (1938)",
                    "Aviation entrepreneur and filmmaker"
                ],
                biography: "Howard Hughes was an American business magnate, investor, record-setting pilot, engineer, film director, and philanthropist.",
                imageName: "howard_hughes",
                imageURL: nil,
                era: .pioneers,
                category: .recordBreaker
            ),
            
            // Додаткові військові пілоти
            Pilot(
                name: "Douglas Bader",
                fullName: "Sir Douglas Robert Steuart Bader",
                nationality: "British",
                birthDate: "1910",
                deathDate: "1982",
                achievements: [
                    "Fighter ace despite losing both legs",
                    "22 aerial victories in WWII",
                    "Inspiration for disabled pilots"
                ],
                biography: "Douglas Bader was a Royal Air Force flying ace during the Second World War. He was credited with 22 aerial victories despite having lost both legs in a flying accident.",
                imageName: "douglas_bader",
                imageURL: nil,
                era: .worldWar,
                category: .military
            ),
            
            Pilot(
                name: "Saburo Sakai",
                fullName: "Saburo Sakai",
                nationality: "Japanese",
                birthDate: "1916",
                deathDate: "2000",
                achievements: [
                    "64 aerial victories in WWII",
                    "Flew with one eye after injury",
                    "Respected by Allied pilots"
                ],
                biography: "Saburo Sakai was a Japanese naval aviator and flying ace of the Imperial Japanese Navy during World War II.",
                imageName: "saburo_sakai",
                imageURL: nil,
                era: .worldWar,
                category: .military
            ),
            
            // Додаткові космонавти
            Pilot(
                name: "John Glenn",
                fullName: "John Herschel Glenn Jr.",
                nationality: "American",
                birthDate: "1921",
                deathDate: "2016",
                achievements: [
                    "First American to orbit Earth (1962)",
                    "Oldest person in space (77 years)",
                    "US Senator and Marine Corps pilot"
                ],
                biography: "John Glenn was an American Marine Corps aviator, engineer, astronaut, and United States Senator from Ohio.",
                imageName: "john_glenn",
                imageURL: nil,
                era: .space,
                category: .astronaut
            ),
            
            Pilot(
                name: "Sally Ride",
                fullName: "Sally Kristen Ride",
                nationality: "American",
                birthDate: "1951",
                deathDate: "2012",
                achievements: [
                    "First American woman in space (1983)",
                    "Youngest American astronaut",
                    "Physicist and educator"
                ],
                biography: "Sally Ride was an American astronaut and physicist. She joined NASA in 1978 and became the first American woman in space in 1983.",
                imageName: "sally_ride",
                imageURL: nil,
                era: .space,
                category: .astronaut
            ),
            
            // Додаткові сучасні пілоти
            Pilot(
                name: "Eileen Collins",
                fullName: "Eileen Marie Collins",
                nationality: "American",
                birthDate: "1956",
                deathDate: nil,
                achievements: [
                    "First female Space Shuttle pilot",
                    "First female Space Shuttle commander",
                    "USAF Colonel and test pilot"
                ],
                biography: "Eileen Collins is a retired NASA astronaut and United States Air Force colonel. She was the first female pilot and first female commander of a Space Shuttle.",
                imageName: "eileen_collins",
                imageURL: nil,
                era: .modern,
                category: .astronaut
            ),
            
            Pilot(
                name: "Barrington Irving",
                fullName: "Barrington Irving",
                nationality: "Jamaican-American",
                birthDate: "1983",
                deathDate: nil,
                achievements: [
                    "Youngest person to fly solo around the world",
                    "First African-American to fly solo around the world",
                    "Aviation educator and mentor"
                ],
                biography: "Barrington Irving is a Jamaican-American pilot who became the youngest person and first African-American to fly solo around the world.",
                imageName: "barrington_irving",
                imageURL: nil,
                era: .modern,
                category: .recordBreaker
            ),
            
            Pilot(
                name: "Tammie Jo Shults",
                fullName: "Tammie Jo Shults",
                nationality: "American",
                birthDate: "1961",
                deathDate: nil,
                achievements: [
                    "Southwest Flight 1380 emergency landing",
                    "Former Navy fighter pilot",
                    "One of first female F/A-18 Hornet pilots"
                ],
                biography: "Tammie Jo Shults is a retired American commercial airline pilot and former United States Navy pilot. She was the captain of Southwest Airlines Flight 1380.",
                imageName: "tammie_jo_shults",
                imageURL: nil,
                era: .modern,
                category: .commercial
            ),
            
            // Нові пілоти з вашого списку
            Pilot(
                name: "Karen Skinner",
                fullName: "Karen Skinner",
                nationality: "Spanish",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Microlights and Paramotors specialist",
                    "Aviation instructor",
                    "Pioneer in ultralight aviation"
                ],
                biography: "Karen Skinner is a Spanish aviation specialist known for her expertise in microlights and paramotors, contributing to the development of ultralight aviation.",
                imageName: "KAREN SKINNER",
                imageURL: nil,
                era: .modern,
                category: .microlights
            ),
            
            Pilot(
                name: "Wanraya Wannapong",
                fullName: "Wanraya Wannapong",
                nationality: "Thai",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Drone racing champion",
                    "Aerial photography specialist",
                    "UAV technology pioneer"
                ],
                biography: "Wanraya Wannapong is a Thai drone pilot and aerial photography specialist, known for her expertise in UAV technology and drone racing.",
                imageName: "WANRAYA WANNAPONG ",
                imageURL: nil,
                era: .modern,
                category: .drones
            ),
            
            Pilot(
                name: "Castor Fantoba",
                fullName: "Castor Fantoba",
                nationality: "Spanish",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Aerobatics champion",
                    "Air show performer",
                    "Flight instructor"
                ],
                biography: "Castor Fantoba is a Spanish aerobatics pilot known for his precision flying and air show performances.",
                imageName: "CASTOR FANTOBA",
                imageURL: nil,
                era: .modern,
                category: .aerobatics
            ),
            
            Pilot(
                name: "Klaus Ohlmann",
                fullName: "Klaus Ohlmann",
                nationality: "German",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Gliding world record holder",
                    "Long-distance gliding specialist",
                    "Meteorology expert"
                ],
                biography: "Klaus Ohlmann is a German glider pilot known for his world records in long-distance gliding and expertise in meteorology.",
                imageName: "KLAUS OHLMANN",
                imageURL: nil,
                era: .modern,
                category: .gliding
            ),
            
            Pilot(
                name: "Corinna Schwiegshausen",
                fullName: "Corinna Schwiegshausen",
                nationality: "German",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Hang gliding champion",
                    "Cross-country flying specialist",
                    "Aviation safety advocate"
                ],
                biography: "Corinna Schwiegshausen is a German hang gliding pilot known for her cross-country flying achievements and aviation safety advocacy.",
                imageName: "CORINNA SCHWIEGERSHAUSEN",
                imageURL: nil,
                era: .modern,
                category: .hangGliding
            ),
            
            Pilot(
                name: "Jennifer Murray",
                fullName: "Jennifer Murray",
                nationality: "British",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Helicopter world record holder",
                    "First woman to fly around the world in helicopter",
                    "Aviation author and speaker"
                ],
                biography: "Jennifer Murray is a British helicopter pilot who became the first woman to fly around the world in a helicopter, setting multiple world records.",
                imageName: "JENNIFER MURRAY",
                imageURL: nil,
                era: .modern,
                category: .rotorcraft
            ),
            
            Pilot(
                name: "David Hempleman-Adams",
                fullName: "David Hempleman-Adams",
                nationality: "British",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Ballooning world record holder",
                    "Adventure sports pioneer",
                    "Polar explorer"
                ],
                biography: "David Hempleman-Adams is a British adventurer and balloonist known for his world records in ballooning and polar exploration.",
                imageName: "DAVID HEMPLEMAN-ADAMS",
                imageURL: nil,
                era: .modern,
                category: .ballooning
            ),
            
            Pilot(
                name: "Honorin Hamard",
                fullName: "Honorin Hamard",
                nationality: "French",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Paragliding world champion",
                    "Cross-country flying specialist",
                    "Aviation instructor"
                ],
                biography: "Honorin Hamard is a French paragliding pilot known for his world championship titles and expertise in cross-country flying.",
                imageName: "HONORIN HAMARD",
                imageURL: nil,
                era: .modern,
                category: .paragliding
            ),
            
            Pilot(
                name: "Jean Batten",
                fullName: "Jean Batten",
                nationality: "New Zealand",
                birthDate: "1909",
                deathDate: "1982",
                achievements: [
                    "First woman to fly solo from England to Australia",
                    "Multiple long-distance flight records",
                    "Aviation pioneer"
                ],
                biography: "Jean Batten was a New Zealand aviator who made several record-breaking solo flights across the world in the 1930s.",
                imageName: "JEAN BATTEN",
                imageURL: nil,
                era: .pioneers,
                category: .generalAviation
            ),
            
            Pilot(
                name: "Eldon W. Joersz",
                fullName: "Eldon W. Joersz",
                nationality: "American",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "SR-71 Blackbird pilot",
                    "Speed record holder",
                    "Reconnaissance specialist"
                ],
                biography: "Eldon W. Joersz is an American pilot known for flying the SR-71 Blackbird and setting speed records in reconnaissance missions.",
                imageName: "ELDON JOERSZ",
                imageURL: nil,
                era: .modern,
                category: .military
            ),
            
            Pilot(
                name: "Ennio Graber",
                fullName: "Ennio Graber",
                nationality: "Swiss",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Aeromodelling world champion",
                    "Model aircraft designer",
                    "Aviation educator"
                ],
                biography: "Ennio Graber is a Swiss aeromodelling champion known for his innovative model aircraft designs and world championship titles.",
                imageName: "ENNIO GRABER",
                imageURL: nil,
                era: .modern,
                category: .aeromodelling
            ),
            
            Pilot(
                name: "Thomas Grout",
                fullName: "Thomas Grout",
                nationality: "French",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Drone racing champion",
                    "FPV flying specialist",
                    "Technology innovator"
                ],
                biography: "Thomas Grout is a French drone racing champion known for his FPV flying skills and contributions to drone racing technology.",
                imageName: "THOMAS GROUT",
                imageURL: nil,
                era: .modern,
                category: .drones
            ),
            
            Pilot(
                name: "Christian Ciech",
                fullName: "Christian Ciech",
                nationality: "Italian",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Hang gliding world champion",
                    "Cross-country flying specialist",
                    "Aviation safety expert"
                ],
                biography: "Christian Ciech is an Italian hang gliding pilot known for his world championship titles and expertise in cross-country flying.",
                imageName: "CHRISTIAN CIECH",
                imageURL: nil,
                era: .modern,
                category: .hangGliding
            ),
            
            Pilot(
                name: "Gayeon Mo",
                fullName: "Gayeon Mo",
                nationality: "South Korean",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Drone racing champion",
                    "Aerial photography specialist",
                    "UAV technology pioneer"
                ],
                biography: "Gayeon Mo is a South Korean drone pilot known for her achievements in drone racing and aerial photography.",
                imageName: "GAYEON MO",
                imageURL: nil,
                era: .modern,
                category: .drones
            ),
            
            Pilot(
                name: "David Broom",
                fullName: "David Broom",
                nationality: "British",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Microlights and Paramotors specialist",
                    "Aviation instructor",
                    "Ultralight aircraft designer"
                ],
                biography: "David Broom is a British aviation specialist known for his expertise in microlights and paramotors, and his work as an aviation instructor.",
                imageName: "DAVID BROOM",
                imageURL: nil,
                era: .modern,
                category: .microlights
            ),
            
            Pilot(
                name: "Charles Boden",
                fullName: "Charles Boden",
                nationality: "American",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Space shuttle pilot",
                    "NASA astronaut",
                    "Space mission specialist"
                ],
                biography: "Charles Boden is an American astronaut and space shuttle pilot known for his contributions to NASA space missions.",
                imageName: "CHARLES BODEN",
                imageURL: nil,
                era: .space,
                category: .space
            ),
            
            Pilot(
                name: "Thomas Morgenstern",
                fullName: "Thomas Morgenstern",
                nationality: "Austrian",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Helicopter rescue specialist",
                    "Mountain rescue pilot",
                    "Aviation safety expert"
                ],
                biography: "Thomas Morgenstern is an Austrian helicopter pilot known for his expertise in mountain rescue operations and aviation safety.",
                imageName: "THOMAS MORGENSTERN",
                imageURL: nil,
                era: .modern,
                category: .rotorcraft
            ),
            
            Pilot(
                name: "Curtis Bartholomew",
                fullName: "Curtis Bartholomew",
                nationality: "American",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Parachuting world record holder",
                    "Skydiving instructor",
                    "Extreme sports pioneer"
                ],
                biography: "Curtis Bartholomew is an American parachuting specialist known for his world records in skydiving and contributions to extreme sports.",
                imageName: "CURTIS BARTHOLOMEW",
                imageURL: nil,
                era: .modern,
                category: .parachuting
            ),
            
            Pilot(
                name: "Bertrand Piccard",
                fullName: "Bertrand Piccard",
                nationality: "Swiss",
                birthDate: "1958",
                deathDate: nil,
                achievements: [
                    "First non-stop balloon flight around the world",
                    "Solar-powered aircraft pioneer",
                    "Environmental aviation advocate"
                ],
                biography: "Bertrand Piccard is a Swiss psychiatrist and balloonist who made the first non-stop balloon flight around the world and pioneered solar-powered aviation.",
                imageName: "BERTRAND PICCARD",
                imageURL: nil,
                era: .modern,
                category: .ballooning
            ),
            
            Pilot(
                name: "Mikhail Mamistov",
                fullName: "Mikhail Mamistov",
                nationality: "Russian",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Aerobatics world champion",
                    "Air show performer",
                    "Flight instructor"
                ],
                biography: "Mikhail Mamistov is a Russian aerobatics pilot known for his world championship titles and spectacular air show performances.",
                imageName: "MIKHAIL MAMISTOV",
                imageURL: nil,
                era: .modern,
                category: .aerobatics
            ),
            
            Pilot(
                name: "Rudi Browning",
                fullName: "Rudi Browning",
                nationality: "Australian",
                birthDate: "Unknown",
                deathDate: nil,
                achievements: [
                    "Drone racing champion",
                    "Aeromodelling specialist",
                    "Aviation technology innovator"
                ],
                biography: "Rudi Browning is an Australian aviation specialist known for his achievements in drone racing and aeromodelling.",
                imageName: "RUDI BROWNING",
                imageURL: nil,
                era: .modern,
                category: .drones
            )
        ]
    }
}
