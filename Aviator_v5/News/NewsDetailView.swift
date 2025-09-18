import SwiftUI

struct NewsDetailView: View {
    let newsItem: NewsItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = newsItem.imageURL, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(.white.opacity(0.1))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.title)
                            )
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(newsItem.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.white)
                            Text("Author")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Text(newsItem.category)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.leading, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.white)
                            Text("Source")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Text(newsItem.category)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.leading, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                            Text("Published")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Text(newsItem.date, style: .date)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.leading, 20)
                        
                        Text(newsItem.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.leading, 20)
                    }
                    
                    Divider()
                        .background(.white.opacity(0.3))
                        .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.white)
                            Text("Description")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Text(newsItem.summary)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 20)
                    }
                    
                    if !newsItem.url.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.white)
                                Text("Article URL")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            
                            Text(newsItem.url)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 20)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button(action: {
                                UIPasteboard.general.string = newsItem.url
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Link to Clipboard")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .background(
            LinearGradient(
                colors: [.green.opacity(0.8), .blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
