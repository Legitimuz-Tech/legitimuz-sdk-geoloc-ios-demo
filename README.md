# Legitimuz AntiFraude iOS Demo App

A comprehensive iOS demo application demonstrating how to integrate and use the **AntifraudeSDK** for fraud prevention and detection in your iOS applications.

## 📱 Overview

This demo app showcases the complete integration of Legitimuz's fraud prevention SDK, including:

- ✅ User data collection (CPF, Email)
- 🌍 Automatic geolocation handling with permission management
- 📊 Device fingerprinting and information collection
- 🔄 Real-time fraud analysis
- 🎯 Event-driven architecture with comprehensive error handling
- 🎨 Modern SwiftUI interface

## 🔧 Requirements

- **iOS 14.0+** 
- **Xcode 12.0+**
- **Swift 5.5+**
- Valid Legitimuz API credentials

## 📦 Installation

### Method 1: Swift Package Manager (Recommended)

#### Option A: Add via Xcode UI

1. **Open your iOS project** in Xcode
2. **Navigate to File** → **Add Package Dependencies...**
3. **Enter the package URL**:
   ```
   https://github.com/your-organization/AntifraudeSDK
   ```
4. **Select version requirements**:
   - Choose "Up to Next Major Version" and enter the latest version
   - Or select "Branch" and use `main` for the latest development version
5. **Click "Add Package"**
6. **Select your target** and click "Add Package"

#### Option B: Add via Package.swift

If you're using Swift Package Manager in a Package.swift file:

```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS(.v14)
    ],
    dependencies: [
        .package(
            url: "https://github.com/your-organization/AntifraudeSDK",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: ["AntifraudeSDK"]
        )
    ]
)
```

### Method 2: Manual Installation

#### Download and Add Manually

1. **Download the SDK**:
   - Clone or download the AntifraudeSDK repository
   - Or download the release package from your distribution source

2. **Add to your project**:
   - Drag the `AntifraudeSDK` folder into your Xcode project
   - Ensure "Copy items if needed" is checked
   - Select your target in "Add to target"

3. **Configure Build Settings**:
   - In your target's Build Settings, ensure iOS Deployment Target is set to 14.0 or later

### Method 3: Local Development Setup

If you're working with a local copy of the SDK:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-organization/AntifraudeSDK.git
   ```

2. **Add Local Package**:
   - In Xcode: File → Add Package Dependencies...
   - Click "Add Local..." 
   - Navigate to and select the cloned `AntifraudeSDK` folder
   - Click "Add Package"

## 🛠 Project Configuration

### Required Permissions

Add these permissions to your `Info.plist` if you plan to use geolocation features:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location to provide enhanced fraud prevention services.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app uses location to provide enhanced fraud prevention services.</string>
```

### Import the SDK

After installation, import the SDK in your Swift files:

```swift
import AntifraudeSDK
```

### Verify Installation

Create a simple test to verify the SDK is properly installed:

```swift
import SwiftUI
import AntifraudeSDK

struct TestView: View {
    var body: some View {
        VStack {
            Text("AntifraudeSDK Test")
            Button("Test SDK") {
                let config = LegitimuzSDKConfig(
                    apiURL: "https://test.legitimuz.com",
                    token: "test-token",
                    action: "test"
                )
                let sdk = LegitimuzAntiFraude.create(config: config)
                print("SDK created successfully: \(sdk)")
            }
        }
    }
}
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repository>
cd antifraude
```

### 2. Open in Xcode

```bash
open antifraude.xcodeproj
```

### 3. Configure the SDK

Update the configuration in `ContentView.swift`:

```swift
let config = LegitimuzSDKConfig(
    apiURL: "YOUR_API_URL",           // Replace with your API endpoint
    token: "YOUR_API_TOKEN",          // Replace with your authentication token
    action: "signin",                 // Action type: "signin", "signup", "transaction", etc.
    origin: "YOUR_ORIGIN",            // Your app's origin URL
    enableRequestGeolocation: true,   // Enable automatic location tracking
    eventHandler: self               // Event handler for SDK callbacks
)
```

### 4. Build and Run

