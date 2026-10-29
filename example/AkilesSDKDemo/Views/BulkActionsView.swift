import SwiftUI

struct BulkActionsView: View {
    let isLoading: Bool
    let onRemoveAllSessions: () async -> Void
    let onRefreshAllSessions: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bulk Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Button(action: {
                    Task {
                        await onRefreshAllSessions()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Refresh All")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading)
                
                Button(action: {
                    Task {
                        await onRemoveAllSessions()
                    }
                }) {
                    HStack {
                        Image(systemName: "trash.circle")
                        Text("Remove All")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading)
            }
        }
        .padding()
        .background(Color.red.opacity(0.05))
        .cornerRadius(12)
    }
}