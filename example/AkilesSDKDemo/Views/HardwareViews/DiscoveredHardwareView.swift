import SwiftUI
import AkilesSDK

struct DiscoveredHardwareView: View {
    let discoveredHardware: [Hardware]
    let sessionIDs: [String]
    @Binding var selectedSessionID: String
    let isLoading: Bool
    let isSyncing: Bool
    let syncProgress: Float
    let syncStatus: SyncStatus
    let onSync: (String, String) async -> Void
    let onCancelSync: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discovered Hardware")
                .font(.headline)
                .fontWeight(.semibold)
            
            if discoveredHardware.isEmpty {
                Text("No hardware devices discovered. Scan for hardware first.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(spacing: 8) {
                    // Sync Progress Bar (shown when syncing)
                    if isSyncing {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sync in Progress")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.purple)
                                    
                                    SyncProgressBar(progress: syncProgress, status: syncStatus)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    onCancelSync()
                                }) {
                                    HStack {
                                        Image(systemName: "xmark")
                                        Text("Cancel")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                    .font(.caption)
                                }
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    ForEach(discoveredHardware, id: \.id) { hardware in
                        HardwareItemView(
                            hardware: hardware,
                            sessionIDs: sessionIDs,
                            selectedSessionID: $selectedSessionID,
                            isLoading: isLoading,
                            isSyncing: isSyncing,
                            onSync: onSync,
                            onCancelSync: onCancelSync
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
    }
}