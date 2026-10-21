//
//  PostCardView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

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
        if let url = post.postUrl.flatMap({ URL(string: $0) }) {
            Link(destination: url) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PostCardView(post: Post(id: 1, title: "Congratulations!", subtitle: "You are our lucky winner", postUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", imageUrl: "https://www.nps.gov/common/uploads/cropped_image/primary/D1721D51-A497-281A-72B8C06573F9327A.jpg?width=1600&quality=90&mode=crop", createdDate: Date(), startDate: Date.midnightYesterday, expireDate: Date.midnightToday, source: "Totally Legit Source"))
        .frame(width: 400)
        .padding(.vertical)
}
