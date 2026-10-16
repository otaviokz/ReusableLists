//
//  AboutView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import WebKit
import SwiftData

struct AboutView: View {
    @EnvironmentObject private var onboardigState: OnboardingState
    @Environment(\.modelContext) private var modelContext
    @State private var exportedFile: ExportedFile?
    @State private var showExportError = false

    var body: some View {
        VStack {
            Form {
                HStack {
                    Image.play.sizedToFitSquare(side: 21)
                        .padding(.top, 2)
                    Image("").sizedToFitSquare(side: 1.625)
                    Button { onboardigState.reset() }
                    label: { Text("Onboarding") }
                }
                .padding(.leading, 4)
                
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/reusable-lists/id6478542301")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Link(destination: MigrationExporter.reusableListsPlusPlusAppStoreURL) {
                    Label("Get Reusable Lists++", systemImage: "arrow.up.forward.app")
                }
                Button(action: exportToReusableListsPlusPlus) {
                    Label("Export Data to Reusable Lists++", systemImage: "square.and.arrow.up.on.square")
                }
                LabeledContent("Version", value: "3.0.0")
                
                Section("Final Update") {
                    Text("Version 3.0.0 is the last update published for Reusable Lists. Soon you'll be able to export all your data to the new app, Reusable Lists++.")
                    Text("1. Tap \"Get Reusable Lists++\" above and install it from the App Store.")
                    Text("2. Tap \"Export Data to Reusable Lists++\" above.")
                    Text("3. In the share sheet, choose Reusable Lists++ to import your lists and blueprints.")
                }
                .foregroundStyle(Color.primary)
                
                HTMLView(fileName: "PrivacyPolicy")
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
            .foregroundStyle(Color.cyan)
            .navigationTitle("About")
        }
        .sheet(item: $exportedFile) { file in
            ActivityView(activityItems: [file.url])
                .presentationDetents([.medium, .large])
        }
        .alert("Couldn't export your data", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        }
    }

    /// Exports all data as JSON and presents the share sheet so the user can send it to Reusable Lists++.
    private func exportToReusableListsPlusPlus() {
        do {
            let url = try MigrationExporter(context: modelContext).exportToFile()
            exportedFile = ExportedFile(url: url)
        } catch {
            logger.error("Failed to export data for migration: \(error.localizedDescription)")
            showExportError = true
        }
    }
}

private struct ExportedFile: Identifiable {
    let id = UUID()
    let url: URL
}

/// Wraps `UIActivityViewController` so a file generated on demand can be shared.
private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AboutView()
}
