import SwiftUI
import ComposableArchitecture

struct AviationView: View {
    let store: StoreOf<AviationEventsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    Theme.Gradients.primary
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(AviationEventsFeature.State.EventTab.allCases, id: \.self) { tab in
                                Button(action: {
                                    viewStore.send(.selectTab(tab))
                                }) {
                                    VStack(spacing: 8) {
                                        Text(tab.displayName)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(viewStore.selectedTab == tab ? Theme.Palette.darkRed : Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                        
                                        Rectangle()
                                            .fill(viewStore.selectedTab == tab ? Theme.Palette.darkRed : Color.clear)
                                            .frame(height: 2)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                            
                            TextField("Search events...", text: viewStore.binding(
                                get: \.searchText,
                                send: AviationEventsFeature.Action.searchTextChanged
                            ))
                            .foregroundColor(Theme.Palette.white)
                            .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterChip(
                                    title: "All",
                                    isSelected: viewStore.selectedSportFilter == nil,
                                    action: {
                                        viewStore.send(.selectSportFilter(nil))
                                    }
                                )
                                
                                ForEach(viewStore.availableSports, id: \.self) { sport in
                                    FilterChip(
                                        title: sport.displayName,
                                        isSelected: viewStore.selectedSportFilter == sport,
                                        action: {
                                            viewStore.send(.selectSportFilter(sport))
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 16)
                        
                        if viewStore.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(Theme.Palette.white)
                                Text("Loading events...")
                                    .foregroundColor(Theme.Palette.white)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let errorMessage = viewStore.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(Theme.Palette.brightOrangeRed)
                                Text("Error")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                Text(errorMessage)
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            let events = viewStore.filteredEvents
                            
                            if events.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 80))
                                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                    Text("No Events Found")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Palette.white)
                                    Text("Try adjusting your filters or search terms")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ScrollView {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 16) {
                                        ForEach(events) { event in
                                            AviationEventCardView(event: event)
                                                .onTapGesture {
                                                    viewStore.send(.selectEvent(event))
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                                }
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Aviation Events")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.darkRed)
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .sheet(item: viewStore.binding(
                get: \.selectedEvent,
                send: AviationEventsFeature.Action.selectEvent
            )) { event in
                AviationEventDetailView(event: event)
            }
        }
    }
}

struct AviationEventCardView: View {
    let event: AviationEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: event.sport.icon)
                    .font(.title2)
                    .foregroundColor(Theme.Palette.darkRed)
                
                Spacer()
                
                Text(event.classification.shortName)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.Palette.darkRed.opacity(0.8))
                    .foregroundColor(Theme.Palette.white)
                    .cornerRadius(4)
            }
            Text(event.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Theme.Palette.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Theme.Palette.darkRed)
                    .font(.caption)
                Text(event.dateRange)
                    .font(.caption)
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
            }
            HStack {
                Image(systemName: "location")
                    .foregroundColor(Theme.Palette.darkRed)
                    .font(.caption)
                Text("\(event.location), \(event.country)")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                    .lineLimit(1)
            }
            Text(event.sport.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Theme.Palette.darkRed)
        }
        .padding(12)
        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
        .cornerRadius(12)
        .shadow(color: Theme.Shadows.medium, radius: 4)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Theme.Palette.darkRed : Theme.Palette.white.opacity(0.2))
                .foregroundColor(isSelected ? Theme.Palette.white : Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                .cornerRadius(16)
        }
    }
}

struct AviationEventDetailView: View {
    let event: AviationEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Gradients.primary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(event.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                            
                            HStack(spacing: 8) {
                                Text(event.sport.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.Gradients.vibrant)
                                    .foregroundColor(Theme.Palette.white)
                                    .cornerRadius(8)
                                
                                Text(event.classification.shortName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.Palette.white.opacity(0.2))
                                    .foregroundColor(Theme.Palette.white)
                                    .cornerRadius(8)
                                
                                Text(event.eventType.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.Palette.darkRed.opacity(0.8))
                                    .foregroundColor(Theme.Palette.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                        .cornerRadius(12)
                        .shadow(color: Theme.Shadows.medium, radius: 4)
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Event Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.white)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                InfoRow(icon: "calendar", title: "Event Dates", value: event.dateRange)
                                InfoRow(icon: "location", title: "Location", value: "\(event.location), \(event.country)")
                                InfoRow(icon: "figure.stand", title: "Discipline", value: event.discipline)
                                InfoRow(icon: "building.2", title: "Organizer", value: event.organizer)
                                InfoRow(icon: "airplane", title: "Sport Category", value: event.sport.displayName)
                                InfoRow(icon: "trophy", title: "Event Type", value: event.eventType.displayName)
                                InfoRow(icon: "tag", title: "Classification", value: event.classification.displayName)
                                InfoRow(icon: "number", title: "Event ID", value: event.id)
                                
                                if let alternateDates = event.alternateDates {
                                    InfoRow(icon: "calendar.badge.clock", title: "Alternate Dates", value: alternateDates)
                                }
                            }
                        }
                        .padding()
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                        .cornerRadius(12)
                        .shadow(color: Theme.Shadows.medium, radius: 4)
                        if event.contactPerson != nil || event.contactEmail != nil || event.contactPhone != nil {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Contact Information")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    if let contactPerson = event.contactPerson {
                                        InfoRow(icon: "person", title: "Contact Person", value: contactPerson)
                                    }
                                    
                                    if let contactEmail = event.contactEmail {
                                        InfoRow(icon: "envelope", title: "Email", value: contactEmail)
                                    }
                                    
                                    if let contactPhone = event.contactPhone {
                                        InfoRow(icon: "phone", title: "Phone", value: contactPhone)
                                    }
                                }
                            }
                            .padding()
                            .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                            .cornerRadius(12)
                            .shadow(color: Theme.Shadows.medium, radius: 4)
                        }
                        
                        if let documents = event.documents, !documents.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Documents & Links")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(documents, id: \.self) { document in
                                        HStack {
                                            Image(systemName: "doc.text")
                                                .foregroundColor(Theme.Palette.darkRed)
                                                .font(.subheadline)
                                            Text(document)
                                                .font(.body)
                                                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                            .cornerRadius(12)
                            .shadow(color: Theme.Shadows.medium, radius: 4)
                        }
                        
                        if event.websiteURL != nil || event.faiMiniSiteURL != nil {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Official Links")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    if let websiteURL = event.websiteURL {
                                        HStack {
                                            Image(systemName: "globe")
                                                .foregroundColor(Theme.Palette.darkRed)
                                                .font(.subheadline)
                                            Text("Organizer Website: \(websiteURL)")
                                                .font(.body)
                                                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                            Spacer()
                                        }
                                    }
                                    
                                    if let faiMiniSiteURL = event.faiMiniSiteURL {
                                        HStack {
                                            Image(systemName: "link")
                                                .foregroundColor(Theme.Palette.darkRed)
                                                .font(.subheadline)
                                            Text("FAI Mini-site: \(faiMiniSiteURL)")
                                                .font(.body)
                                                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                            .cornerRadius(12)
                            .shadow(color: Theme.Shadows.medium, radius: 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Palette.darkRed)
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Theme.Palette.darkRed)
                .font(.subheadline)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textTertiary))
                
                Text(value)
                    .font(.body)
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AviationView(
        store: Store(initialState: AviationEventsFeature.State()) {
            AviationEventsFeature()
        }
    )
}

