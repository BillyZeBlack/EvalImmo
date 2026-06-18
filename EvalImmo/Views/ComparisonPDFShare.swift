//
//  ComparisonPDFShare.swift
//  EvalImmo
//

import SwiftUI

@MainActor
enum ComparisonPDFExporter {
    static func export(projects: [InvestmentProjectSnapshot]) throws -> URL {
        let pageSize = CGSize(width: 595, height: 842)
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("valoria-comparaison.pdf")

        var mediaBox = CGRect(origin: .zero, size: pageSize)

        guard let consumer = CGDataConsumer(url: fileURL as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ProjectPDFExportError.renderingFailed
        }

        let document = ComparisonPDFDocumentView(projects: projects)
            .frame(width: pageSize.width, height: pageSize.height)
        let renderer = ImageRenderer(content: document)
        renderer.proposedSize = ProposedViewSize(pageSize)

        pdfContext.beginPDFPage(nil)
        renderer.render { _, renderInContext in
            renderInContext(pdfContext)
        }
        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return fileURL
    }
}

private struct ComparisonPDFDocumentView: View {
    let projects: [InvestmentProjectSnapshot]

    private let metrics = ComparisonPDFMetric.allCases

    private var maximumYield: Double {
        max(
            projects.flatMap { project in
                metrics.map { $0.value(for: project) }
            }.max() ?? 0,
            10
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            projectSummary
            yieldChart
            cashflowSummary
            Spacer(minLength: 10)
            disclaimer
            footer
        }
        .padding(28)
        .background(ComparisonPDFPalette.background)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Valoria")
                    .font(.title)
                    .bold()
                    .foregroundStyle(ComparisonPDFPalette.brand)

                Text("Comparaison de projets")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(ComparisonPDFPalette.ink)
            }

            Spacer()

            Text(Date().formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .trailing)
        }
    }

    private var projectSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Projets comparés")
                .font(.headline)
                .bold()
                .foregroundStyle(ComparisonPDFPalette.brand)

            VStack(spacing: 8) {
                ForEach(projects.indices, id: \.self) { index in
                    let project = projects[index]

                    HStack(spacing: 10) {
                        Circle()
                            .fill(ComparisonPDFPalette.seriesColor(at: index))
                            .frame(width: 9, height: 9)

                        Text(project.comparisonPDFTitle)
                            .font(.subheadline)
                            .foregroundStyle(ComparisonPDFPalette.ink)
                            .lineLimit(1)

                        Spacer()

                        Text(pdfCurrency(project.costs.total))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .background(ComparisonPDFPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var yieldChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rendements")
                .font(.headline)
                .bold()
                .foregroundStyle(ComparisonPDFPalette.brand)

            GeometryReader { proxy in
                let axisWidth: CGFloat = 42
                let plotHeight = max(proxy.size.height - 32, 1)
                let plotWidth = max(proxy.size.width - axisWidth, 1)
                let groupWidth = max(plotWidth / CGFloat(metrics.count), 1)
                let barWidth = min(max(groupWidth / CGFloat(projects.count + 2), 10), 18)

                ZStack(alignment: .topLeading) {
                    ForEach(0...4, id: \.self) { tick in
                        let value = maximumYield * Double(4 - tick) / 4
                        let y = plotHeight * CGFloat(tick) / 4

                        Text("\(value, specifier: "%.0f") %")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: axisWidth - 8, alignment: .trailing)
                            .position(x: (axisWidth - 8) / 2, y: y)

                        Rectangle()
                            .fill(ComparisonPDFPalette.grid)
                            .frame(width: plotWidth, height: 1)
                            .position(x: axisWidth + plotWidth / 2, y: y)
                    }

                    ForEach(metrics.indices, id: \.self) { metricIndex in
                        let metric = metrics[metricIndex]
                        let centerX = axisWidth + groupWidth * (CGFloat(metricIndex) + 0.5)

                        Text(metric.title)
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.secondary)
                            .position(x: centerX, y: plotHeight + 20)

                        ForEach(projects.indices, id: \.self) { projectIndex in
                            let project = projects[projectIndex]
                            let value = metric.value(for: project)
                            let ratio = CGFloat(min(max(value / maximumYield, 0), 1))
                            let height = max(plotHeight * ratio, 3)
                            let spread = barWidth * 0.62
                            let offset = (CGFloat(projectIndex) - CGFloat(projects.count - 1) / 2) * spread

                            RoundedRectangle(cornerRadius: 4)
                                .fill(ComparisonPDFPalette.seriesColor(at: projectIndex))
                                .frame(width: barWidth, height: height)
                                .position(x: centerX + offset, y: plotHeight - height / 2)
                        }
                    }
                }
            }
            .frame(height: 240)
        }
        .padding(14)
        .background(ComparisonPDFPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var cashflowSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cashflow mensuel")
                .font(.headline)
                .bold()
                .foregroundStyle(ComparisonPDFPalette.brand)

            VStack(spacing: 8) {
                ForEach(projects.indices, id: \.self) { index in
                    let project = projects[index]

                    HStack(spacing: 10) {
                        Circle()
                            .fill(ComparisonPDFPalette.seriesColor(at: index))
                            .frame(width: 9, height: 9)

                        Text(project.comparisonPDFTitle)
                            .font(.subheadline)
                            .foregroundStyle(ComparisonPDFPalette.ink)
                            .lineLimit(1)

                        Spacer()

                        Text(pdfSignedCurrency(project.result.monthlyCashflow) + "/mois")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(project.result.monthlyCashflow < 0 ? ComparisonPDFPalette.loss : ComparisonPDFPalette.gain)
                    }
                }
            }
        }
        .padding(14)
        .background(ComparisonPDFPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var disclaimer: some View {
        Text("Les résultats présentés sont des estimations indicatives, calculées à partir des données saisies. Ils ne constituent pas un conseil financier, fiscal, juridique ou patrimonial.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .background(ComparisonPDFPalette.note)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var footer: some View {
        HStack {
            Text("Valoria")
            Spacer()
            Text("Comparaison")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    private func pdfCurrency(_ value: Double) -> String {
        String(format: "%.2f EUR", value)
    }

    private func pdfSignedCurrency(_ value: Double) -> String {
        "\(value >= 0 ? "+" : "")\(String(format: "%.2f EUR", value))"
    }
}

private enum ComparisonPDFMetric: CaseIterable {
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

private enum ComparisonPDFPalette {
    static let background = Color(red: 0.93, green: 0.97, blue: 0.96)
    static let card = Color.white
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.14)
    static let gain = Color(red: 0.00, green: 0.48, blue: 0.38)
    static let loss = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let grid = Color.black.opacity(0.08)
    static let note = Color.white.opacity(0.72)

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
    var comparisonPDFTitle: String {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(createdAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return name
    }
}
