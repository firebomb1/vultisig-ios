//
//  KeysignDiscovery.swift
//  VoltixApp

import Dispatch
import Mediator
import OSLog
import SwiftUI

private let logger = Logger(subsystem: "keysign-discovery", category: "view")
struct KeysignDiscoveryView: View {
    enum KeysignDiscoveryStatus {
        case WaitingForDevices
        case FailToStart
        case Keysign
    }
    
    @Binding var presentationStack: [CurrentScreen]
    @EnvironmentObject var appState: ApplicationState
    @State private var peersFound = [String]()
    @State private var selections = Set<String>()
    private let mediator = Mediator.shared
    private let serverAddr = "http://127.0.0.1:8080"
    private let sessionID = UUID().uuidString
    @State private var currentState = KeysignDiscoveryStatus.WaitingForDevices
    @State private var localPartyID = ""
    let keysignPayload: KeysignPayload
    @State private var keysignMessages = [String]()
    @StateObject var participantDiscovery = ParticipantDiscovery()
    private let serviceName = "VoltixApp-" + Int.random(in: 1 ... 1000).description
    
    var body: some View {
        VStack {
            switch self.currentState {
                case .WaitingForDevices:
                    VStack {
                        Text("Pair with two other devices:".uppercased())
                            .font(.body18MenloBold)
                            .multilineTextAlignment(.center)
                        
                        self.getQrImage(size: 100)
                            .resizable()
                            .scaledToFit()
                            .padding()
                        Text("Scan the above QR CODE.".uppercased())
                            .font(.body13Menlo)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.systemFill)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                    
                    // TODO: Validate if it is <= 3 devices
                    if self.participantDiscovery.peersFound.count == 0 {
                        VStack {
                            HStack {
                                Text("Looking for devices... ")
                                    .font(.body15MenloBold)
                                    .multilineTextAlignment(.center)
                                
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .padding(2)
                            }
                        }
                        .padding()
                        .background(Color.systemFill)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                    }
                    
                    List(self.participantDiscovery.peersFound, id: \.self, selection: self.$selections) { peer in
                        HStack {
                            Image(systemName: self.selections.contains(peer) ? "checkmark.circle" : "circle")
                            Text(peer)
                        }
                        .onTapGesture {
                            if self.selections.contains(peer) {
                                self.selections.remove(peer)
                            } else {
                                self.selections.insert(peer)
                            }
                        }
                    }
                    
                    Button(action: {
                        self.startKeysign(allParticipants: self.selections.map { $0 })
                        self.currentState = .Keysign
                        self.participantDiscovery.stop()
                    }) {
                        HStack {
                            Text("Sign".uppercased())
                                .font(.title30MenloBlack)
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 10, height: 15)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(self.selections.count < self.appState.currentVault?.getThreshold() ?? Int.max)
                case .FailToStart:
                    Text("fail to start keysign")
                case .Keysign:
                    KeysignView(presentationStack: self.$presentationStack,
                                keysignCommittee: self.selections.map { $0 },
                                mediatorURL: self.serverAddr,
                                sessionID: self.sessionID,
                                keysignType: self.keysignPayload.coin.chain.signingKeyType,
                                messsageToSign: self.keysignMessages, // need to figure out all the prekeysign hashes
                                localPartyKey: self.localPartyID,
                                keysignPayload: self.keysignPayload)
            }
        }
        .navigationTitle("MAIN DEVICE")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationButtons.backButton(presentationStack: self.$presentationStack)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationButtons.questionMarkButton
            }
        }
        .onAppear {
            if let localPartyID = appState.currentVault?.localPartyID, !localPartyID.isEmpty {
                self.localPartyID = localPartyID
            } else {
                self.localPartyID = Utils.getLocalDeviceIdentity()
            }
            guard let vault = appState.currentVault else {
                self.currentState = .FailToStart
                logger.error("no vault found")
                return
            }
            let keysignMessageResult = self.keysignPayload.getKeysignMessages(vault: vault)
            switch keysignMessageResult {
                case .success(let preSignedImageHash):
                    self.keysignMessages = preSignedImageHash
                    if self.keysignMessages.isEmpty {
                        logger.error("no meessage need to be signed")
                        self.currentState = .FailToStart
                    }
                case .failure(let err):
                    logger.error("Failed to get preSignedImageHash: \(err)")
                    self.currentState = .FailToStart
            }
        }
        .task {
            // start the mediator , so other devices can discover us
            Task {
                self.mediator.start(name: self.serviceName)
                self.startKeysignSession()
            }
            self.participantDiscovery.getParticipants(serverAddr: self.serverAddr, sessionID: self.sessionID)
        }
        .onDisappear {
            logger.info("mediator server stopped")
            self.participantDiscovery.stop()
            self.mediator.stop()
        }
    }
    
    private func startKeysign(allParticipants: [String]) {
        let urlString = "\(self.serverAddr)/start/\(self.sessionID)"
        Utils.sendRequest(urlString: urlString, method: "POST", body: allParticipants) { _ in
            logger.info("kicked off keysign successfully")
        }
    }
    
    private func startKeysignSession() {
        let urlString = "\(self.serverAddr)/\(self.sessionID)"
        let body = [self.localPartyID]
        Utils.sendRequest(urlString: urlString, method: "POST", body: body) { success in
            if success {
                logger.info("Started session successfully.")
            } else {
                logger.info("Failed to start session.")
            }
        }
    }
    
    func getQrImage(size: CGFloat) -> Image {
        let keysignMsg = KeysignMessage(sessionID: self.sessionID,
                                        serviceName: self.serviceName,
                                        payload: self.keysignPayload)
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(keysignMsg)
            return Utils.getQrImage(data: jsonData, size: size)
        } catch {
            logger.error("fail to encode keysign messages to json,error:\(error)")
        }
        
        return Image(systemName: "xmark")
    }
}

