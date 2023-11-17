//
//  PollsView.swift
//  PennMobile
//
//  Created by Jordan H on 9/10/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct PollsView: View {
    @State var polls: [PollQuestion] = []
    
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
                            .padding([.leading, .trailing], 70)
                            .padding(.top)
                    }
                    .padding(.top, -120)
                    .frame(minHeight: geo.size.height, alignment: .center)
                } else {
                    VStack {
                        ForEach(polls) { poll in
                            PollView(poll: poll)
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
                self.polls = polls.map {
                    var pollQuestion = $0.poll
                    pollQuestion.optionChosenId = $0.pollOptions[0].id; // id of first returned selected answer
                    return pollQuestion
                }
            }
        }
    }
}
