//
//  InvestmentPerformanceSummaryView.swift
//  EvalImmo
//

import SwiftUI

struct InvestmentPerformanceSummaryView: View {
    let project: InvestmentProjectSnapshot

    private var yieldItems: [YieldChartItem] {
        [
            YieldChartItem(title: "Brut", value: project.economicResult.grossYield),
            YieldChartItem(title: "Net", value: project.economicResult.netYieldBeforeTax),
            YieldChartItem(title: "Net-net", value: project.result.netNetYield)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            YieldBarsView(items: yieldItems)

            Divider()

            CashflowValueView(value: project.result.monthlyCashflow)
        }
        .padding(.vertical, 8)
    }
}

private struct YieldBarsView: View {
    let items: [YieldChartItem]

    private var maximumValue: Double {
        max(items.map(\.value).max() ?? 0, 10)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                HStack(spacing: 12) {
                    Text(item.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 64, alignment: .leading)

                    GeometryReader { proxy in
                        let width = max(proxy.size.width, 1)
                        let ratio = min(max(item.value / maximumValue, 0), 1)

                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(PerformancePalette.track)

                            Capsule()
                                .fill(PerformancePalette.brand)
                                .frame(width: max(width * ratio, 4))
                        }
                    }
                    .frame(height: 10)

                    Text("\(item.value, specifier: "%.2f") %")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(PerformancePalette.ink)
                        .frame(width: 72, alignment: .trailing)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct CashflowValueView: View {
    let value: Double

    private var valueColor: Color {
        value < 0 ? PerformancePalette.loss : PerformancePalette.gain
    }

    var body: some View {
        HStack {
            Text("Cashflow")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text("\(value >= 0 ? "+" : "")\(value, specifier: "%.2f") EUR/mois")
                .font(.headline.monospacedDigit())
                .foregroundStyle(valueColor)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct YieldChartItem: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
}

private enum PerformancePalette {
    static let brand = Color(red: 0.04, green: 0.45, blue: 0.38)
    static let gain = Color(red: 0.08, green: 0.58, blue: 0.32)
    static let loss = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let ink = Color(red: 0.08, green: 0.11, blue: 0.16)
    static let track = Color.black.opacity(0.08)
}
