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
        
        var swipeColor: Color {
            if background.prefersGrayscaleContent {
                return Color.primary
            } else {
                return Color.green
            }
        }
        
        var dollarColor: Color {
            if background.prefersGrayscaleContent {
                return Color.primary
            } else {
                return Color.baseBlue
            }
        }
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
    
    var shortTitle: LocalizedStringKey {
        switch self {
        case .unknown, .remaining:
            return "left"
        case .used:
            return "used"
        }
    }
    
    var longTitle: LocalizedStringKey {
        switch self {
        case .unknown, .remaining:
            return "Remaining"
        case .used:
            return "Used"
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
    
    var label: LocalizedStringKey {
        switch self {
        case .unknown, .projectedEnd:
            return "End of Term Projections"
        case .remaining:
            return "Remaining"
        case .used:
            return "Used"
        case .total:
            return "Total"
        }
    }
}

private struct DiningAnalyticsSmall: View {
    var swipes: BalanceDetails<Int>
    var dollars: BalanceDetails<Double>
    var configuration: ConfigureDiningAnalyticsHomeWidgetIntent.Configuration
    
    let iconHeight: CGFloat = 20
    let meterSize: CGFloat = 70
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                VStack {
                    Label {
                        Text("Swipes")
                    } icon: {
                        Image(systemName: "creditcard")
                    }
                    .labelStyle(IconOnlyLabelStyle())
                    .foregroundColor(configuration.swipeColor)
                    .frame(height: iconHeight)
                    .unredacted()
                    MeterView(current: Double(swipes.used), maximum: Double(swipes.total), style: configuration.swipeColor) {
                        VStack {
                            Text("\(configuration.meterType.getMetric(in: swipes))").fontWeight(.bold).multilineTextAlignment(.center).privacySensitive()
                            Text(configuration.meterType.shortTitle).font(.caption2)
                        }
                    }
                    .frame(width: meterSize, height: meterSize)
                }
                VStack {
                    Label {
                        Text("Dining Dollars")
                    } icon: {
                        Image(systemName: "dollarsign")
                    }
                    .labelStyle(IconOnlyLabelStyle())
                    .foregroundColor(configuration.dollarColor)
                    .frame(height: iconHeight)
                    .unredacted()
                    MeterView(current: Double(dollars.used), maximum: Double(dollars.total), style: configuration.dollarColor) {
                        VStack {
                            let metric = configuration.meterType.getMetric(in: dollars)
                            if metric < 1000 {
                                (
                                    Text("\(Int(metric))").fontWeight(.bold) +
                                    Text(".\(String(format: "%02d", Int(metric * 100) % 100))").fontWeight(.medium).font(.caption2)
                                ).lineLimit(1).privacySensitive()
                            } else {
                                Text("\(Int(metric))").fontWeight(.bold).multilineTextAlignment(.center).privacySensitive()
                            }
                            Text(configuration.meterType.shortTitle).font(.caption2)
                        }
                    }
                    .frame(width: meterSize, height: meterSize)
                }
            }
            .padding(.bottom, 4)
            Text(configuration.auxiliaryStatistic.label).font(.caption2).foregroundColor(.secondary).unredacted()
            HStack(spacing: 5) {
                let swipes = configuration.auxiliaryStatistic.getMetric(in: swipes)
                let dollars = configuration.auxiliaryStatistic.getMetric(in: dollars)
                Text("\(swipes) \(swipes == 1 ? "swipe" : "swipes"), \(dollars, format: .currency(code: "USD"))").fontWeight(.medium).font(.caption).privacySensitive()
            }.multilineTextAlignment(.center)
        }
    }
}

private struct DiningAnalyticsSummary: View {
    var swipes: BalanceDetails<Int>
    var dollars: BalanceDetails<Double>
    var configuration: ConfigureDiningAnalyticsHomeWidgetIntent.Configuration
    
