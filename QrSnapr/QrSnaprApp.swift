import Cocoa
import SwiftUI
import Vision
import KeyboardShortcuts


class QRCodeReader {
    static func readQRCode(completion: @escaping (Result<String, Error>) -> Void) {
        let pasteboard = NSPasteboard.general
        guard let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            completion(.failure(NSError(domain: "No image found in clipboard", code: 0, userInfo: nil)))
            return
        }
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(.failure(NSError(domain: "Failed to convert NSImage to CGImage", code: 1, userInfo: nil)))
            return
        }
        
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation], let payload = results.first?.payloadStringValue else {
                completion(.failure(NSError(domain: "No QR code detected in the image", code: 2, userInfo: nil)))
                return
            }
            
            completion(.success(payload))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}

extension AppState {
    func openSettings() {
        let settingsView = SettingsScreen()
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 400, height: 200))
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.title = "Shortcuts"
    }
}

@MainActor
final class AppState: ObservableObject {
    init() {
        KeyboardShortcuts.onKeyDown(for: .toggleQrDetect) {
            self.readQRCode()
        }
    }
    
    func readQRCode() {
        print("QR Code Reader Triggered")
        QRCodeReader.readQRCode { result in
            DispatchQueue.main.async {
                self.handleQRCodeDetection(result: result)
            }
        }
    }
    
    private func handleQRCodeDetection(result: Result<String, Error>) {
        switch result {
        case .success(let payload):
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(payload, forType: .string)
            showAlert(message: "QR Code Copied to clipboard")
        case .failure(_):
            showAlert(message: "Error detecting QR code")
        }
    }

    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
     func donate() {
        // Insert donation logic here
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("https://dagpi.xyz/donate", forType: .string)
        showAlert(message: "Donation link on your clipboard :)")
        
    }
}

@main
struct SwiftUIMenuBarApp: App {

    @StateObject private var appState = AppState()
    
    
    var body: some Scene {
        MenuBarExtra("Qr Code Reader", systemImage: "qrcode") {
            Button("Read QR Code", action: appState.readQRCode)
            Divider()
            Button("Shortcuts", action: appState.openSettings)
            Button("Quit", action: quitApp)
        }
    }
    
    
    
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
   
    
}


