//
//  EditVaultView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-03-12.
//

import SwiftUI
import SwiftData

struct EditVaultView: View {
    let vault: Vault
    
    @State var showVaultExporter = false
    @State var showAlert = false
    @State var navigateBackToHome = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query var vaults: [Vault]
    
    var body: some View {
        exporter
    }
    
    var base: some View {
        ZStack {
            Background()
            view
        }
    }
    
    var navigation: some View {
        base
            .navigationBarBackButtonHidden(true)
            .navigationTitle(NSLocalizedString("editVault", comment: "Edit Vault View title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationBackButton()
                }
            }
    }
    
    var alert: some View {
        navigation
            .alert(NSLocalizedString("deleteVaultTitle", comment: ""), isPresented: $showAlert) {
                Button(NSLocalizedString("delete", comment: ""), role: .destructive) { delete() }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("deleteVaultDescription", comment: ""))
            }
            .navigationDestination(isPresented: $navigateBackToHome) {
                HomeView(selectedVault: vaults.first, showVaultsList: true)
            }
    }
    
    var exporter: some View {
        alert
            .fileExporter(isPresented: $showVaultExporter,
                          document: VultisigDocument(vault: BackupVault(version: .v1, vault: vault)),
                          contentType: .data,
                          defaultFilename: "\(vault.getExportName())") { result in
                switch result {
                case .failure(let error):
                    print("Failed to export, error: \(error.localizedDescription)")
                case .success(let url):
                    print("Exported to \(url)")
                }
            }
    }
    
    var view: some View {
        ScrollView {
            VStack(spacing: 16) {
                deviceName
                vaultDetails
                backupVault
                editVault
                reshareVault
                deleteVault
            }
        }
    }
    
    var deviceName: some View {
        Text(vault.localPartyID)
            .padding(.top, 30)
            .font(.body16MenloBold)
            .foregroundColor(.neutral0)
    }
    
    var vaultDetails: some View {
        NavigationLink {
            VaultPairDetailView(vault: vault)
        } label: {
            EditVaultCell(title: "vaultDetailsTitle", description: "vaultDetailsDescription", icon: "info")
        }
    }
    
    var backupVault: some View {
        Button {
            showVaultExporter = true
        } label: {
            EditVaultCell(title: "backup", description: "backupVault", icon: "arrow.down.circle.fill")
        }
    }
    
    var editVault: some View {
        NavigationLink {
            RenameVaultView(vault: vault)
        } label: {
            EditVaultCell(title: "rename", description: "renameVault", icon: "square.and.pencil")
        }
    }
    
    var deleteVault: some View {
        Button {
            showDeleteAlert()
        } label: {
            EditVaultCell(title: "delete", description: "deleteVault", icon: "trash.fill", isDestructive: true)
        }
    }
    
    var reshareVault: some View {
        NavigationLink {
            SetupVaultView(tssType: .Reshare, vault: vault)
        } label: {
            EditVaultCell(title: "reshare", description: "reshareVault", icon: "square.and.arrow.up.fill")
        }
    }
    
    private func showDeleteAlert() {
        showAlert.toggle()
    }
    
    private func delete() {
        modelContext.delete(vault)
        
        do {
            try modelContext.save()
        } catch {
            print("Error: \(error)")
        }
        navigateBackToHome = true
    }
}

#Preview {
    EditVaultView(vault: Vault.example)
}