Press `Cmd + R` or click the Run button in Xcode.

## 📚 SDK Integration Guide

### Basic Setup

#### 1. Import the SDK

```swift
import AntifraudeSDK
```

#### 2. Initialize the SDK

```swift
class YourViewModel: ObservableObject {
    private var legitimuzSDK: LegitimuzAntiFraude?
    
    func initializeSDK() {
        let config = LegitimuzSDKConfig(
            apiURL: "https://api.legitimuz.com",
            token: "your-api-token",
            action: "signin",
            origin: "your-app-origin",
            enableRequestGeolocation: true,
            eventHandler: self
        )
        
        legitimuzSDK = LegitimuzAntiFraude.create(config: config)
        legitimuzSDK?.mount()
    }
}
```

#### 3. Set User Data

```swift
// Set CPF (automatically removes non-numeric characters)
legitimuzSDK?.setCpf("123.456.789-00")

// Set email
legitimuzSDK?.setEmail("user@example.com")

// Change action if needed
legitimuzSDK?.setAction("transaction")
```

#### 4. Send Analysis

```swift
// Send analysis with optional geolocation reference ID
legitimuzSDK?.sendAnalysis("optional-ref-id")

// Or send without reference ID
legitimuzSDK?.sendAnalysis()
```

### Event Handling

Implement the `LegitimuzEventHandler` protocol to handle SDK events:

```swift
extension YourViewModel: LegitimuzEventHandler {
    @MainActor
    func onEvent(_ event: LegitimuzEvent) {
        switch event.eventId {
        case "analysis-success":
            // Analysis completed successfully
            print("Fraud analysis completed!")
            
        case "api-error":
            // API request failed
            let message = event.data["message"] as? String ?? "Unknown API error"
            print("API Error: \(message)")
            
        case "geolocation-denied":
            // User denied location permission
            print("Location permission denied")
            
        case "geolocation-not-available":
            // Location services not available
            print("Location not available")
            
        case "sdk-internal-error":
            // Internal SDK error
            let message = event.data["message"] as? String ?? "Unknown SDK error"
            print("SDK Error: \(message)")
            
        case "validation-error":
            // Data validation error
            let message = event.data["message"] as? String ?? "Validation error"
            print("Validation Error: \(message)")
            
        default:
            break
        }
    }
}
```

## 🔑 Configuration Options

### LegitimuzSDKConfig Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apiURL` | String | ✅ Yes | Your Legitimuz API endpoint URL |
| `token` | String | ✅ Yes | Authentication token provided by Legitimuz |
| `action` | String | ✅ Yes | Action type ("signin", "signup", "transaction", etc.) |
| `origin` | String? | ❌ Optional | Origin URL for backend validation |
| `enableRequestGeolocation` | Bool | ❌ Optional | Enable automatic location tracking (default: false) |
| `eventHandler` | LegitimuzEventHandler? | ❌ Optional | Event callback handler |

### Action Types

The SDK supports various action types to categorize different user behaviors:

- `"signin"` - User login/authentication
- `"signup"` - User registration  
- `"transaction"` - Financial transactions
- `"password_reset"` - Password reset attempts
- `"profile_update"` - Profile modifications
- Custom actions as needed

## 📍 Geolocation Features

### Automatic Permission Handling

The SDK automatically handles location permissions when `enableRequestGeolocation` is enabled:

1. **Permission Request**: Automatically requests location permission when needed
2. **Graceful Degradation**: Continues analysis even if location is denied
3. **Error Handling**: Provides detailed feedback through events
4. **Privacy Compliant**: Only requests location when explicitly enabled

### Location Events

| Event ID | Description |
|----------|-------------|
| `geolocation-denied` | User denied location permission |
| `geolocation-not-available` | Location services unavailable |

## 🛠 Advanced Usage

### Dynamic Action Changes

```swift
// Change action for different user flows
legitimuzSDK?.setAction("transaction")
legitimuzSDK?.setCpf("12345678900")
legitimuzSDK?.sendAnalysis("transaction-ref-123")
```

### Error Handling Best Practices

