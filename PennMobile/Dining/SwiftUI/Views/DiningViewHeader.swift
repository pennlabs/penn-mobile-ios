//
//  DiningViewHeader.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

struct DiningViewHeader: View {

    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    @EnvironmentObject var diningAnalyticsViewModel: DiningAnalyticsViewModel
    @State var alertIsPresented = false

    var body: some View {

        VStack {
            HStack {
                DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "dollarsign.circle.fill"), balance: Double(diningVM.diningBalance.diningDollars) ?? 0.0, specifier: "%.2f", dollarSign: true)
                DiningBalanceView(description: "Swipes", image: Image(systemName: "creditcard.fill"), balance: Double(diningVM.diningBalance.regularVisits), specifier: "%.0f")
            }
            HStack {
                DiningBalanceView(description: "Guest Swipes", image: Image(systemName: "person.2.fill"), balance: Double(diningVM.diningBalance.guestVisits), specifier: "%.0f")
                AnalyticsCardView(text: "Analytics!")
                    .environmentObject(diningAnalyticsViewModel)
            }
        }

    }
}

struct DiningViewHeaderDate: View {
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: Date()).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(dateString)
                .font(.system(.caption))
                .fontWeight(.bold)
                .foregroundColor(.gray)

            Text("Dining")
                .font(.system(.title))
                .fontWeight(.bold)
        }
    }
}

struct DiningViewHeaderBalance: View {
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Label("\(diningVM.diningBalance.regularVisits)", systemImage: "creditcard.fill")
                .labelStyle(BalanceLabelStyle())

            Label("\(String(format: "%.2f", Double(diningVM.diningBalance.diningDollars) ?? 0.0))", systemImage: "dollarsign.circle.fill")
                .labelStyle(BalanceLabelStyle())
        }
    }
}

struct BalanceLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
                .font(.system(size: 17, weight: .bold, design: .rounded))
            configuration.icon
                .frame(width: 20, height: 20)
        }
    }
}

struct DiningViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            HStack {
                DiningViewHeaderDate()
                    .padding()

                Spacer()
            }
            Spacer()
        }
    }
}
