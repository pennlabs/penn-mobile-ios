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
        ScrollView {
            VStack {
                ForEach(polls, id: \.self.id) { poll in
                    HomePollsCellWrapper(pollQuestion: poll.poll)
                        .frame(height: HomePollsCell.getPollHeight(for: poll.poll))
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

struct HomePollsCellWrapper: UIViewRepresentable {
    let pollQuestion: PollQuestion

    func makeUIView(context: Context) -> HomePollsCell {
        let cell = HomePollsCell()
        cell.pollQuestion = pollQuestion
        cell.isUserInteractionEnabled = false
        for cell in cell.tableView.visibleCells as! [PollOptionCell] {
            cell.answered = true
        }
        return cell
    }

    func updateUIView(_ uiView: HomePollsCell, context: Context) {
        uiView.pollQuestion = pollQuestion
    }
}

//
//func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: PollOptionCell.identifier, for: indexPath) as! PollOptionCell
//    let pollOption = pollQuestion.options[indexPath.row]
//
//    cell.totalResponses = pollQuestion.totalVoteCount
//    cell.answered = (pollQuestion.optionChosenId != nil)
//    cell.chosen = pollQuestion.optionChosenId == pollOption.id
//
//    cell.pollOption = pollOption
//
//    return cell
//}
//
//DispatchQueue.main.async {
//    self.pollQuestion.options[indexPath.row].voteCount += 1
//    // Change selected cell to chosen
//    let chosenCell = (tableView.cellForRow(at: indexPath) as! PollOptionCell)
//    chosenCell.pollOption.voteCount += 1
//    chosenCell.chosen = true
//
//    // Update cells to reflect question answered
//    for cell in tableView.visibleCells as! [PollOptionCell] {
//        cell.totalResponses += 1
//        cell.answered = true
//    }
//
//    // Update model
//    self.pollQuestion.optionChosenId = self.pollQuestion.options[indexPath.row].id
//}
