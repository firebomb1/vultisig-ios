//
//  VaultSelection.swift
//  VoltixApp
//

import SwiftUI
import SwiftData

struct VaultSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState:ApplicationState
    @Query var vaults:[Vault]
    @Binding var presentationStack: Array<CurrentScreen>
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: Vault? = nil
    var body: some View {
        List(selection: $appState.currentVault){
            ForEach(vaults){vault in
                Text(vault.name)
                    .swipeActions(){
                        Button("Delete",role:.destructive){
                            self.itemToDelete = vault
                            showingDeleteAlert = true
                        }
                    }
            }
        }
        .confirmationDialog(Text("Delete Vault"), isPresented: $showingDeleteAlert,titleVisibility: .automatic){
            Button("Delete",role:.destructive){
                withAnimation{
                    if let itemToDelete {
                        deleteVault(vault: itemToDelete)
                    }
                }
            }
        } message: {
            Text("Are you sure want to delete selected vault? \n Operation is not reversable")
        }
        .toolbar{
            ToolbarItemGroup(placement: .topBarLeading){
                Button("New vault",systemImage: "plus"){
                    let vault = Vault(name:"Vault #\(vaults.count + 1)")
                    appState.creatingVault = vault
                    self.presentationStack.append(.peerDiscovery)
                }
                Button("Join keygen",systemImage: "circle.hexagonpath"){
                    let vault = Vault(name:"Vault #\(vaults.count + 1)")
                    appState.creatingVault = vault
                    self.presentationStack.append(.joinKeygen)
                }
            }
        }.navigationBarBackButtonHidden()
    }
    func deleteVault(vault:Vault){
        modelContext.delete(vault)
        do{
            try modelContext.save()
        } catch {
            print("Error:\(error)")
        }
    }
}

#Preview("VaultSelection") {
    ModelContainerPreview(Vault.sampleVaults){
        VaultSelectionView(presentationStack: .constant([]))
    }
}

