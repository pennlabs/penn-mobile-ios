//
//  DiningAnalyticsHomeWidget.swift
//  PennMobile
//
//  Created by Anthony Li on 11/5/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import SwiftUI

extension ConfigureDiningAnalyticsHomeWidgetIntent: ConfigurationRepresenting {
    struct Configuration {
        let background: WidgetBackgroundType
        let meterType: DiningAnalyticsMeterType
        let auxiliaryStatistic: DiningAnalyticsAuxiliaryStatistic
    }

    var configuration: Configuration {
        return Configuration(background: background, meterType: meterType, auxiliaryStatistic: auxiliaryStatistic)
    }
}

extension DiningAnalyticsMeterType {
    func getMetric<Balance: AdditiveArithmetic & Comparable>(in balance: BalanceDetails<Balance>) -> Balance {
        switch self {
        case .unknown, .remaining:
            return balance.remaining
        case .used:
            return balance.used
        }
    }
    
    var subtitle: LocalizedStringKey {
        switch self {
        case .unknown, .remaining:
            return "left"
        case .used:
            return "used"
        }
    }
}

extension DiningAnalyticsAuxiliaryStatistic {
    func getMetric<Balance: AdditiveArithmetic & Comparable>(in balance: BalanceDetails<Balance>) -> Balance {
        switch self {
        case .unknown, .projectedEnd:
            return balance.projectedEnd
        case .remaining:
            return balance.remaining
        case .used:
            return balance.used
        case .total:
            return balance.total
        }
    }
    
    var shortTitle: LocalizedStringKey {
        switch self {
        case .unknown, .projectedEnd:
            return "extra"
        case .remaining:
            return "left"
        case .used:
            return "used"
        case .total:
            return "total"
        }
    }
}

struct DiningAnalyticsHomeWidgetView: View {
    var entry: DiningAnalyticsEntry<ConfigureDiningAnalyticsHomeWidgetIntent.Configuration>
    
    let iconHeight: CGFloat = 20
    let meterSize: CGFloat = 70
    
    var swipeColor: Color {
        if entry.configuration.background.prefersGrayscaleContent {
            return Color.primary
        } else {
            return Color.green
        }
    }
    
    var dollarColor: Color {
        if entry.configuration.background.prefersGrayscaleContent {
            return Color.primary
        } else {
            return Color.baseBlue
        }
    }
    
    var body: some View {
        Group {
            if let swipes = entry.swipes, let dollars = entry.dollars {
                HStack(spacing: 5) {
                    VStack {
                        Label {
                            Text("Swipes")
                        } icon: {
                            Image(systemName: "creditcard")
                        }
                        .labelStyle(IconOnlyLabelStyle())
                        .foregroundColor(swipeColor)
                        .frame(height: iconHeight)
                        .unredacted()
                        MeterView(current: Double(swipes.used), maximum: Double(swipes.total), style: swipeColor) {
                            VStack {
                                Text("\(entry.configuration.meterType.getMetric(in: swipes))").fontWeight(.bold).multilineTextAlignment(.center).privacySensitive()
                                Text(entry.configuration.meterType.subtitle).font(.caption2)
                            }
                        }
                        .frame(width: meterSize, height: meterSize)
                        VStack {
                            Text("\(entry.configuration.auxiliaryStatistic.getMetric(in: swipes))").lineLimit(1).font(.subheadline)
                            Text(entry.configuration.auxiliaryStatistic.shortTitle).font(.caption2).foregroundColor(.secondary)
                        }
                    }
                    VStack {
                        Label {
                            Text("Dining Dollars")
                        } icon: {
                            Image(systemName: "dollarsign")
                        }
                        .labelStyle(IconOnlyLabelStyle())
                        .foregroundColor(dollarColor)
                        .frame(height: iconHeight)
                        .unredacted()
                        MeterView(current: Double(dollars.used), maximum: Double(dollars.total), style: dollarColor) {
                            VStack {
                                let metric = entry.configuration.meterType.getMetric(in: dollars)
                                if metric < 1000 {
                                    (
                                        Text("\(Int(metric))").fontWeight(.bold) +
                                        Text(".\(String(format: "%02d", Int(metric * 100) % 100))").fontWeight(.medium).font(.caption2)
                                    ).lineLimit(1).privacySensitive()
                                } else {
                                    Text("\(Int(metric))").fontWeight(.bold).multilineTextAlignment(.center).privacySensitive()
                                }
                                Text(entry.configuration.meterType.subtitle).font(.caption2)
                            }
                        }
                        .frame(width: meterSize, height: meterSize)
                        VStack {
                            Text("\(entry.configuration.auxiliaryStatistic.getMetric(in: dollars), format: .currency(code: "USD"))").lineLimit(1).font(.subheadline)
                            Text(entry.configuration.auxiliaryStatistic.shortTitle).font(.caption2).foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                (Text("Go to ") + Text("Dining › Analytics").fontWeight(.bold) + Text(" to use this widget.")).multilineTextAlignment(.center).padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(entry.configuration.background)
    }
}

struct DiningAnalyticsHomeWidget: Widget {
    var body: some WidgetConfiguration {
        let provider = IntentDiningAnalyticsProvider<ConfigureDiningAnalyticsHomeWidgetIntent>(placeholderConfiguration: .init(background: .unknown, meterType: .unknown, auxiliaryStatistic: .unknown))
        return IntentConfiguration(kind: WidgetKind.diningAnalyticsHome,
                            intent: ConfigureDiningAnalyticsHomeWidgetIntent.self,
                            provider: provider) { entry in
            DiningAnalyticsHomeWidgetView(entry: entry)
        }
        .configurationDisplayName("Dining Analytics")
        .description("Keep tabs on your dollars and swipes.")
        .supportedFamilies([.systemSmall])
    }
}

struct DiningAnalyticsHomeWidget_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            let configuration = ConfigureDiningAnalyticsHomeWidgetIntent.Configuration(background: .whiteGray, meterType: .remaining, auxiliaryStatistic: .projectedEnd)
            DiningAnalyticsHomeWidgetView(entry: DiningAnalyticsEntry(date: Date(), configuration: configuration, swipes: BalanceDetails(remaining: 20, total: 100, projectedEnd: 5), dollars: BalanceDetails(remaining: 206.29, total: 250, projectedEnd: 10)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Average user")
            DiningAnalyticsHomeWidgetView(entry: DiningAnalyticsEntry(date: Date(), configuration: configuration, swipes: BalanceDetails(remaining: 0, total: 100, projectedEnd: 0), dollars: BalanceDetails(remaining: 0, total: 250, projectedEnd: 0)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Overspender")
            DiningAnalyticsHomeWidgetView(entry: DiningAnalyticsEntry(date: Date(), configuration: configuration, swipes: BalanceDetails(remaining: 1000, total: 100, projectedEnd: 10000), dollars: BalanceDetails(remaining: 1000, total: 250, projectedEnd: 1000)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Rich kid")
            DiningAnalyticsHomeWidgetView(entry: DiningAnalyticsEntry(date: Date(), configuration: configuration, swipes: nil, dollars: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("No data")
        }
    }
}