class ParticipantDiscovery: ObservableObject {
    @Published var peersFound = [String]()
    var discoverying = true
    
    func stop() {
        self.discoverying = false
    }
    
    func getParticipants(serverAddr: String, sessionID: String) {
        let urlString = "\(serverAddr)/\(sessionID)"
        Task.detached {
            repeat {
                Utils.getRequest(urlString: urlString, headers: [String: String](), completion: { result in
                    switch result {
                        case .success(let data):
                            if data.isEmpty {
                                logger.error("No participants available yet")
                                return
                            }
                            do {
                                let decoder = JSONDecoder()
                                let peers = try decoder.decode([String].self, from: data)
                                DispatchQueue.main.async {
                                    for peer in peers {
                                        if !self.peersFound.contains(peer) {
                                            self.peersFound.append(peer)
                                        }
                                    }
                                }
                            } catch {
                                logger.error("Failed to decode response to JSON: \(error)")
                            }
                        case .failure(let error):
                            logger.error("Failed to start session, error: \(error)")
                    }
                })
                try await Task.sleep(for: .seconds(1)) // wait for a second to continue
            } while self.discoverying
        }
    }
}

//
// #Preview {
//    KeysignDiscoveryView(
//        presentationStack: .constant([]),
//        keysignPayload: KeysignPayload(coin: Coin(chain: Chain.Bitcoin,
//                                                  ticker: "BTC", logo: "",
//                                                  address: "bc1qj9q4nsl3q7z6t36un08j6t7knv5v3cwnnstaxu",
//                                                  hexPublicKey: "", feeUnit: "SATS"),
//                                       toAddress: "bc1qj9q4nsl3q7z6t36un08j6t7knv5v3cwnnstaxu",
//                                       toAmount: 1000,
//                                       chainSpecific: .Bitcoin(byteFee: 25),
//                                       utxos: [], memo: nil))
// }
