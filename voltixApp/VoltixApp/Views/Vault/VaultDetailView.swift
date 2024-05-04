//
//
//  VaultDetailView.swift
//  VoltixApp
//
//  Created by Amol Kumar on 2024-03-07.
//

import SwiftUI

struct VaultDetailView: View {
    @Binding var showVaultsList: Bool
    @Binding var isEditingChains: Bool
    let vault: Vault
    
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var viewModel: VaultDetailViewModel
    
    @State var showSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Background()
            view
            scanButton
        }
        .onAppear {
            setData()
            appState.currentVault = vault
			ApplicationState.shared.currentVault = vault
        }
        .onChange(of: vault) {
            setData()
        }
        .onChange(of: vault.coins) {
            setData()
        }
        .sheet(isPresented: $showSheet, content: {
            NavigationView {
                ChainSelectionView(showChainSelectionSheet: $showSheet, vault: vault)
            }
        })
    }
    
    var view: some View {
        ScrollView {
            if viewModel.coinsGroupedByChains.count>1 {
                list
            } else {
                emptyList
            }
            
            addButton
            Spacer()
        }
        .opacity(showVaultsList ? 0 : 1)
    }
    
    var list: some View {
        List {
            ForEach(viewModel.coinsGroupedByChains.sorted(by: {
                $0.order < $1.order
            }), id: \.id) { group in
                ChainNavigationCell(group: group, vault: vault, isEditingChains: $isEditingChains)
                    .listRowInsets(EdgeInsets())
            }
            .onMove(perform: isEditingChains ? move : nil)
            .background(Color.backgroundBlue)
            .listRowInsets(EdgeInsets())
        }
        .listStyle(PlainListStyle())
        .frame(height: getListHeight())
        .padding(.top, 30)
        .background(Color.backgroundBlue)
    }
    
    var emptyList: some View {
        ErrorMessage(text: "noChainSelected")
            .padding(.vertical, 50)
    }
    
    var addButton: some View {
        HStack {
            chooseChainButton
            Spacer()
            settingsButton
        }
        .padding(16)
        .padding(.bottom, 150)
        .background(Color.backgroundBlue)
        .listRowInsets(EdgeInsets())
    }
    
    var chooseChainButton: some View {
        Button {
            showSheet.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                Text(NSLocalizedString("chooseChains", comment: "Choose Chains"))
            }
            .listRowInsets(EdgeInsets())
        }
        .font(.body16MenloBold)
        .foregroundColor(.turquoise600)
        .listRowInsets(EdgeInsets())
    }
    
    var settingsButton: some View {
        NavigationLink {
            EditVaultView(vault: vault)
        } label: {
            NavigationSettingButton(tint: .turquoise600)
        }
        .frame(width: 30, height: 30)
        .listRowInsets(EdgeInsets())
    }
       
    var scanButton: some View {
        NavigationLink {
            JoinKeysignView(vault: vault)
        } label: {
            ZStack {
                Circle()
                    .foregroundColor(.blue800)
                    .frame(width: 80, height: 80)
                    .opacity(0.8)
                
                Circle()
                    .foregroundColor(.turquoise600)
                    .frame(width: 60, height: 60)
                
                Image(systemName: "camera")
                    .font(.title30MenloUltraLight)
                    .foregroundColor(.blue600)
            }
            .opacity(showVaultsList ? 0 : 1)
        }
    }
    
    private func setData() {
        viewModel.fetchCoins(for: vault)
        setOrder()
    }
    
    private func setOrder() {
        for index in 0..<viewModel.coinsGroupedByChains.count {
            viewModel.coinsGroupedByChains[index].setOrder(index)
        }
    }
    
    private func move(from: IndexSet, to: Int) {
        let fromIndex = from.first ?? 0
        
        if fromIndex<to {
            moveDown(fromIndex: fromIndex, toIndex: to-1)
        } else {
            moveUp(fromIndex: fromIndex, toIndex: to)
        }
    }
    
    private func moveDown(fromIndex: Int, toIndex: Int) {
        let groups = viewModel.coinsGroupedByChains
        
        for index in fromIndex...toIndex {
            groups[index].order = groups[index].order-1
        }
        groups[fromIndex].order = toIndex
    }
    
    private func moveUp(fromIndex: Int, toIndex: Int) {
        let groups = viewModel.coinsGroupedByChains
        
        groups[fromIndex].order = toIndex
        
        for index in toIndex...fromIndex {
            groups[index].order = groups[index].order+1
        }
    }
    
    private func getListHeight() -> CGFloat {
        CGFloat(30+(viewModel.coinsGroupedByChains.count*80))
    }
}

#Preview {
    VaultDetailView(showVaultsList: .constant(false), isEditingChains: .constant(false), vault: Vault.example)
        .environmentObject(VaultDetailViewModel())
        .environmentObject(ApplicationState.shared)
}
