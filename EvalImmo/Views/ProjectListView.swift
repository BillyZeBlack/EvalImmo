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
                ContentUnavailableView(
                    "Aucun projet",
                    systemImage: "building.2",
                    description: Text("Les projets sauvegardes apparaitront ici.")
                )
            } else {
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

private struct ProjectRowView: View {
    let project: InvestmentProjectSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(projectTitle)
                .font(.headline)

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
