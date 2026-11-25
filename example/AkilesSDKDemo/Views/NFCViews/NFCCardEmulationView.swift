import SwiftUI
import AkilesSDK

struct NFCCardEmulationView: View {
    let akiles: Akiles
    let isLoading: Bool
    let onEmulationComplete: (String) -> Void
    let onEmulationError: (String) -> Void
    
    @State private var selectedLanguage: String = "en"
    @State private var isEmulating: Bool = false
    @State private var emulationTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NFC Card Emulation")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Text("Start card emulation to allow your device to be read by Akiles hardware")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Control Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await startCardEmulation()
                        }
                    }) {
                        HStack {
                            if isEmulating {
                                LoadingSpinner()
                            } else {
                                Image(systemName: "wave.3.right.circle.fill")
                            }
                            Text(isEmulating ? "Emulating..." : "Start Emulation")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isEmulating ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isEmulating || isLoading)
                    
                    if isEmulating {
                        Button(action: {
                            cancelCardEmulation()
                        }) {
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                Text("Cancel")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
                
                if isEmulating {
                    VStack(spacing: 8) {
                        Text("Card emulation is active")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("Hold your device near an Akiles reader")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func startCardEmulation() async {
        isEmulating = true
        
        emulationTask = Task {
            do {
                try await akiles.startCardEmulation()
                DispatchQueue.main.async {
                    self.isEmulating = false
                    self.emulationTask = nil
                    self.onEmulationComplete("Card emulation completed successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    if !Task.isCancelled {
                        self.isEmulating = false
                        self.emulationTask = nil
                        self.onEmulationError("Card emulation failed: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        await emulationTask?.value
    }
    
    private func cancelCardEmulation() {
        emulationTask?.cancel()
        emulationTask = nil
        isEmulating = false
        onEmulationComplete("Card emulation cancelled")
    }
}
