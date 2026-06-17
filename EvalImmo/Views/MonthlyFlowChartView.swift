//
//  MonthlyFlowChartView.swift
//  EvalImmo
//

import SwiftUI

struct MonthlyFlowChartView: View {
    let project: InvestmentProjectSnapshot

    private var items: [MonthlyFlowItem] {
        [
            MonthlyFlowItem(title: "Loyer", value: project.economicIndicators.annualRentalPrice / 12, kind: .income),
            MonthlyFlowItem(title: "Charges", value: -monthlyOperatingExpenses, kind: .expense),
            MonthlyFlowItem(title: "Credit", value: -project.economicIndicators.monthlyPayment, kind: .expense),
            MonthlyFlowItem(title: "Impots", value: -(project.indicators.taxes / 12), kind: .tax)
        ]
    }

    private var monthlyOperatingExpenses: Double {
        (project.economicIndicators.annualCondominiumFees / 12)
            + (project.economicIndicators.annualPropertyTax / 12)
            + (project.economicIndicators.annualOwnerInsurance / 12)
    }

    private var cashflow: Double {
        project.result.monthlyCashflow
    }

    private var maximumMagnitude: Double {
        max(items.map { abs($0.value) }.max() ?? 0, abs(cashflow), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Flux mensuels")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 11) {
                ForEach(items) { item in
                    MonthlyFlowBarRow(item: item, maximumMagnitude: maximumMagnitude)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
    }

}

private struct MonthlyFlowBarRow: View {
    let item: MonthlyFlowItem
    let maximumMagnitude: Double

    var body: some View {
        HStack(spacing: 10) {
            Text(item.title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 84, alignment: .leading)
                .lineLimit(1)

            GeometryReader { proxy in
                let width = max(proxy.size.width, 1)
                let center = width / 2
                let halfWidth = width / 2
                let ratio = min(abs(item.value) / max(maximumMagnitude, 1), 1)
                let barWidth = max(halfWidth * ratio, 3)
                let offset = item.value >= 0 ? center : center - barWidth

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(MonthlyFlowPalette.track)
                        .frame(height: 10)

                    Rectangle()
                        .fill(MonthlyFlowPalette.zero)
                        .frame(width: 1, height: 20)
                        .offset(x: center)

                    Capsule()
                        .fill(item.color)
                        .frame(width: barWidth, height: 10)
                        .offset(x: offset)
                }
            }
            .frame(height: 20)

            Text(valueString)
                .font(.caption.monospacedDigit())
                .foregroundStyle(item.value < 0 ? MonthlyFlowPalette.loss : MonthlyFlowPalette.gain)
                .frame(width: 82, alignment: .trailing)
        }
    }

    private var valueString: String {
        let formattedValue = String(format: "%.0f", item.value)
        return "\(item.value >= 0 ? "+" : "")\(formattedValue) EUR"
    }
}

private struct MonthlyFlowItem: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    let kind: MonthlyFlowKind

    var color: Color {
        switch kind {
        case .income:
            return MonthlyFlowPalette.gain
        case .expense:
            return MonthlyFlowPalette.loss
        case .tax:
            return MonthlyFlowPalette.tax
        }
    }
}

private enum MonthlyFlowKind {
    case income
    case expense
    case tax
}

private enum MonthlyFlowPalette {
    static let gain = Color(red: 0.08, green: 0.58, blue: 0.32)
    static let loss = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let tax = Color(red: 0.61, green: 0.34, blue: 0.84)
    static let track = Color.black.opacity(0.08)
    static let zero = Color.black.opacity(0.3)
}
