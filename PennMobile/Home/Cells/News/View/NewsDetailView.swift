//
//  NewsDetailView.swift
//  PennMobile
//
//  Created by Jacky on 2/9/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

// MARK: - used to replace NativeVewsViewController (navigation to news article from HomeView) (works in tandem with Anthony's NewsCardView in HomeCardView)

import SwiftUI
import Kingfisher
import SwiftSoup

struct NewsDetailView: View {
    
    var article: NewsArticle
    
    @Environment(\.dismiss) private var dismiss
    
    private func extractParagraphs(from html: String) -> [String] {
        do {
            let doc = try SwiftSoup.parse(html)
            let pElements = try doc.select("p")
            let paragraphs = try pElements.map { try $0.text() }
            return paragraphs.isEmpty ? [html] : paragraphs
        } catch {
            return [html]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // article headline (custom font for now?)
                Text(article.headline)
                    .font(.custom("Libre Baskerville Bold", size: 30))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                // image with zoom on scroll behavior like in DiningVenueDetailView
                GeometryReader { geometry in
                    let minY = geometry.frame(in: .global).minY
                    KFImage(URL(string: article.dominantMedia.imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 150 + max(0, minY))
                        .offset(y: min(0, minY) * -2/3)
                        .allowsHitTesting(false)
                        .clipped()
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .zIndex(2)
                
                // authors
                Text("\(article.data.labsArticle.authors.map { $0.name }.joined(separator: ", ")) • \(article.published_at)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // article content
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(extractParagraphs(from: article.content), id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.system(size: 16, weight: .regular))
                            .lineSpacing(6)
                    }
                }
                .padding(.horizontal)
                
                // read more sectino with same DP logo as before
                VStack(spacing: 8) {
                    Image("dpPlusLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 150, maxHeight: 150)
                        .padding(.horizontal)
                    
                    // links to DP app on app store
                    Button(action: {
                        if let url = URL(string: "itms-apps://apple.com/app/id1550818171"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Read more on DP+")
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                        // this is if we want the design choice of a button instead of just the text like it used to be
//                            .padding()
//                            .background(Color.primary)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.top, 15)
                }
                
                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.primary)
        })
        .navigationTitle("")
    }
}

// extension to to convert the text to AttributedString
extension AttributedString {
    init?(html: String) {
        guard let data = html.data(using: .utf8) else { return nil }
        if let nsAttrStr = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            self.init(nsAttrStr)
        } else {
            return nil
        }
    }
}
