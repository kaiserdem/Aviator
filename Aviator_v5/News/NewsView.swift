import SwiftUI
import ComposableArchitecture

struct NewsView: View {
    let store: StoreOf<NewsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    LinearGradient(
                        colors: [.green.opacity(0.8), .blue.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack {
                        if viewStore.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                Text("Loading news...")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let errorMessage = viewStore.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.red)
                                Text("Error")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(errorMessage)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.newsItems.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "newspaper")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("News")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Latest aviation news will appear here")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
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
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white.opacity(0.1))
                }
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            } else {
                Image(systemName: "newspaper")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 80, height: 80)
                    .background(.white.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(newsItem.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Text(newsItem.summary)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(newsItem.category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 4)
    }
}

#Preview {
    NewsView(
        store: Store(initialState: NewsFeature.State()) {
            NewsFeature()
        }
    )
}
