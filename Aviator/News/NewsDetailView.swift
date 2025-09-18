import SwiftUI

struct NewsDetailView: View {
    let post: NewsPost
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
                                    .font(.title)
                            )
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(post.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.Palette.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(Theme.Palette.accentGreen)
                            Text("Author")
                                .font(.subheadline)
                                .foregroundStyle(Theme.Palette.textPrimary)
                        }
                        Text(post.author)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(Theme.Palette.accentGreen)
                            Text("Source")
                                .font(.subheadline)
                                .foregroundStyle(Theme.Palette.textPrimary)
                        }
                        Text(post.source)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Theme.Palette.accentGreen)
                            Text("Published")
                                .font(.subheadline)
                                .foregroundStyle(Theme.Palette.textPrimary)
                        }
                        Text(post.createdAt, style: .date)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 20)
                        
                        Text(post.createdAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 20)
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(Theme.Palette.accentGreen)
                            Text("Description")
                                .font(.subheadline)
                                .foregroundStyle(Theme.Palette.textPrimary)
                        }
                        Text(post.description)
                            .font(.body)
                            .foregroundStyle(Theme.Palette.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 20)
                    }
                    
                    if let url = post.url {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(Theme.Palette.accentGreen)
                                Text("Article URL")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.Palette.textPrimary)
                            }
                            
                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 20)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button(action: {
                                UIPasteboard.general.string = url.absoluteString
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Link to Clipboard")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.Palette.accentGreen)
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
        .background(Theme.Gradient.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}
