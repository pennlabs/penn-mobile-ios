//
//  PollsView.swift
//  PennMobile
//
//  Created by Jordan H on 9/10/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct PollsView: View {
    @State var polls: [PollPost] = []
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                if polls.isEmpty {
                    VStack {
                        Image(systemName: "list.bullet.clipboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .foregroundColor(.secondary)
                        Text("You have not voted on any polls yet! Keep your eye out for them on the home page!")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 70)
                            .padding(.top)
                    }
                    .padding(.top, -120)
                    .frame(minHeight: geo.size.height, alignment: .center)
                } else {
                    VStack {
                        ForEach(polls, id: \.self.id) { poll in
                            PollWrapper(pollQuestion: poll.poll, chosenId: poll.pollOptions[0].id)
                        }
                    }
                }
            }
        }
        .task {
            let pollsResult = await PollsNetworkManager.instance.getPollHistory()
            switch pollsResult {
            case .failure(let error):
                print(error)
            case .success(let polls):
                self.polls = polls
            }
        }
    }
}

struct PollWrapper: UIViewRepresentable {
    let pollQuestion: PollQuestion
    let chosenId: Int?
    var answeredPollQuestion: PollQuestion {
        var question = pollQuestion
        question.optionChosenId = chosenId
        return question
    }

    func makeUIView(context: Context) -> HomePollsCell {
        let cell = HomePollsCell()
        cell.pollQuestion = answeredPollQuestion
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: HomePollsCell, context: Context) -> CGSize? {
        return CGSize(width: proposal.width ?? 0, height: HomePollsCell.getPollHeight(for: answeredPollQuestion))
    }

    func updateUIView(_ uiView: HomePollsCell, context: Context) {
        uiView.pollQuestion = answeredPollQuestion
    }
}
