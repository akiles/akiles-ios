import SwiftUI

struct NFCCardScanView: View {
    let isCardScanning: Bool
    let isLoading: Bool
    let onScanCard: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NFC Card Scanner")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Text("Hold your NFC card near the device to scan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    Task {
                        await onScanCard()
                    }
                }) {
                    HStack {
                        if isCardScanning {
                            LoadingSpinner()
                        } else {
                            Image(systemName: "wave.3.right.circle.fill")
                        }
                        Text(isCardScanning ? "Scanning..." : "Scan NFC Card")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCardScanning ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isCardScanning || isLoading)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }
}