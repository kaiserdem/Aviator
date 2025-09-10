import SwiftUI
import ComposableArchitecture
import WebKit

struct NewsView: View {
    let store: StoreOf<NewsFeature>
    @State private var webURL: URL?

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
                                webURL = post.url
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(post.title)
                                        .font(.title3)
                                        .foregroundStyle(Theme.Palette.textPrimary)
                                    HStack(spacing: 8) {
                                        Text("by \(post.author)")
                                        Text(post.createdAt, style: .relative)
                                    }
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("News")
                .navigationDestination(item: viewStore.binding(get: \.selected, send: { .select($0) })) { post in
                    NewsWebScreen(title: post.title, url: post.url)
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

// Simple WKWebView wrapper for SwiftUI (без індикатора)
private struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black
        view.load(URLRequest(url: url))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }
}

// Full screen in-app web screen with title
private struct NewsWebScreen: View, Identifiable {
    let id = UUID()
    let title: String
    let url: URL?
    var body: some View {
        if let url = url {
            WebContentView(title: title, url: url)
        } else {
            ContentUnavailableView("Invalid URL", systemImage: "xmark.circle")
        }
    }
}

private struct WebContentView: View {
    let title: String
    let url: URL
    var body: some View {
        WebView(url: url)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Theme.Gradient.background)
    }
}


