//
//  PacCodeView.swift
//  PennMobile
//
//  Created by Jordan Hochman on 4/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct PacCodeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = PacCodeViewModel()
    @State private var showRefreshConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Image("PAC_Code")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .foregroundColor(.primary)
//                .padding(.top, 52)
            
            Text("PAC Code")
                .font(.system(size: 35))
                .foregroundColor(.primary)
            
            Text("After being fetched from Campus Express, your PAC code is stored securely on your device. It requires your authentication to view each time and never leaves your device.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
//                .padding(.horizontal, 20)
            
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    Text(viewModel.digit(at: index))
                        .font(.system(size: 30, weight: .bold))
                        .frame(width: 70, height: 70)
                        .background(Color.grey6)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 25)
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            Spacer()
        }
        .navigationBarTitle("PAC Code", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showRefreshConfirmation = true
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
            }
        }
        .confirmationDialog(
            "Refresh PAC Code",
            isPresented: $showRefreshConfirmation,
            titleVisibility: .visible,
            actions: {
                Button("Yes", role: .destructive) {
                    viewModel.refreshPacCode()
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("Has there been a change to your PAC Code? Would you like Penn Mobile to refresh your information?")
            }
        )
        // Alert for errors or login issues
        .alert("Error", isPresented: $viewModel.showAlert, actions: {
            Button("OK", role: .cancel) {
                // If login is required, dismiss this view
                if viewModel.requiresLogin {
                    dismiss()
                }
            }
        }, message: {
            Text(viewModel.alertMessage ?? "")
        })
        // Authenticate and load PAC Code when view appears
        .onAppear {
            viewModel.requestAuthentication(cancelText: "Go Back", reasonText: "Authenticate to see your PAC Code")
        }
        // Clear PAC Code when view disappears
        .onDisappear {
            viewModel.clearPacCode()
        }
    }
}

@Observable
class PacCodeViewModel {
    var pacCode: String?
    var isLoading: Bool = false
    var showAlert: Bool = false
    var alertMessage: String?
    var requiresLogin: Bool = false
    
    func digit(at index: Int) -> String {
        guard let pacCode, pacCode.count > index else { return "" }
        let char = pacCode[pacCode.index(pacCode.startIndex, offsetBy: index)]
        return String(char)
    }
    
    /// Simulates authentication and then loads (or fetches) the PAC Code.
    func requestAuthentication() {
        // Replace the following simulation with your LocalAuthentication (LAContext) flow.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if the user is logged in
            if Account.isLoggedIn {
                if let storedCode = KeychainAccessible.instance.getPacCode() {
                    // Animate the change
                    withAnimation {
                        self.pacCode = storedCode
                    }
                } else {
                    self.handleNetworkPacCodeRefetch()
                }
            } else {
                self.alertMessage = "Please login to use this feature"
                self.requiresLogin = true
                self.showAlert = true
            }
        }
    }
    
    /// Refreshes the PAC Code by refetching it from the network.
//    func refreshPacCode() {
////        handleNetworkPacCodeRefetch()
//    }
    
    /// Performs the network call to fetch the PAC Code.
    func refreshPacCode() {
        self.isLoading = true
        let popVC = {}
        PacCodeNetworkManager.instance.getPacCode { result in
            self.isLoading = false
            showRefreshAlertForError(result: result, title: "PAC Code",
            success: { pacCode in
                KeychainAccessible.instance.savePacCode(pacCode)
                self.pacCode = pacCode
            },
            noInternet: popVC, parsingError: popVC, authenticationError: self.handleAuthenticationError)
//            switch result {
//            case .success(let newCode):
//                KeychainAccessible.instance.savePacCode(newCode)
//                withAnimation {
//                    self.pacCode = newCode
//                }
//            case .failure(let error):
//                self.alertMessage = error.localizedDescription
//                self.showAlert = true
//            }
        }
    }
    
    func clearPacCode() {
        pacCode = nil
    }
}

#Preview {
    PacCodeView()
}
