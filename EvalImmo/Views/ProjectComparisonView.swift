//
//  ProjectComparisonView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectComparisonView: View {
    let projects: [InvestmentProjectSnapshot]

    var body: some View {
        List {
            if projects.count < ProjectComparisonLimits.minimumSelectionCount {
                ContentUnavailableView(
                    "Comparaison indisponible",
                    systemImage: "chart.bar.xaxis",
                    description: Text("Sélectionnez au moins deux projets.")
                )
            } else {
                Section {
                    ComparisonYieldChartView(projects: projects)
                } header: {
                    Label("Rendements", systemImage: "chart.bar.xaxis")
                }

                Section {
                    ComparisonCashflowView(projects: projects)
                } header: {
                    Label("Cashflow mensuel", systemImage: "arrow.left.arrow.right")
                }
            }
        }
        .navigationTitle("Comparaison")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(ComparisonPalette.background)
        .toolbarBackground(ComparisonPalette.background, for: .navigationBar)
    }
}

private struct ComparisonYieldChartView: View {
    let projects: [InvestmentProjectSnapshot]
    private let metrics = YieldComparisonMetric.allCases

    private var maximumYield: Double {
        max(
            projects.flatMap { project in
                metrics.map { $0.value(for: project) }
            }.max() ?? 0,
            10
        )
    }

    private var yAxisTickValues: [Double] {
        (0...4).reversed().map { maximumYield * Double($0) / 4 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ComparisonLegendView(projects: projects)

            GeometryReader { proxy in
                let axisWidth: CGFloat = 44
                let plotHeight = max(proxy.size.height - 34, 1)
                let plotWidth = max(proxy.size.width - axisWidth, 1)
                let groupWidth = max(plotWidth / CGFloat(metrics.count), 1)
                let barWidth = min(max(groupWidth / CGFloat(projects.count + 2), 10), 20)

                ZStack(alignment: .topLeading) {
                    ForEach(Array(yAxisTickValues.enumerated()), id: \.offset) { _, value in
                        let ratio = CGFloat(value / maximumYield)
                        let y = plotHeight * (1 - ratio)

                        Text("\(value, specifier: "%.0f") %")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: axisWidth - 8, alignment: .trailing)
                            .position(x: (axisWidth - 8) / 2, y: y)

                        Rectangle()
                            .fill(ComparisonPalette.grid)
                            .frame(width: plotWidth, height: 1)
                            .position(x: axisWidth + plotWidth / 2, y: y)
                    }

                    Rectangle()
                        .fill(ComparisonPalette.grid)
                        .frame(width: 1, height: plotHeight)
                        .position(x: axisWidth, y: plotHeight / 2)

                    Rectangle()
                        .fill(ComparisonPalette.grid)
                        .frame(width: plotWidth, height: 1)
                        .position(x: axisWidth + plotWidth / 2, y: plotHeight)

                    ForEach(metrics.indices, id: \.self) { metricIndex in
                        let metric = metrics[metricIndex]
                        let centerX = axisWidth + groupWidth * (CGFloat(metricIndex) + 0.5)

                        Text(metric.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .position(x: centerX, y: plotHeight + 20)

                        ForEach(projects.indices, id: \.self) { projectIndex in
                            let project = projects[projectIndex]
                            let value = metric.value(for: project)
                            let ratio = CGFloat(min(max(value / maximumYield, 0), 1))
                            let height = max(plotHeight * ratio, 3)
                            let spread = barWidth * 0.58
                            let offset = (CGFloat(projectIndex) - CGFloat(projects.count - 1) / 2) * spread

                            RoundedRectangle(cornerRadius: 5)
                                .fill(ComparisonPalette.seriesColor(at: projectIndex).opacity(0.88))
                                .frame(width: barWidth, height: height)
                                .position(
                                    x: centerX + offset,
                                    y: plotHeight - height / 2
                                )
                                .accessibilityLabel("\(project.comparisonTitle), \(metric.title)")
                                .accessibilityValue("\(value, specifier: "%.2f") pour cent")
                        }
                    }
                }
            }
            .frame(height: 230)
        }
        .padding(.vertical, 8)
    }
}

