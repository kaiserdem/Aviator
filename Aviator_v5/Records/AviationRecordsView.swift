import SwiftUI
import ComposableArchitecture

struct AviationRecordsView: View {
    let store: StoreOf<AviationRecordsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    Theme.Gradients.primary
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                            
                            TextField("Search records...", text: viewStore.binding(
                                get: \.searchText,
                                send: AviationRecordsFeature.Action.searchTextChanged
                            ))
                            .foregroundColor(Theme.Palette.white)
                            .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        
                        // Category Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterChip(
                                    title: "All",
                                    isSelected: viewStore.selectedCategory == nil,
                                    action: {
                                        viewStore.send(.selectCategory(nil))
                                    }
                                )
                                
                                ForEach(viewStore.availableCategories, id: \.self) { category in
                                    FilterChip(
                                        title: category.displayName,
                                        isSelected: viewStore.selectedCategory == category,
                                        action: {
                                            viewStore.send(.selectCategory(category))
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 16)
                        
                        // Content
                        if viewStore.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(Theme.Palette.white)
                                Text("Loading records...")
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
                            let records = viewStore.filteredRecords
                            
                            if records.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "trophy")
                                        .font(.system(size: 80))
                                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                    Text("No Records Found")
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
                                        ForEach(records) { record in
                                            AviationRecordCardView(record: record)
                                                .onTapGesture {
                                                    viewStore.send(.selectRecord(record))
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
                            Text("Aviation Records")
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
                get: \.selectedRecord,
                send: AviationRecordsFeature.Action.selectRecord
            )) { record in
                AviationRecordDetailView(record: record)
            }
        }
    }
}

struct AviationRecordCardView: View {
    let record: AviationRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category іконка та рік
            HStack {
                Image(systemName: record.category.icon)
                    .font(.title2)
                    .foregroundColor(Theme.Palette.darkRed)
                
                Spacer()
                
                Text("\(record.year)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.Palette.darkRed.opacity(0.8))
                    .foregroundColor(Theme.Palette.white)
                    .cornerRadius(4)
            }
            
            // Назва рекорду
            Text(record.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Theme.Palette.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Значення рекорду
            Text(record.displayValue)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Theme.Palette.darkRed)
            
            // Пілот (якщо є)
            if let pilot = record.pilot {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(Theme.Palette.darkRed)
                        .font(.caption)
                    Text(pilot)
                        .font(.caption)
                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                        .lineLimit(1)
                }
            }
            
            // Літак (якщо є)
            if let aircraft = record.aircraft {
                HStack {
                    Image(systemName: "airplane")
                        .foregroundColor(Theme.Palette.darkRed)
                        .font(.caption)
                    Text(aircraft)
                        .font(.caption)
                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
        .cornerRadius(12)
        .shadow(color: Theme.Shadows.medium, radius: 4)
    }
}

struct AviationRecordDetailView: View {
    let record: AviationRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Gradients.primary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 16) {
                            Text(record.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                            
                            HStack(spacing: 8) {
                                Text(record.category.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.Gradients.vibrant)
                                    .foregroundColor(Theme.Palette.white)
                                    .cornerRadius(8)
                                
                                Text("\(record.year)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.Palette.white.opacity(0.2))
                                    .foregroundColor(Theme.Palette.white)
                                    .cornerRadius(8)
                                
                                if record.isCurrentRecord {
                                    Text("CURRENT")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Theme.Palette.darkRed.opacity(0.8))
                                        .foregroundColor(Theme.Palette.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                        .cornerRadius(12)
                        .shadow(color: Theme.Shadows.medium, radius: 4)
                        
                        // Record Details
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Record Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.white)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                InfoRow(icon: "trophy", title: "Record Value", value: record.displayValue)
                                InfoRow(icon: "doc.text", title: "Description", value: record.description)
                                
                                if let pilot = record.pilot {
                                    InfoRow(icon: "person", title: "Pilot", value: pilot)
                                }
                                
                                if let aircraft = record.aircraft {
                                    InfoRow(icon: "airplane", title: "Aircraft", value: aircraft)
                                }
                                
                                if let location = record.location {
                                    InfoRow(icon: "location", title: "Location", value: location)
                                }
                                
                                InfoRow(icon: "calendar", title: "Year", value: "\(record.year)")
                                
                                if let previousRecord = record.previousRecord {
                                    InfoRow(icon: "clock.arrow.circlepath", title: "Previous Record", value: previousRecord)
                                }
                                
                                // FAI Information
                                if let faiId = record.faiId {
                                    InfoRow(icon: "number", title: "FAI Record ID", value: faiId)
                                }
                                
                                if let faiClass = record.faiClass {
                                    InfoRow(icon: "airplane", title: "FAI Class", value: faiClass)
                                }
                                
                                if let faiSubClass = record.faiSubClass {
                                    InfoRow(icon: "tag", title: "FAI Sub-Class", value: faiSubClass)
                                }
                                
                                if let recordType = record.recordType {
                                    InfoRow(icon: "doc.text", title: "Record Type", value: recordType)
                                }
                                
                                if let performance = record.performance {
                                    InfoRow(icon: "speedometer", title: "Performance", value: performance)
                                }
                                
                                if let date = record.date {
                                    InfoRow(icon: "calendar.badge.clock", title: "Date", value: date)
                                }
                                
                                if let claimant = record.claimant {
                                    InfoRow(icon: "person.badge.plus", title: "Claimant", value: claimant)
                                }
                                
                                if let status = record.status {
                                    InfoRow(icon: "checkmark.circle", title: "Status", value: status)
                                }
                                
                                if let region = record.region {
                                    InfoRow(icon: "globe", title: "Region", value: region)
                                }
                            }
                        }
                        .padding()
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                        .cornerRadius(12)
                        .shadow(color: Theme.Shadows.medium, radius: 4)
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

#Preview {
    AviationRecordsView(
        store: Store(initialState: AviationRecordsFeature.State()) {
            AviationRecordsFeature()
        }
    )
}
