import SwiftUI
import ComposableArchitecture

struct NewsView: View {
    let store: StoreOf<NewsFeature>
    
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
                                Text("Loading news...")
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
                        } else if viewStore.newsItems.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "newspaper")
                                    .font(.system(size: 80))
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                Text("News")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                Text("Latest aviation news will appear here")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(viewStore.newsItems) { newsItem in
                                Button {
                                    viewStore.send(.selectNews(newsItem))
                                } label: {
                                    NewsRowView(newsItem: newsItem)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                        }
                    }
                    .navigationTitle("News")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .navigationDestination(item: viewStore.binding(get: \.selectedNews, send: { .selectNews($0) })) { newsItem in
                        NewsDetailView(newsItem: newsItem)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct NewsRowView: View {
    let newsItem: NewsItem
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: newsItem.date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageURL = newsItem.imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "photo")
                        .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textTertiary))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                }
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            } else {
                Image(systemName: "newspaper")
                    .font(.title2)
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textTertiary))
                    .frame(width: 80, height: 80)
                    .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(newsItem.title)
                            .font(.headline)
                            .foregroundColor(Theme.Palette.white)
                            .lineLimit(2)
                        
                        Text(newsItem.summary)
                            .font(.subheadline)
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(newsItem.category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Theme.Gradients.vibrant)
                            .foregroundColor(Theme.Palette.white)
                            .cornerRadius(4)
                        
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textTertiary))
                            .font(.caption)
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

#Preview {
    NewsView(
        store: Store(initialState: NewsFeature.State()) {
            NewsFeature()
        }
    )
}
