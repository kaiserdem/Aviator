import SwiftUI
import ComposableArchitecture
import UIKit

struct PilotsView: View {
    let store: StoreOf<PilotsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    Theme.Gradients.primary
                        .ignoresSafeArea()
                    
                    VStack {
                        if viewStore.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(Theme.Palette.white)
                                Text("Loading pilots...")
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
                        } else if viewStore.pilots.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "airplane")
                                    .font(.system(size: 80))
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                Text("Great Pilots")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                Text("No pilots data available")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            VStack(spacing: 0) {
                                // Фільтри
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        FilterChip(
                                            title: "All",
                                            isSelected: viewStore.selectedEra == nil && viewStore.selectedCategory == nil,
                                            action: {
                                                viewStore.send(.selectEra(nil))
                                                viewStore.send(.selectCategory(nil))
                                            }
                                        )
                                        
                                        ForEach(PilotEra.allCases, id: \.self) { era in
                                            FilterChip(
                                                title: era.rawValue,
                                                isSelected: viewStore.selectedEra == era,
                                                action: { viewStore.send(.selectEra(era)) }
                                            )
                                        }
                                        
                                        ForEach(PilotCategory.allCases, id: \.self) { category in
                                            FilterChip(
                                                title: category.rawValue,
                                                isSelected: viewStore.selectedCategory == category,
                                                action: { viewStore.send(.selectCategory(category)) }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 30)
                                }
                                .padding(.vertical, 8)
                                
                                // Список пілотів
                                List(filteredPilots(viewStore)) { pilot in
                                    Button {
                                        viewStore.send(.selectPilot(pilot))
                                    } label: {
                                        PilotRowView(pilot: pilot)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                .listStyle(PlainListStyle())
                                .scrollContentBackground(.hidden)
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Great Pilots")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.darkRed)
                                .padding(.top, 50)
                        }
                    }
                    .navigationDestination(item: viewStore.binding(get: \.selectedPilot, send: { .selectPilot($0) })) { pilot in
                        PilotDetailView(pilot: pilot)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
                
                // Налаштування кольору заголовка навігації
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.clear
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor(red: 0.7, green: 0.13, blue: 0.13, alpha: 1.0) // Червоний колір
                ]
                appearance.largeTitleTextAttributes = [
                    .foregroundColor: UIColor(red: 0.7, green: 0.13, blue: 0.13, alpha: 1.0) // Червоний колір
                ]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
            }
        }
    }
    
    private func filteredPilots(_ viewStore: ViewStoreOf<PilotsFeature>) -> [Pilot] {
        var pilots = viewStore.pilots
        
        if let era = viewStore.selectedEra {
            pilots = pilots.filter { $0.era == era }
        }
        
        if let category = viewStore.selectedCategory {
            pilots = pilots.filter { $0.category == category }
        }
        
        return pilots
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.Gradients.soft)
                .foregroundColor(Theme.Palette.white)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PilotRowView: View {
    let pilot: Pilot
    
    var body: some View {
        HStack(spacing: 12) {
            // Зображення пілота
            Group {
                if UIImage(named: pilot.imageName) != nil {
                    // Локальне зображення з Assets
                    Image(pilot.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else if let imageURL = pilot.imageURL {
                    // Завантаження з інтернету
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                            .frame(width: 60, height: 60)
                            .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                            .cornerRadius(30)
                    }
                } else {
                    // Плейсхолдер
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                        .frame(width: 60, height: 60)
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                        .cornerRadius(30)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pilot.name)
                    .font(.headline)
                    .foregroundColor(Theme.Palette.white)
                
                Text(pilot.fullName)
                    .font(.subheadline)
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                
                HStack(spacing: 8) {
                    Text(pilot.era.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.Gradients.vibrant)
                        .foregroundColor(Theme.Palette.white)
                        .cornerRadius(4)
                    
                    Text(pilot.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.Palette.white.opacity(0.2))
                        .foregroundColor(Theme.Palette.white)
                        .cornerRadius(4)
                }
                
                Text(pilot.nationality)
                    .font(.caption)
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textTertiary))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.Palette.darkRed)
                .font(.caption)
        }
        .padding()
        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
        .cornerRadius(12)
        .shadow(color: Theme.Shadows.medium, radius: 4)
    }
}

