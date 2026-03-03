import SwiftUI

struct DiagnosticsView: View {
    let isLoading: Bool
    let isCapturing: Bool
    let onCaptureDiagnostics: () async -> Void
    let onCancelCapture: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diagnostics")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 8) {
                Button(action: {
                    Task {
                        await onCaptureDiagnostics()
                    }
                }) {
                    HStack {
                        if isCapturing {
                            LoadingSpinner()
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                        }
                        Text(isCapturing ? "Capturing..." : "Capture Diagnostics")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCapturing ? Color.gray : Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading || isCapturing)

                if isCapturing {
                    Button(action: {
                        onCancelCapture()
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Cancel")
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.teal.opacity(0.05))
        .cornerRadius(12)
    }
}
