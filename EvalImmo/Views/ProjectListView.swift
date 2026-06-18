//
//  ProjectListView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectListView: View {
    @ObservedObject var store: ProjectStore
    @State private var projectPendingDeletion: InvestmentProjectSnapshot?
    @State private var isComparingProjects = false
    @State private var selectedProjectIDs: Set<UUID> = []
    let access: FeatureAccess
    let onAddProject: () -> Void
    let onDuplicateProject: (InvestmentProjectSnapshot) -> Void
    let onCompareProjects: ([UUID]) -> Void
    let onRequestPremium: (PremiumFeature) -> Void

    init(
        store: ProjectStore,
        access: FeatureAccess = FeatureAccess(isPremium: true, projectCount: 0),
        onAddProject: @escaping () -> Void,
        onDuplicateProject: @escaping (InvestmentProjectSnapshot) -> Void = { _ in },
        onCompareProjects: @escaping ([UUID]) -> Void = { _ in },
        onRequestPremium: @escaping (PremiumFeature) -> Void = { _ in }
    ) {
        self.store = store
        self.access = access
        self.onAddProject = onAddProject
        self.onDuplicateProject = onDuplicateProject
        self.onCompareProjects = onCompareProjects
        self.onRequestPremium = onRequestPremium
    }

    var body: some View {
        List {
            if store.projects.isEmpty {
                EmptyProjectListView(onAddProject: onAddProject)
            } else {
                ProjectPortfolioSummaryView(projects: store.projects)

                ForEach(store.projects) { project in
                    projectListRow(for: project)
                }
            }
        }
        .navigationTitle(isComparingProjects ? "Comparer" : "Projets")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(ProjectListPalette.background)
        .tint(ProjectListPalette.brand)
        .toolbarBackground(ProjectListPalette.background, for: .navigationBar)
        .toolbar {
            if !isComparingProjects && store.projects.count >= ProjectComparisonLimits.minimumSelectionCount {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Comparer", systemImage: "chart.bar.xaxis") {
                        startComparisonSelectionIfAvailable()
                    }
                }
            }

            if !isComparingProjects {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Nouveau projet", systemImage: "plus", action: onAddProject)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isComparingProjects {
                comparisonActionBar
            }
        }
        .confirmationDialog(
            "Supprimer ce projet ?",
            isPresented: deletionConfirmationBinding,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                deletePendingProject()
            }

            Button("Annuler", role: .cancel) {
                projectPendingDeletion = nil
            }
        } message: {
            Text("Cette action supprimera définitivement \(projectTitleForPendingDeletion).")
        }
    }

    @ViewBuilder
    private func projectListRow(for project: InvestmentProjectSnapshot) -> some View {
        if isComparingProjects {
            Button {
                toggleProjectSelection(project)
            } label: {
                ProjectSelectableRowView(
                    project: project,
                    isSelected: selectedProjectIDs.contains(project.id),
                    isDisabled: isSelectionDisabled(for: project)
                )
            }
            .buttonStyle(.plain)
            .disabled(isSelectionDisabled(for: project))
        } else {
            NavigationLink(value: AppState.Route.projectDetail(project.id)) {
                ProjectRowView(project: project)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    projectPendingDeletion = project
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }

                Button {
                    duplicateProject(project)
                } label: {
                    Label("Dupliquer", systemImage: "doc.on.doc")
                }
                .tint(ProjectListPalette.brand)
            }
        }
    }

    private var comparisonActionBar: some View {
        HStack(spacing: 12) {
            Button("Annuler", action: cancelComparisonSelection)
                .frame(maxWidth: .infinity, minHeight: 44)
                .buttonStyle(.bordered)

            Button("Valider") {
                validateComparisonSelection()
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .buttonStyle(.borderedProminent)
            .disabled(!canValidateComparison)
        }
        .controlSize(.large)
        .buttonBorderShape(.roundedRectangle)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var canValidateComparison: Bool {
        selectedProjectIDs.count >= ProjectComparisonLimits.minimumSelectionCount
            && selectedProjectIDs.count <= ProjectComparisonLimits.maximumSelectionCount
    }

    private var deletionConfirmationBinding: Binding<Bool> {
        Binding(
            get: { projectPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    projectPendingDeletion = nil
                }
            }
        )
    }

    private var projectTitleForPendingDeletion: String {
        guard let project = projectPendingDeletion else {
            return "ce projet"
        }

        return projectTitle(for: project)
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

    private func startComparisonSelection() {
        selectedProjectIDs = []
        isComparingProjects = true
    }

    private func startComparisonSelectionIfAvailable() {
        if access.canCompareProjects {
            startComparisonSelection()
        } else {
            onRequestPremium(.comparison)
        }
    }

    private func cancelComparisonSelection() {
        selectedProjectIDs = []
        isComparingProjects = false
    }

    private func validateComparisonSelection() {
        guard canValidateComparison else { return }
        guard access.canCompareProjects else {
            onRequestPremium(.comparison)
            return
        }

        let selectedIDs = store.projects.compactMap { project in
            selectedProjectIDs.contains(project.id) ? project.id : nil
        }

        cancelComparisonSelection()
        onCompareProjects(selectedIDs)
    }

    private func isSelectionDisabled(for project: InvestmentProjectSnapshot) -> Bool {
        !selectedProjectIDs.contains(project.id)
            && selectedProjectIDs.count >= ProjectComparisonLimits.maximumSelectionCount
    }

    private func toggleProjectSelection(_ project: InvestmentProjectSnapshot) {
        if selectedProjectIDs.contains(project.id) {
            selectedProjectIDs.remove(project.id)
        } else if selectedProjectIDs.count < ProjectComparisonLimits.maximumSelectionCount {
            selectedProjectIDs.insert(project.id)
        }
    }

    private func duplicateProject(_ project: InvestmentProjectSnapshot) {
        if access.canDuplicateProject {
            onDuplicateProject(project)
        } else {
            onRequestPremium(.duplication)
        }
    }
}

private struct EmptyProjectListView: View {
    let onAddProject: () -> Void

    var body: some View {
        ContentUnavailableView {
            VStack {
                Image("valoria-launch-logo-concept")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("Vos projets s'afficheront ici")
                    .font(.title3)
                    .bold()
            }
        } actions: {
            Button("Nouveau projet", action: onAddProject)
                .buttonStyle(.borderedProminent)
                .tint(ProjectListPalette.brand)
        }
    }
}

private struct ProjectPortfolioSummaryView: View {
    let projects: [InvestmentProjectSnapshot]

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Portefeuille")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)

                        Text("\(projects.count) projet\(projects.count > 1 ? "s" : "") suivi\(projects.count > 1 ? "s" : "")")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    Spacer()

                    Image(systemName: "building.columns")
                        .font(.title2)
                        .foregroundStyle(ProjectListPalette.gold)
                }

                HStack(spacing: 12) {
                    portfolioMetric("Investi", value: formatted(totalInvestment, fractionDigits: 0, suffix: "EUR"))
                    portfolioMetric("Cashflow", value: formatted(monthlyCashflow, fractionDigits: 2, suffix: "EUR"))
                }
            }
            .padding(18)
            .background(ProjectListPalette.brand)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
    }

    private var totalInvestment: Double {
        projects.reduce(0) { $0 + $1.costs.total }
    }

    private var monthlyCashflow: Double {
        projects.reduce(0) { $0 + $1.result.monthlyCashflow }
    }

    private func portfolioMetric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.65))

            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatted(_ value: Double, fractionDigits: Int, suffix: String) -> String {
        let format = "%.\(fractionDigits)f %@"
        return String(format: format, value, suffix)
    }
}

