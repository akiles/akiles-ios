import SwiftUI
import AkilesSDK

struct HardwareItemView: View {
    let hardware: Hardware
    let sessionIDs: [String]
    @Binding var selectedSessionID: String
    let isLoading: Bool
    let isSyncing: Bool
    let onSync: (String, String) async -> Void
    let onCancelSync: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading) {
                    Text(hardware.name)
                        .font(.body)
                        .fontWeight(.medium)
                    Text("ID: \(hardware.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if !sessionIDs.isEmpty {
                HStack(spacing: 8) {
                    Button(action: {
                        Task {
                            await onSync(selectedSessionID, hardware.id)
                        }
                    }) {
                        HStack {
                            if isLoading || isSyncing {
                                LoadingSpinner()
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            Text(isSyncing ? "Syncing..." : "Sync")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isSyncing ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .disabled(isLoading || isSyncing || selectedSessionID.isEmpty)
                    
                    if selectedSessionID.isEmpty {
                        Text("Select a session above to sync")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Sync with session: \(selectedSessionID)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No sessions available. Add a session first.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}