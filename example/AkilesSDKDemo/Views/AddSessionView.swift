import SwiftUI

struct AddSessionView: View {
    @Binding var token: String
    let isLoading: Bool
    let onAddSession: (String) async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add New Session")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                TextField("Enter session token", text: $token)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
                Button(action: {
                    Task {
                        await onAddSession(token)
                    }
                }) {
                    HStack {
                        if isLoading {
                            LoadingSpinner()
                        }
                        Text("Add Session")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading || token.isEmpty)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }
}