private struct ProjectRowView: View {
    let project: InvestmentProjectSnapshot

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 3)
                .fill(cashflowColor)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(projectTitle)
                            .font(.headline)
                            .foregroundStyle(ProjectListPalette.ink)

                        Text(project.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(formattedCashflow)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(cashflowColor)
                }

                HStack(spacing: 8) {
                    Label("Bien + travaux", systemImage: "house")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(projectAmount, specifier: "%.0f") EUR")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(ProjectListPalette.ink)
                }
            }
        }
        .padding(.vertical, 10)
    }

    private var projectAmount: Double {
        project.costs.price + project.costs.works
    }

    private var formattedCashflow: String {
        String(format: "%.2f EUR", project.result.monthlyCashflow)
    }

    private var cashflowColor: Color {
        project.result.monthlyCashflow < 0 ? ProjectListPalette.loss : ProjectListPalette.gain
    }

    private var projectTitle: String {
        let name = project.draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(project.createdAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return name
    }
}

private struct ProjectSelectableRowView: View {
    let project: InvestmentProjectSnapshot
    let isSelected: Bool
    let isDisabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? ProjectListPalette.brand : .secondary)
                .frame(width: 28)

            ProjectRowView(project: project)
                .opacity(isDisabled ? 0.45 : 1)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(projectTitle)
        .accessibilityValue(isSelected ? "Sélectionné" : "Non sélectionné")
    }

    private var projectTitle: String {
        let name = project.draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(project.createdAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return name
    }
}

enum ProjectComparisonLimits {
    static let minimumSelectionCount = 2
    static let maximumSelectionCount = 4
}

private enum ProjectListPalette {
    static let background = Color(red: 0.93, green: 0.97, blue: 0.96)
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.14)
    static let gain = Color(red: 0.00, green: 0.48, blue: 0.38)
    static let loss = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let gold = Color(red: 0.91, green: 0.69, blue: 0.32)
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectListView(store: ProjectStore(), onAddProject: {})
        }
    }
}
