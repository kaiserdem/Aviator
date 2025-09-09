import SwiftUI
import ComposableArchitecture
import SafariServices

struct NewsView: View {
    let store: StoreOf<NewsFeature>
    @State private var safariURL: URL?

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                Group {
                    if viewStore.isLoading {
                        ProgressView("Loading…")
                    } else if viewStore.posts.isEmpty {
                        ContentUnavailableView("No news", systemImage: "newspaper", description: Text("Please try again later"))
                    } else {
                        List(viewStore.posts) { post in
                            Button {
                                safariURL = post.url
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(post.title)
                                        .font(.title2)
                                        .foregroundStyle(Theme.Palette.textPrimary)
                                    HStack(spacing: 8) {
                                        Text("by \(post.author)")
                                        Text(post.createdAt, style: .relative)
                                    }
                                    .foregroundStyle(.secondary)
                                    .font(.title3)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("News")
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollContentBackground(.hidden)
                .background(Theme.Gradient.background)
                .task { await viewStore.send(.onAppear).finish() }
                .sheet(item: $safariURL) { url in
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
            }
        }
    }
}

 extension URL: @retroactive Identifiable {
     public var id: String { absoluteString }
}

private struct SafariView: UIViewControllerRepresentable, Identifiable {
    let id = UUID()
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}