private struct ComparisonCashflowView: View {
    let projects: [InvestmentProjectSnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(projects.indices, id: \.self) { index in
                let project = projects[index]

                HStack(spacing: 10) {
                    Circle()
                        .fill(ComparisonPalette.seriesColor(at: index))
                        .frame(width: 9, height: 9)

                    Text(project.comparisonTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ComparisonPalette.ink)
                        .lineLimit(1)

                    Spacer()

                    Text("\(project.result.monthlyCashflow >= 0 ? "+" : "")\(project.result.monthlyCashflow, specifier: "%.2f") EUR/mois")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(project.result.monthlyCashflow < 0 ? ComparisonPalette.loss : ComparisonPalette.gain)
                        .lineLimit(1)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct ComparisonLegendView: View {
    let projects: [InvestmentProjectSnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(projects.indices, id: \.self) { index in
                HStack(spacing: 8) {
                    Circle()
                        .fill(ComparisonPalette.seriesColor(at: index))
                        .frame(width: 9, height: 9)

                    Text(projects[index].comparisonTitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ComparisonPalette.ink)
                        .lineLimit(1)
                }
            }
        }
    }
}

private enum YieldComparisonMetric: CaseIterable {
    case gross
    case net
    case netNet

    var title: String {
        switch self {
        case .gross:
            return "Brut"
        case .net:
            return "Net"
        case .netNet:
            return "Net-net"
        }
    }

    func value(for project: InvestmentProjectSnapshot) -> Double {
        switch self {
        case .gross:
            return project.economicResult.grossYield
        case .net:
            return project.economicResult.netYieldBeforeTax
        case .netNet:
            return project.result.netNetYield
        }
    }
}

private enum ComparisonPalette {
    static let background = Color(red: 0.93, green: 0.97, blue: 0.96)
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.14)
    static let gain = Color(red: 0.00, green: 0.48, blue: 0.38)
    static let loss = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let grid = Color.black.opacity(0.08)
    static let track = Color.black.opacity(0.07)

    private static let series: [Color] = [
        Color(red: 0.02, green: 0.44, blue: 0.37),
        Color(red: 0.91, green: 0.69, blue: 0.32),
        Color(red: 0.33, green: 0.44, blue: 0.70),
        Color(red: 0.67, green: 0.30, blue: 0.46)
    ]

    static func seriesColor(at index: Int) -> Color {
        series[index % series.count]
    }
}

private extension InvestmentProjectSnapshot {
    var comparisonTitle: String {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(createdAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return name
    }
}

struct ProjectComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectComparisonView(
                projects: [
                    InvestmentProjectSnapshot(
                        draft: previewDraft(name: "T2 Dijon"),
                        costs: InvestmentCosts(price: 65_000, notaryFees: 5_000, agencyCosts: 1_000, works: 7_000),
                        economicIndicators: InvestmentEconomicIndicators(
                            annualRentalPrice: 6_000,
                            annualCondominiumFees: 900,
                            monthlyPayment: 420,
                            annualPropertyTax: 480,
                            annualOwnerInsurance: 120
                        ),
                        economicResult: InvestmentEconomicResult(grossYield: 8.45, netYieldBeforeTax: 6.9, monthlyCashflowBeforeTax: 75),
                        indicators: InvestmentIndicators(
                            annualRentalPrice: 6_000,
                            annualCondominiumFees: 900,
                            taxes: 850,
                            monthlyPayment: 420,
                            annualPropertyTax: 480,
                            annualOwnerInsurance: 120
                        ),
                        result: InvestmentYieldResult(grossYield: 8.45, netYield: 6.9, netNetYield: 6.29, monthlyCashflow: 32.02)
                    ),
                    InvestmentProjectSnapshot(
                        draft: previewDraft(name: "Scenario travaux"),
                        costs: InvestmentCosts(price: 65_000, notaryFees: 5_000, agencyCosts: 1_000, works: 14_000),
                        economicIndicators: InvestmentEconomicIndicators(
                            annualRentalPrice: 6_600,
                            annualCondominiumFees: 900,
                            monthlyPayment: 470,
                            annualPropertyTax: 480,
                            annualOwnerInsurance: 120
                        ),
                        economicResult: InvestmentEconomicResult(grossYield: 7.76, netYieldBeforeTax: 6.48, monthlyCashflowBeforeTax: 70),
                        indicators: InvestmentIndicators(
                            annualRentalPrice: 6_600,
                            annualCondominiumFees: 900,
                            taxes: 920,
                            monthlyPayment: 470,
                            annualPropertyTax: 480,
                            annualOwnerInsurance: 120
                        ),
                        result: InvestmentYieldResult(grossYield: 7.76, netYield: 6.48, netNetYield: 5.4, monthlyCashflow: -18.40)
                    )
                ]
            )
        }
    }
}

private func previewDraft(name: String) -> InvestmentProjectDraft {
    var draft = InvestmentProjectDraft()
    draft.name = name
    return draft
}
