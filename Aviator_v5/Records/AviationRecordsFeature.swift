import Foundation
import ComposableArchitecture

@Reducer
struct AviationRecordsFeature {
    @ObservableState
    struct State: Equatable {
        var records: [AviationRecord] = []
        var isLoading = false
        var errorMessage: String?
        var selectedRecord: AviationRecord?
        var selectedCategory: RecordCategory? = nil
        var searchText: String = ""
        
        var filteredRecords: [AviationRecord] {
            var filtered = records
            
            // Фільтр за категорією
            if let category = selectedCategory {
                filtered = filtered.filter { $0.category == category }
            }
            
            // Пошук за текстом
            if !searchText.isEmpty {
                filtered = filtered.filter { record in
                    record.title.localizedCaseInsensitiveContains(searchText) ||
                    record.description.localizedCaseInsensitiveContains(searchText) ||
                    record.pilot?.localizedCaseInsensitiveContains(searchText) == true ||
                    record.aircraft?.localizedCaseInsensitiveContains(searchText) == true ||
                    record.location?.localizedCaseInsensitiveContains(searchText) == true
                }
            }
            
            return filtered
        }
        
        var availableCategories: [RecordCategory] {
            return RecordCategory.allCases
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case loadRecords
        case recordsLoaded([AviationRecord])
        case selectRecord(AviationRecord?)
        case selectCategory(RecordCategory?)
        case searchTextChanged(String)
        case error(String)
    }
    
    @Dependency(\.aviationRecordsClient) var aviationRecordsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.loadRecords)
                }
                
            case .loadRecords:
                return .run { send in
                    do {
                        let records = try await aviationRecordsClient.loadRecords()
                        await send(.recordsLoaded(records))
                    } catch {
                        await send(.error("Failed to load records: \(error.localizedDescription)"))
                    }
                }
                
            case let .recordsLoaded(records):
                state.isLoading = false
                state.errorMessage = nil
                state.records = records
                return .none
                
            case let .selectRecord(record):
                state.selectedRecord = record
                return .none
                
            case let .selectCategory(category):
                state.selectedCategory = category
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
