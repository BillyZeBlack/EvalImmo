//
//  ProjectListView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectListView: View {
    @ObservedObject var store: ProjectStore
    @State private var projectPendingDeletion: InvestmentProjectSnapshot?
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
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            projectPendingDeletion = project
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                    .confirmationDialog(
                        "Supprimer ce projet ?",
                        isPresented: deletionConfirmationBinding(for: project),
                        titleVisibility: .visible
                    ) {
                        Button("Supprimer", role: .destructive) {
                            deletePendingProject()
                        }

                        Button("Annuler", role: .cancel) {
                            projectPendingDeletion = nil
                        }
                    } message: {
                        Text("Cette action supprimera definitivement \(projectTitle(for: project)).")
                    }
                }
            }
        }
        .navigationTitle("Projets")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .tint(.teal)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Nouveau projet", systemImage: "plus", action: onAddProject)
            }
        }
    }

    private func deletionConfirmationBinding(for project: InvestmentProjectSnapshot) -> Binding<Bool> {
        Binding(
            get: { projectPendingDeletion?.id == project.id },
            set: { isPresented in
                if !isPresented {
                    projectPendingDeletion = nil
                }
            }
        )
    }

    private func deletePendingProject() {
        guard let project = projectPendingDeletion else { return }

        store.deleteProject(with: project.id)
        projectPendingDeletion = nil
    }

    private func projectTitle(for project: InvestmentProjectSnapshot) -> String {
        let name = project.draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "ce projet"
        }

        return "\"\(name)\""
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
        LabeledContent(title) {
            Text(value)
                .font(.body.monospacedDigit())
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(projectTitle)
                        .font(.headline)

                    Text(project.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(formattedCashflow)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(project.result.monthlyCashflow < 0 ? .red : .green)
            }

            LabeledContent("Montant bien + travaux") {
                Text("\(projectAmount, specifier: "%.0f") EUR")
                    .font(.subheadline.monospacedDigit())
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private var projectAmount: Double {
        project.costs.price + project.costs.works
    }

    private var formattedCashflow: String {
        String(format: "%.2f EUR", project.result.monthlyCashflow)
    }

    private var projectTitle: String {
        let name = project.draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(project.createdAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return name
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectListView(store: ProjectStore(), onAddProject: {})
        }
    }
}
