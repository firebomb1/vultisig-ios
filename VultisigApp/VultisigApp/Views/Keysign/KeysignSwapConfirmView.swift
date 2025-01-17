//
//  KeysignSwapConfirmView.swift
//  VultisigApp
//
//  Created by Artur Guseinov on 29.04.2024.
//

import SwiftUI

struct KeysignSwapConfirmView: View {

    @ObservedObject var viewModel: JoinKeysignViewModel

    var body: some View {
        VStack {
            fields
            button
        }
    }

    var fields: some View {
        ScrollView {
            VStack(spacing: 30) {
                summary
            }
        }
    }

    var summary: some View {
        VStack(spacing: 16) {
            getValueCell(for: "Action", with: getAction())
            Separator()
            getValueCell(for: "Provider", with: getProvider())
            Separator()
            getValueCell(for: "Swap from", with: getFromAmount())
            Separator()
            getValueCell(for: "to", with: getToAmount())
        }
        .padding(16)
        .background(Color.blue600)
        .cornerRadius(10)
    }

    var button: some View {
        Button(action: {
            self.viewModel.joinKeysignCommittee()
        }) {
            FilledButton(title: "joinKeySign")
        }
        .padding(20)
    }

    func getAction() -> String {
        return NSLocalizedString("Swap", comment: "")
    }

    func getProvider() -> String {
        switch viewModel.keysignPayload?.swapPayload {
        case .oneInch:
            return "1Inch"
        case .thorchain:
            return "THORCain"
        case .none:
            return .empty
        }
    }

    func getFromAmount() -> String {
        guard let payload = viewModel.keysignPayload?.swapPayload else { return .empty }
        let amount = payload.fromCoin.decimal(for: payload.fromAmount)
        return "\(amount) \(payload.fromCoin.ticker)"
    }

    func getToAmount() -> String {
        guard let payload = viewModel.keysignPayload?.swapPayload else { return .empty }
        let amount = payload.toAmountDecimal
        return "\(amount) \(payload.toCoin.ticker)"
    }

    func getValueCell(for title: String, with value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString(title, comment: ""))
                .font(.body20MontserratSemiBold)
                .foregroundColor(.neutral0)

            Text(value)
                .font(.body12Menlo)
                .foregroundColor(.turquoise600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func getDetailsCell(for title: String, with value: String) -> some View {
        HStack {
            Text(
                NSLocalizedString(title, comment: "")
                    .replacingOccurrences(of: "Fiat", with: SettingsCurrency.current.rawValue)
            )
            Spacer()
            Text(value)
        }
        .font(.body16MenloBold)
        .foregroundColor(.neutral100)
    }
}
