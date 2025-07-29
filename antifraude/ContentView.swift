//
//  ContentView.swift
//  antifraude
//
//  Created by Christian Santos on 28/07/25.
//

import SwiftUI
import AntifraudeSDK

@available(iOS 14.0, *)
struct ContentView: View {
    @StateObject private var viewModel = LegitimuzDemoViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Legitimuz AntiFraude Demo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        // CPF Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CPF")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("000.000.000-00", text: $viewModel.cpf)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("user@example.com", text: $viewModel.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Ref ID Geoloc Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ref ID Geoloc (Optional)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("geoloc-ref-123", text: $viewModel.refIdGeoloc)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Send Analysis Button
                        Button(action: {
                            viewModel.sendAnalysis()
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                }
                                Text(viewModel.isLoading ? "Analyzing..." : "Send Analysis")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.cpf.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.cpf.isEmpty || viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 20)
                    
                    // Information Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it works:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Enter your CPF and email")
                            Text("2. Optionally enter a Ref ID for geolocation tracking")
                            Text("3. Click 'Send Analysis' to perform fraud detection")
                            Text("4. SDK automatically handles location permissions")
                            Text("5. Analysis is sent with or without location data")
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .alert("SDK Event", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .onAppear {
            viewModel.initializeSDK()
        }
    }
}

@available(iOS 14.0, *)
@MainActor
class LegitimuzDemoViewModel: ObservableObject {
    @Published var cpf: String = ""
    @Published var email: String = ""
    @Published var refIdGeoloc: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var legitimuzSDK: LegitimuzAntiFraude?
    
    func initializeSDK() {
        // SDK Configuration
        let config = LegitimuzSDKConfig(
            apiURL: "https://api.legitimuz.com",  // Replace with actual API URL
            token: "4f83c2e7-4750-4405-ac00-f7a5deba10c8",            // Replace with actual token
            action: "signin",                     // Default action
            origin: "http://app.demo.antifraude.teste.com", // Origin expected by backend
            enableRequestGeolocation: true,       // Enable location tracking
            eventHandler: self
        )
        
        // Create and mount SDK
        legitimuzSDK = LegitimuzAntiFraude.create(config: config)
        legitimuzSDK?.mount()
    }
    
    func sendAnalysis() {
        guard let sdk = legitimuzSDK else {
            showMessage("SDK not initialized")
            return
        }
        
        isLoading = true
        
        sdk.setCpf(cpf)
        sdk.setEmail(email)
        
        let refId = refIdGeoloc.isEmpty ? nil : refIdGeoloc
        sdk.sendAnalysis(refId)
        
        // Reset loading state after a delay (in real app, this would be in the callback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
        }
    }
    
    private func showMessage(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

@available(iOS 14.0, *)
extension LegitimuzDemoViewModel: LegitimuzEventHandler {
    @MainActor
    func onEvent(_ event: LegitimuzEvent) {
        switch event.eventId {
        case "analysis-success":
            isLoading = false
            showMessage("Analysis completed successfully!")
            
        case "api-error":
            isLoading = false
            let message = event.data["message"] as? String ?? "Unknown API error"
            showMessage("API Error: \(message)")
            
        case "geolocation-denied":
            showMessage("Geolocation permission denied")
            
        case "geolocation-not-available":
            showMessage("Geolocation not available")
            
        case "sdk-internal-error":
            isLoading = false
            let message = event.data["message"] as? String ?? "Unknown SDK error"
            showMessage("SDK Error: \(message)")
            
        case "validation-error":
            isLoading = false
            let message = event.data["message"] as? String ?? "Validation error"
            showMessage(message)
            
        default:
            break
        }
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        ContentView()
    } else {
        Text("iOS 14.0+ required")
    }
}
