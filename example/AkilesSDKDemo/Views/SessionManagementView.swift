import SwiftUI

struct SessionManagementView: View {
    let sessionIDs: [String]
    @Binding var selectedSessionID: String
    let isLoading: Bool
    let onRemoveSession: (String) async -> Void
    let onRefreshSession: (String) async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Picker("Select Session", selection: $selectedSessionID) {
                    Text("Select a session").tag("")
                    ForEach(sessionIDs, id: \.self) { sessionID in
                        Text(sessionID).tag(sessionID)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                .clipped()
                .disabled(isLoading)
                
                HStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await onRefreshSession(selectedSessionID)
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isLoading || selectedSessionID.isEmpty)
                    
                    Button(action: {
                        Task {
                            await onRemoveSession(selectedSessionID)
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isLoading || selectedSessionID.isEmpty)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
}