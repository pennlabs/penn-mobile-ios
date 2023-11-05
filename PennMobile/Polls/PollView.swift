//
//  PollView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/29/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct PollOptionView: View {
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    var option: PollOption
    var chosenId: Int?
    var totalVoteCount: Int
    
    var isAnswered: Bool {
        chosenId == option.id
    }
    
    var showResults: Bool {
        chosenId != nil
    }
    
    var color: Color {
        if isAnswered {
            Color("blueLighter")
        } else if showResults {
            Color.labelTertiary
        } else {
            Color("greenLighter")
        }
    }
    
    var proportion: Double? {
        guard showResults, totalVoteCount != 0 else { return nil }
        let raw = Double(option.voteCount) / Double(totalVoteCount)
        return max(min(raw, 1), 0)
    }
    
    var percentageText: Text? {
        let check = Image(systemName: "checkmark.circle")
        
        if let proportion, let formatted = Self.percentFormatter.string(from: .init(value: proportion)) {
            if isAnswered {
                return Text("\(check) \(formatted)")
            } else {
                return Text(formatted)
            }
        }
        
        if isAnswered {
            return Text("\(check)")
        }
        
        return nil
    }
    
    var body: some View {
        HStack {
            Text(option.choice)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.vertical, 6)
            if showResults {
                Spacer()
                VStack(alignment: .trailing) {
                    percentageText?
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("^[\(option.voteCount) votes](inflect: true)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.trailing)
            }
        }
            .padding(.horizontal, 12)
            .frame(minHeight: 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .leading) {
                if let proportion {
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(color)
                            .frame(width: proportion * proxy.size.width)
                    }
                }
            }
            .background(color.opacity(showResults ? 0.3 : 1))
            .clipShape(.rect(cornerRadius: 6))
    }
}

struct PollView: View {
    var poll: PollQuestion
    var showPrivacyStatement = true
    
    var icon: Image {
        Image(systemName: "chart.bar.fill")
    }
    
    var deadlineText: String {
        let diffComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: poll.expireDate)
        var result = [String]()
        if let d = diffComponents.day, d > 0 {
            result.append("\(d)d")
        }
        if let h = diffComponents.hour, h > 0 {
            result.append("\(h)h")
        }
        if let mm = diffComponents.minute, mm > 0 {
            result.append("\(mm)m")
        }
        return result.joined(separator: " ")
    }
    
    var body: some View {
        HomeCardView {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(icon) Poll from \(poll.clubCode)")
                        .textCase(.uppercase)
                        .fontWeight(.medium)
                    Spacer()
                    Text(deadlineText)
                }
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding(.bottom, 2)
                
                Text(poll.question)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 4) {
                    ForEach(poll.options) { option in
                        PollOptionView(option: option, chosenId: poll.optionChosenId, totalVoteCount: poll.totalVoteCount)
                    }
                }
                
                if showPrivacyStatement {
                    Text("Penn Labs anonymously shares info with the organization.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
            .padding()
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    PollView(poll: .mock)
        .frame(width: 400)
        .padding(.vertical)
}