```swift
extension YourViewModel: LegitimuzEventHandler {
    @MainActor
    func onEvent(_ event: LegitimuzEvent) {
        switch event.eventId {
        case "analysis-success":
            // Handle successful analysis
            handleSuccessfulAnalysis(event.data)
            
        case "api-error":
            // Retry logic for API errors
            handleAPIError(event.data)
            
        case "validation-error":
            // Show user-friendly validation messages
            showValidationError(event.data)
            
        default:
            // Log unexpected events for debugging
            print("Unhandled event: \(event.eventId)")
        }
    }
}
```

### Memory Management

```swift
class YourViewModel: ObservableObject {
    deinit {
        legitimuzSDK?.destroy()
    }
}
```

## 🎨 UI Integration Examples

### SwiftUI Integration

```swift
struct FraudPreventionView: View {
    @StateObject private var viewModel = FraudViewModel()
    
    var body: some View {
        VStack {
            TextField("CPF", text: $viewModel.cpf)
            TextField("Email", text: $viewModel.email)
            
            Button("Analyze") {
                viewModel.sendAnalysis()
            }
            .disabled(viewModel.cpf.isEmpty)
        }
        .onAppear {
            viewModel.initializeSDK()
        }
        .alert("SDK Event", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
```

### UIKit Integration

```swift
class ViewController: UIViewController {
    private var legitimuzSDK: LegitimuzAntiFraude?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSDK()
    }
    
    private func initializeSDK() {
        let config = LegitimuzSDKConfig(
            apiURL: "your-api-url",
            token: "your-token",
            action: "signin",
            enableRequestGeolocation: true,
            eventHandler: self
        )
        
        legitimuzSDK = LegitimuzAntiFraude.create(config: config)
        legitimuzSDK?.mount()
    }
}

extension ViewController: LegitimuzEventHandler {
    func onEvent(_ event: LegitimuzEvent) {
        DispatchQueue.main.async {
            // Handle events on main thread
        }
    }
}
```

## 🔍 Debugging

### Enable Debug Logging

The SDK provides detailed console logging. Look for messages prefixed with `LegitimuzAntiFraude:` in the Xcode console:

```
LegitimuzAntiFraude: Mounting iOS SDK
LegitimuzAntiFraude: CPF set
LegitimuzAntiFraude: Email set
LegitimuzAntiFraude: === API Request Debug ===
LegitimuzAntiFraude: URL: https://api.legitimuz.com/external/fraud-prevention/analysis
LegitimuzAntiFraude: === API Response Debug ===
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "CPF is required!" | Ensure CPF is set before calling `sendAnalysis()` |
| API 401 errors | Verify your authentication token |
| Location not working | Check location permissions in Settings app |
| Build errors | Ensure iOS deployment target is 14.0+ |

## 📖 API Reference

### LegitimuzAntiFraude Class

```swift
public class LegitimuzAntiFraude {
    static func create(config: LegitimuzSDKConfig) -> LegitimuzAntiFraude
    func mount()
    func setCpf(_ cpf: String)
    func setEmail(_ email: String)
    func setAction(_ newAction: String)
    func sendAnalysis(_ refIdGeoloc: String? = nil)
    func destroy()
}
```

### LegitimuzEvent Structure

```swift
public struct LegitimuzEvent {
    public let eventId: String      // Event identifier
    public let name: String         // Event category
    public let data: [String: Any]  // Event data
}
```

## 🔒 Security Considerations

- **API Token**: Keep your API token secure and never commit it to version control
- **User Data**: The SDK handles sensitive data like CPF - ensure compliance with local data protection laws
- **Network Security**: All API communications use HTTPS
- **Location Privacy**: Location data is only collected when explicitly enabled and with user permission

## 📞 Support

For technical support and questions:

- 📧 **Email**: support@legitimuz.com
- 📚 **Documentation**: [Developer Portal](https://docs.legitimuz.com)
- 🐛 **Issues**: Report issues through your designated support channel

## 📄 License

This demo application is provided as-is for integration guidance. The AntifraudeSDK usage is subject to your agreement with Legitimuz.

---

**Made with ❤️ by Legitimuz** 