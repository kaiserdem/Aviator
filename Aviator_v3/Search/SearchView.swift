import SwiftUI
import ComposableArchitecture
import Foundation

struct SearchView: View {
    let store: StoreOf<SearchFeature>
    
    private var isSearchEnabled: Bool {
        let viewStore = ViewStore(store, observe: { $0 })
        return !viewStore.origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !viewStore.destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    backgroundView
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            searchFormView(viewStore: viewStore)
                            searchResultsSummaryView(viewStore: viewStore)
                        }
                        .padding()
                    }
                    .navigationTitle("Flight Search")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarBackground(Theme.Gradient.navigationBar, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundView: some View {
        Theme.Gradient.background
            .ignoresSafeArea()
    }
    
    private func searchFormView(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        VStack(spacing: 16) {
            Text("Flight Search")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.Palette.textPrimary)
            
            originDestinationFields(viewStore: viewStore)
            dateFields(viewStore: viewStore)
            passengersSection(viewStore: viewStore)
            travelClassSection(viewStore: viewStore)
            searchButton(viewStore: viewStore)
        }
        .padding()
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Shadow.red, radius: 4)
    }
    
    private func originDestinationFields(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text("From")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                TextField("Origin (e.g., WAW)", text: viewStore.binding(get: \.origin, send: { .originChanged($0) }))
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.default)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
            }
            
            VStack(alignment: .leading) {
                Text("To")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                TextField("Destination (e.g., SOF)", text: viewStore.binding(get: \.destination, send: { .destinationChanged($0) }))
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.default)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
            }
        }
    }
    
    private func dateFields(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text("Departure")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                DatePicker("", selection: viewStore.binding(get: \.departureDate, send: { .departureDateChanged($0) }), displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .colorScheme(.dark)
            }
            
            VStack(alignment: .leading) {
                Text("Return")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                DatePicker("", selection: viewStore.binding(get: \.returnDate, send: { .returnDateChanged($0) }), displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .colorScheme(.dark)
            }
        }
    }
    
    private func passengersSection(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Passengers")
                .font(.caption)
                .foregroundColor(Theme.Palette.textSecondary)
            
            HStack(spacing: 20) {
                passengerCounter(
                    title: "Adults",
                    value: viewStore.adults,
                    binding: viewStore.binding(get: \.adults, send: { .adultsChanged($0) }),
                    range: 1...9
                )
                
                passengerCounter(
                    title: "Children",
                    value: viewStore.children,
                    binding: viewStore.binding(get: \.children, send: { .childrenChanged($0) }),
                    range: 0...9
                )
                
                passengerCounter(
                    title: "Infants",
                    value: viewStore.infants,
                    binding: viewStore.binding(get: \.infants, send: { .infantsChanged($0) }),
                    range: 0...9
                )
            }
        }
    }
    
    private func passengerCounter(title: String, value: Int, binding: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.Palette.textPrimary)
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.Palette.primaryRed)
            Stepper("", value: binding, in: range)
                .colorScheme(.dark)
        }
    }
    
    private func travelClassSection(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Travel Class")
                .font(.caption)
                .foregroundColor(Theme.Palette.textSecondary)
            
            Picker("Travel Class", selection: viewStore.binding(get: \.travelClass, send: { .travelClassChanged($0) })) {
                Text("Economy").tag("ECONOMY")
                Text("Business").tag("BUSINESS")
                Text("First").tag("FIRST")
            }
            .pickerStyle(SegmentedPickerStyle())
            .colorScheme(.dark)
        }
    }
    
    private func searchButton(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        Button(action: {
            viewStore.send(.searchFlights)
        }) {
            HStack {
                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(viewStore.isLoading ? "Searching..." : "Search Flights")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSearchEnabled ? Theme.Gradient.button : Theme.Gradient.surface)
            .foregroundColor(isSearchEnabled ? .white : Theme.Palette.textTertiary)
            .cornerRadius(10)
            .shadow(color: isSearchEnabled ? Theme.Shadow.red : .clear, radius: 4)
        }
        .disabled(viewStore.isLoading || !isSearchEnabled)
    }
    
    private func searchResultsSummaryView(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        Group {
            if let resultsCount = viewStore.searchResultsCount {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.Palette.success)
                            Text("Search Completed")
                                .font(.headline)
                                .foregroundColor(Theme.Palette.textPrimary)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Found \(resultsCount) flight\(resultsCount == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(Theme.Palette.textSecondary)
                            Spacer()
                            Text("View Results →")
                                .font(.subheadline)
                                .foregroundColor(Theme.Palette.primaryRed)
                        }
                    }
                    .padding()
                    .background(Theme.Gradient.surface)
                    .cornerRadius(12)
                    .shadow(color: Theme.Shadow.red, radius: 4)
                    
                    clearResultsButton(viewStore: viewStore)
                }
            }
        }
    }
    
    private func clearResultsButton(viewStore: ViewStoreOf<SearchFeature>) -> some View {
        Button(action: {
            viewStore.send(.clearResults)
        }) {
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(Theme.Palette.textSecondary)
                Text("Clear Results")
                    .font(.subheadline)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Theme.Palette.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.Palette.textTertiary, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Theme.Palette.surface)
            .foregroundColor(Theme.Palette.textPrimary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.Palette.primaryRed.opacity(0.3), lineWidth: 1)
            )
            .accentColor(Theme.Palette.primaryRed)
            .colorScheme(.dark)
    }
}


#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
