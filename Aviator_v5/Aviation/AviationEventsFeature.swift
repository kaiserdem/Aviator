import Foundation
import ComposableArchitecture

@Reducer
struct AviationEventsFeature {
    @ObservableState
    struct State: Equatable {
        var currentEvents: [AviationEvent] = []
        var faiChampionships: [AviationEvent] = []
        var isLoading = false
        var errorMessage: String?
        var selectedEvent: AviationEvent?
        var selectedTab: EventTab = .currentEvents
        var selectedSportFilter: Sport? = nil
        var searchText: String = ""
        
        enum EventTab: String, CaseIterable {
            case currentEvents = "Current Events"
            case faiChampionships = "FAI Championships"
            
            var displayName: String {
                switch self {
                case .currentEvents:
                    return "Current Events"
                case .faiChampionships:
                    return "FAI World & Continental Championships"
                }
            }
        }
        
        var filteredEvents: [AviationEvent] {
            let events = selectedTab == .currentEvents ? currentEvents : faiChampionships
            
            var filtered = events
            
            // Фільтр за спортом
            if let sportFilter = selectedSportFilter {
                filtered = filtered.filter { $0.sport == sportFilter }
            }
            
            // Пошук за текстом
            if !searchText.isEmpty {
                filtered = filtered.filter { event in
                    event.title.localizedCaseInsensitiveContains(searchText) ||
                    event.location.localizedCaseInsensitiveContains(searchText) ||
                    event.country.localizedCaseInsensitiveContains(searchText) ||
                    event.discipline.localizedCaseInsensitiveContains(searchText)
                }
            }
            
            return filtered
        }
        
        var availableSports: [Sport] {
            let events = selectedTab == .currentEvents ? currentEvents : faiChampionships
            return Array(Set(events.map { $0.sport })).sorted { $0.displayName < $1.displayName }
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case loadCurrentEvents
        case loadFAIChampionships
        case eventsLoaded([AviationEvent], EventType)
        case faiChampionshipsLoaded([AviationEvent])
        case selectTab(State.EventTab)
        case selectEvent(AviationEvent?)
        case selectSportFilter(Sport?)
        case searchTextChanged(String)
        case error(String)
    }
    
    enum EventType {
        case current
        case fai
    }
    
    @Dependency(\.aviationEventsClient) var aviationEventsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.loadCurrentEvents)
                    await send(.loadFAIChampionships)
                }
                
            case .loadCurrentEvents:
                return .run { send in
                    do {
                        let events = try await aviationEventsClient.loadCurrentEvents()
                        await send(.eventsLoaded(events, .current))
                    } catch {
                        await send(.error("Failed to load current events: \(error.localizedDescription)"))
                    }
                }
                
            case .loadFAIChampionships:
                return .run { send in
                    do {
                        let events = try await aviationEventsClient.loadFAIChampionships()
                        await send(.faiChampionshipsLoaded(events))
                    } catch {
                        await send(.error("Failed to load FAI championships: \(error.localizedDescription)"))
                    }
                }
                
            case let .eventsLoaded(events, type):
                state.isLoading = false
                state.errorMessage = nil
                switch type {
                case .current:
                    state.currentEvents = events
                case .fai:
                    state.faiChampionships = events
                }
                return .none
                
            case let .faiChampionshipsLoaded(events):
                state.isLoading = false
                state.errorMessage = nil
                state.faiChampionships = events
                return .none
                
            case let .selectTab(tab):
                state.selectedTab = tab
                state.selectedSportFilter = nil // Скидаємо фільтр при зміні табу
                return .none
                
            case let .selectEvent(event):
                state.selectedEvent = event
                return .none
                
            case let .selectSportFilter(sport):
                state.selectedSportFilter = sport
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
                
            case let .error(message):
                state.isLoading = false
                state.errorMessage = message
                return .none
            }
        }
    }
}