struct PilotDetailView: View {
    let pilot: Pilot
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Зображення пілота
                Group {
                    if UIImage(named: pilot.imageName) != nil {
                        // Локальне зображення з Assets
                        Image(pilot.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Theme.Shadows.medium, radius: 12)
                    } else if let imageURL = pilot.imageURL {
                        // Завантаження з інтернету
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Theme.Shadows.medium, radius: 12)
                        } placeholder: {
                            Image(systemName: "person.crop.rectangle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    } else {
                        // Плейсхолдер
                        Image(systemName: "person.crop.rectangle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 16)
                
                // Заголовок
                VStack(alignment: .leading, spacing: 8) {
                    Text(pilot.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.white)
                    
                    Text(pilot.fullName)
                        .font(.title2)
                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                    
                    HStack(spacing: 12) {
                        Text(pilot.era.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.Gradients.vibrant)
                            .foregroundColor(Theme.Palette.white)
                            .cornerRadius(6)
                        
                        Text(pilot.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.Palette.white.opacity(0.2))
                            .foregroundColor(Theme.Palette.white)
                            .cornerRadius(6)
                    }
                }
                
                // Основна інформація
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(title: "Nationality", value: pilot.nationality)
                    InfoRow(title: "Born", value: pilot.birthDate)
                    if let deathDate = pilot.deathDate {
                        InfoRow(title: "Died", value: deathDate)
                    }
                }
                
                Divider()
                    .background(Theme.Palette.darkRed)
                
                // Біографія
                VStack(alignment: .leading, spacing: 8) {
                    Text("Biography")
                        .font(.headline)
                        .foregroundColor(Theme.Palette.white)
                    
                    Text(pilot.biography)
                        .font(.body)
                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                    .background(Theme.Palette.darkRed)
                
                // Досягнення
                VStack(alignment: .leading, spacing: 8) {
                    Text("Achievements")
                        .font(.headline)
                        .foregroundColor(Theme.Palette.white)
                    
                    ForEach(pilot.achievements, id: \.self) { achievement in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Theme.Palette.vibrantPink)
                                .font(.caption)
                                .padding(.top, 2)
                            
                            Text(achievement)
                                .font(.body)
                                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                // Кнопки дій
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        // Кнопка копіювання лінку
                        Button(action: {
                            copyPilotLink(pilot)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Copy Link")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(Theme.Palette.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Theme.Palette.white.opacity(0.2))
                            .cornerRadius(12)
                        }
                        
                        // Кнопка поширення
                        Button(action: {
                            sharePilot(pilot)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Share")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(Theme.Palette.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Theme.Gradients.vibrant)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Theme.Gradients.primary)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.Palette.white)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
        }
    }
}

// MARK: - Helper Functions

extension PilotDetailView {
    private func copyPilotLink(_ pilot: Pilot) {
        let pilotInfo = """
        \(pilot.name) (\(pilot.fullName))
        
        Nationality: \(pilot.nationality)
        Born: \(pilot.birthDate)
        \(pilot.deathDate != nil ? "Died: \(pilot.deathDate!)" : "")
        
        Achievements:
        \(pilot.achievements.map { "• \($0)" }.joined(separator: "\n"))
        
        Biography:
        \(pilot.biography)
        """
        
        UIPasteboard.general.string = pilotInfo
        
        // Показуємо підтвердження (можна додати toast notification)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func sharePilot(_ pilot: Pilot) {
        let pilotInfo = """
        \(pilot.name) (\(pilot.fullName))
        
        Nationality: \(pilot.nationality)
        Born: \(pilot.birthDate)
        \(pilot.deathDate != nil ? "Died: \(pilot.deathDate!)" : "")
        
        Achievements:
        \(pilot.achievements.map { "• \($0)" }.joined(separator: "\n"))
        
        Biography:
        \(pilot.biography)
        """
        
        let activityViewController = UIActivityViewController(
            activityItems: [pilotInfo],
            applicationActivities: nil
        )
        
        // Для iPad
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            activityViewController.popoverPresentationController?.sourceView = window
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = []
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}
