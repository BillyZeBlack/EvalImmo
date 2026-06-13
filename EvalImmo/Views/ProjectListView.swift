//
//  ProjectListView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectListView: View {
    @ObservedObject var store: ProjectStore
    let onAddProject: () -> Void

    var body: some View {
        List {
            if store.projects.isEmpty {
                EmptyProjectListView(onAddProject: onAddProject)
            } else {
                ProjectPortfolioSummaryView(projects: store.projects)

                ForEach(store.projects) { project in
                    NavigationLink(value: AppState.Route.projectDetail(project.id)) {
                        ProjectRowView(project: project)
                    }
                }
            }
        }
        .navigationTitle("Projets")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAddProject) {
                    Label("Nouveau projet", systemImage: "plus")
                }
            }
        }
    }
}

private struct EmptyProjectListView: View {
    let onAddProject: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Aucun projet", systemImage: "building.2")
        } actions: {
            Button("Nouveau projet", action: onAddProject)
                .buttonStyle(.borderedProminent)
        }
    }
}

private struct ProjectPortfolioSummaryView: View {
    let projects: [InvestmentProjectSnapshot]

    var body: some View {
        Section("Synthese") {
            summaryRow("Projets sauvegardes", value: "\(projects.count)")
            summaryRow("Investissement total", value: formatted(totalInvestment, fractionDigits: 0, suffix: "EUR"))
            summaryRow("Cashflow mensuel total", value: formatted(monthlyCashflow, fractionDigits: 2, suffix: "EUR"))
        }
    }

    private var totalInvestment: Double {
        projects.reduce(0) { $0 + $1.costs.total }
    }

    private var monthlyCashflow: Double {
        projects.reduce(0) { $0 + $1.result.monthlyCashflow }
    }

    private func summaryRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func formatted(_ value: Double, fractionDigits: Int, suffix: String) -> String {
        let format = "%.\(fractionDigits)f %@"
        return String(format: format, value, suffix)
    }
}

private struct ProjectRowView: View {
    let project: InvestmentProjectSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(projectTitle)
                .font(.headline)

            Text("\(project.draft.rentalType.title) - \(project.draft.taxRegime.title)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("Prix total")
                Spacer()
                Text("\(project.costs.total, specifier: "%.0f") EUR")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Text("Rendement net-net")
                Spacer()
                Text("\(project.result.netNetYield, specifier: "%.2f") %")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Text("Cashflow mensuel")
                Spacer()
                Text("\(project.result.monthlyCashflow, specifier: "%.2f") EUR")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var projectTitle: String {
        "Projet du \(project.createdAt.formatted(date: .abbreviated, time: .omitted))"
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectListView(store: ProjectStore(), onAddProject: {})
        }
    }
}
