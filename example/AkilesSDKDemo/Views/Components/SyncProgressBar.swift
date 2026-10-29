import SwiftUI
import AkilesSDK

struct SyncProgressBar: View {
    let progress: Float
    let status: SyncStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: CGFloat(progress / 100.0) * geometry.size.width, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
    
    private var statusText: String {
        switch status {
        case .scanning: return "Scanning"
        case .connecting: return "Connecting"
        case .syncingDevice: return "Syncing Device"
        case .syncingServer: return "Syncing Server"
        @unknown default: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .scanning: return .blue
        case .connecting: return .orange
        case .syncingDevice: return .purple
        case .syncingServer: return .green
        @unknown default: return .gray
        }
    }
}