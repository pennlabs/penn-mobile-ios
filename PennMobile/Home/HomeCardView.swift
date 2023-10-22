//
//  HomeCardView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import SwiftSoup

struct HomeCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(Material.regular)
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
            .padding(.horizontal)
    }
}

struct GenericPostCardView: View {
    var icon: Image
    var source: String
    
    var title: String?
    var description: String?
    var imageURL: URL?
    var dateLabel: LocalizedStringKey?
    
    var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(icon) \(source)")
                    .textCase(.uppercase)
                    .fontWeight(.medium)
                if let dateLabel {
                    Spacer()
                    Text(dateLabel)
                }
            }
            .foregroundStyle(.secondary)
            .font(.caption)
            .padding(.bottom, 2)
            
            VStack(alignment: .leading) {
                if let title {
                    Text(title)
                        .fontWeight(.semibold)
                        .font(.headline)
                }
                
                if let description {
                    Text(description)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        HomeCardView {
            if let imageURL {
                content
                    .padding(.top, 150)
                    .background(ZStack(alignment: .bottom) {
                        KFImage(imageURL)
                            .resizable()
                            .scaledToFill()
                        Rectangle().fill(Material.ultraThin)
                        KFImage(imageURL)
                            .resizable()
                            .scaledToFill()
                            .mask(alignment: .center) {
                                VStack(spacing: 0) {
                                    Rectangle().fill(.black).frame(height: 93)
                                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom).frame(height: 64)
                                    Rectangle().fill(.clear)
                                }
                            }
                    })
                    .environment(\.colorScheme, .dark)
            } else {
                content
            }
        }
    }
}

struct PostCardView: View {
    var post: Post
    
    var dateFormat: Date.FormatStyle {
        Date.FormatStyle()
            .month(.defaultDigits)
            .day(.defaultDigits)
    }
    
    var content: some View {
        GenericPostCardView(
            icon: Image(systemName: "megaphone"),
            source: post.source ?? "Announcement",
            title: post.title,
            description: post.subtitle,
            imageURL: URL(string: post.imageUrl),
            dateLabel: "\(post.startDate, format: dateFormat) - \(post.expireDate, format: dateFormat)"
        )
    }
    
    var body: some View {
        Group {
            if let url = post.postUrl.flatMap({ URL(string: $0) }) {
                Link(destination: url) {
                    content
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                content
            }
        }
    }
}

struct NewsCardView: View {
    var article: NewsArticle
    
    var abstract: String? {
        try? SwiftSoup.parse(article.abstract).text()
    }
    
    var body: some View {
        NavigationLink {
            NewsDetailView(article: article)
                .navigationTitle(Text("News"))
        } label: {
            GenericPostCardView(
                icon: Image(systemName: "newspaper"),
                source: "The Daily Pennsylvanian",
                title: article.headline,
                description: abstract,
                imageURL: URL(string: article.dominantMedia.imageUrl),
                dateLabel: "\(article.published_at)"
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NewsDetailView: UIViewControllerRepresentable {
    var article: NewsArticle
    
    func makeUIViewController(context: Context) -> NativeNewsViewController {
        let controller = NativeNewsViewController()
        updateUIViewController(controller, context: context)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: NativeNewsViewController, context: Context) {
        uiViewController.article = article
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 16) {
        PostCardView(post: Post(id: 1, title: "Congratulations!", subtitle: "You are our lucky winner", postUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", imageUrl: "https://www.cnet.com/a/img/resize/2bec42558a71a3922e6e590476b919288a015288/hub/2017/06/01/a176bcb9-1442-4d6d-a7d9-f01efdbcc4bc/broken-screen-ipad-6200-002.jpg?auto=webp&fit=crop&height=675&width=1200", createdDate: Date(), startDate: Date.midnightYesterday, expireDate: Date.midnightToday, source: "Totally Legit Source"))
    }
    .frame(width: 400)
    .padding(.vertical)
}
