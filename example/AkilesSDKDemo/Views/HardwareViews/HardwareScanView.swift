import SwiftUI

struct HardwareScanView: View {
    let isScanning: Bool
    let isLoading: Bool
    let onScan: () async -> Void
    let onCancelScan: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hardware Scanner")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if isScanning {
                    HStack {
                        Button(action: {
                            Task {
                                await onScan()
                            }
                        }) {
                            HStack {
                                LoadingSpinner()
                                Text("Scanning...")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(true)
                        
                        Button(action: {
                            onCancelScan()
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Cancel")
                            }
                            .frame(minWidth: 80)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                } else {
                    Button(action: {
                        Task {
                            await onScan()
                        }
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Scan for Hardware")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isLoading)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}