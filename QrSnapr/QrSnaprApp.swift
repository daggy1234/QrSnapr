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

func generateQRCode(from string: String) -> NSImage? {
    let data = string.data(using: .ascii)
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("Q", forKey: "inputCorrectionLevel")
    guard let outputImage = filter.outputImage else { return nil }
    
    let scaleX = 10.0, scaleY = 10.0
    let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: CGFloat(scaleX), y: CGFloat(scaleY)))
    
    let rep = NSCIImageRep(ciImage: transformedImage)
    let nsImage = NSImage(size: rep.size)
    nsImage.addRepresentation(rep)
    return nsImage
}


struct QRCodeGeneratorView: View {
    @State private var inputText: String = ""
    @State private var qrImage: NSImage? = nil
    
    var body: some View {
        VStack {
            Text("Enter text to generate QR Code")
                .font(.headline)
            TextField("Enter text", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button("Generate") {
                    qrImage = generateQRCode(from: inputText)
                }
                if qrImage != nil {
                    Button("Copy to Clipboard") {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        if let tiffData = qrImage?.tiffRepresentation,
                           let bitmap = NSBitmapImageRep(data: tiffData),
                           let pngData = bitmap.representation(using: .png, properties: [:]) {
                            pasteboard.setData(pngData, forType: .png)
                        }
                    }
                }
            }
            if let qrImage = qrImage {
                Image(nsImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 200, height: 200)
                    .padding()
            }
        }
        .padding()
        .frame(width: 300, height: 300)
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
        KeyboardShortcuts.onKeyDown(for: .toggleQrGenerate) {
            self.openQRCodeGenerator()
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
    
    func openQRCodeGenerator() {
            let generatorView = QRCodeGeneratorView()
            let hostingController = NSHostingController(rootView: generatorView)
            let window = NSWindow(contentViewController: hostingController)
            window.setContentSize(NSSize(width: 320, height: 350))
            window.center()
            window.makeKeyAndOrderFront(nil)
            window.title = "QR Code Generator"
        }
}

@main
struct SwiftUIMenuBarApp: App {

    @StateObject private var appState = AppState()
    
    
    var body: some Scene {
        MenuBarExtra("Qr Code Reader", systemImage: "qrcode") {
            Button("Read QR Code", action: appState.readQRCode)
            Button("Generate QR Code", action: appState.openQRCodeGenerator)
            Divider()
            Button("Shortcuts", action: appState.openSettings)
            Button("Quit", action: quitApp)
            Button("Donate", action: appState.donate)
        }
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
   
    
}