    let meterSize: CGFloat = 100
    let meterLineWidth: CGFloat = 6
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading) {
                Text(configuration.meterType.longTitle).fontWeight(.medium).foregroundColor(.secondary).font(.caption)
                HStack {
                    MeterView(current: Double(swipes.used), maximum: Double(swipes.total), style: configuration.swipeColor, lineWidth: meterLineWidth) {
                        VStack {
                            Text("\(configuration.meterType.getMetric(in: swipes))").fontWeight(.bold).font(.title2).multilineTextAlignment(.center).privacySensitive()
                            Text("Swipes").fontWeight(.medium).font(.caption)
                        }
                    }
                    MeterView(current: Double(dollars.used), maximum: Double(dollars.total), style: configuration.dollarColor, lineWidth: meterLineWidth) {
                        VStack {
                            let metric = configuration.meterType.getMetric(in: dollars)
                            if metric < 1000 {
                                (
                                    Text("\(Int(metric))").fontWeight(.bold).font(.title2) +
                                    Text(".\(String(format: "%02d", Int(metric * 100) % 100))").fontWeight(.medium)
                                ).lineLimit(1).privacySensitive()
                            } else {
                                Text("\(Int(metric))").fontWeight(.bold).font(.title2).multilineTextAlignment(.center).privacySensitive()
                            }
                            Text("Dollars").fontWeight(.medium).font(.caption)
                        }
                    }
                }.frame(height: meterSize)
            }.layoutPriority(2)
            Spacer(minLength: 16)
            VStack(alignment: .leading, spacing: 10) {
                Text(configuration.auxiliaryStatistic.label).fontWeight(.medium).foregroundColor(.secondary).font(.caption)
                VStack(alignment: .leading) {
                    Text("Swipes").fontWeight(.medium).font(.caption)
                    Text("\(configuration.auxiliaryStatistic.getMetric(in: swipes))").fontWeight(.bold)
                }
                
                VStack(alignment: .leading) {
                    Text("Dollars").fontWeight(.medium).font(.caption)
                    Text("\(configuration.auxiliaryStatistic.getMetric(in: dollars), format: .currency(code: "USD"))").fontWeight(.bold)
                }
            }
        }
    }
}

private struct DiningAnalyticsMedium: View {
    var swipes: BalanceDetails<Int>
    var dollars: BalanceDetails<Double>
    var configuration: ConfigureDiningAnalyticsHomeWidgetIntent.Configuration
    
    var body: some View {
        DiningAnalyticsSummary(swipes: swipes, dollars: dollars, configuration: configuration)
            .padding(.horizontal, 20)
    }
}

private struct DiningAnalyticsLarge: View {
    var swipes: BalanceDetails<Int>
    var dollars: BalanceDetails<Double>
    var configuration: ConfigureDiningAnalyticsHomeWidgetIntent.Configuration
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Graph").frame(maxWidth: .infinity, maxHeight: .infinity).background(.gray)
            DiningAnalyticsSummary(swipes: swipes, dollars: dollars, configuration: configuration)
        }
        .padding(16)
    }
}


struct DiningAnalyticsHomeWidgetView: View {
    var entry: DiningAnalyticsEntry<ConfigureDiningAnalyticsHomeWidgetIntent.Configuration>
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        Group {
            if let swipes = entry.swipes, let dollars = entry.dollars {
                switch widgetFamily {
                case .systemSmall:
                    DiningAnalyticsSmall(swipes: swipes, dollars: dollars, configuration: entry.configuration)
                case .systemMedium:
                    DiningAnalyticsMedium(swipes: swipes, dollars: dollars, configuration: entry.configuration)
                default:
                    Text("Unsupported")
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DiningAnalyticsHomeWidget_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            let configuration = ConfigureDiningAnalyticsHomeWidgetIntent.Configuration(background: .whiteGray, meterType: .remaining, auxiliaryStatistic: .projectedEnd)
            DiningAnalyticsHomeWidgetView(entry: DiningAnalyticsEntry(date: Date(), configuration: configuration, swipes: BalanceDetails(remaining: 20, total: 100, projectedEnd: 5), dollars: BalanceDetails(remaining: 206.29, total: 250, projectedEnd: 10)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Average user")
            DiningAnalyticsHomeWidgetView(entry: DiningAnalyticsEntry(date: Date(), configuration: configuration, swipes: BalanceDetails(remaining: 0, total: 100, projectedEnd: 1), dollars: BalanceDetails(remaining: 0, total: 250, projectedEnd: 0)))
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
