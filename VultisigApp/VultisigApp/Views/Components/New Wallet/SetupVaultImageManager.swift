//
//  SetupVaultImageManager.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-05-09.
//

import SwiftUI

struct SetupVaultImageManager: View {
    @Binding var selectedTab: SetupVaultState
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var body: some View {
        VStack(spacing: 12) {
            text
            image
            Spacer()
        }
        .padding(24)
        .clipped()
    }
    
    var text: some View {
        Text(selectedTab.getDescription())
            .font(.body12MontserratSemiBold)
            .foregroundColor(.neutral0)
            .lineSpacing(8)
            .multilineTextAlignment(.center)
    }
    
    var imageContent: some View {
        Image(selectedTab.getImage())
            .resizable()
            .frame(maxWidth: .infinity)
            .aspectRatio(contentMode: idiom == .phone ? .fit : .fill)
    }
    
    var image: some View {
        Image(selectedTab.getImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Background()
        SetupVaultImageManager(selectedTab: .constant(.MOfNVaults))
    }
}
