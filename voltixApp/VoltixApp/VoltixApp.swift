//
//  VoltixApp.swift
//  VoltixApp
//

import Mediator
import SwiftData
import SwiftUI
import WalletCore

@main
struct VoltixApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Vault.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainNavigationStack()
                .environmentObject(ApplicationState.shared) // Shared monolithic mutable state
        }
        .modelContainer(sharedModelContainer)
//        .onChange(of: scenePhase) { phase in
//            if phase == .inactive {
//                // TODO: Anything that needs doing on app backgrounded.
//            }
//        }
    }
}
