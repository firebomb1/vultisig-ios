//
//  SettingsViewModel.swift
//  VoltixApp
//
//  Created by Amol Kumar on 2024-04-05.
//

import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedLanguage: SettingsLanguage = .English
    
    @Published var selectedCurrency: SettingsCurrency {
        didSet {
            SettingsCurrency.current = selectedCurrency
        }
    }
    
    init() {
        self.selectedCurrency = SettingsCurrency.current
    }
    
    static let shared = SettingsViewModel()
    
}
