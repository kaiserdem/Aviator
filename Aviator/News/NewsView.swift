import SwiftUI
import ComposableArchitecture

struct NewsView: View {
    let store: StoreOf<NewsFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    if viewStore.isLoading {
                        ProgressView()
                            .cornerRadius(20)
                            .frame(width: 80, height: 80)
                            .cornerRadius(20)

                    } else if viewStore.posts.isEmpty {
                        ContentUnavailableView("No news", systemImage: "newspaper", description: Text("Please try again later"))
                    } else {
                        List(viewStore.posts) { post in
                            Button {
                                viewStore.send(.select(post))
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(post.title)
                                                .font(.title3)
                                                .foregroundStyle(Theme.Palette.textPrimary)
                                                .lineLimit(2)
                                            
                                            Text(post.description)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(2)
                                        }
                                        
                                        Spacer()
                                        
                                        if let imageURL = post.imageURL, !imageURL.isEmpty {
                                            AsyncImage(url: URL(string: imageURL)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .overlay(
                                                        Image(systemName: "photo")
                                                            .foregroundColor(.gray)
                                                    )
                                            }
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Text("by \(post.author)")
                                        Text("•")
                                        Text(post.source)
                                        Spacer()
                                        Text(post.createdAt, style: .relative)
                                    }
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("News")
                .navigationDestination(item: viewStore.binding(get: \.selected, send: { .select($0) })) { post in
                    NewsDetailView(post: post)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .scrollContentBackground(.hidden)
                        .background(Theme.Gradient.background)
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollContentBackground(.hidden)
                .background(Theme.Gradient.background)
                .task { await viewStore.send(.onAppear).finish() }
            }
        }
    }
}



