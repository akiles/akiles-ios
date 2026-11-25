import SwiftUI
import AkilesSDK

struct GadgetActionView: View {
    let selectedGadget: Gadget
    let selectedSessionID: String
    let isLoading: Bool
    let onPerformAction: (String, String, String) async -> Void
    let onCancelAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gadget Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Selected Gadget:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    
                    Text(selectedGadget.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text("(\(selectedGadget.id))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Available Actions
            if selectedGadget.actions.isEmpty {
                Text("No actions available for this gadget")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Actions:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(selectedGadget.actions, id: \.id) { action in
                        HStack {
                            Button(action: {
                                Task {
                                    await onPerformAction(selectedSessionID, selectedGadget.id, action.id)
                                }
                            }) {
                                HStack {
                                    if isLoading {
                                        LoadingSpinner()
                                    } else {
                                        Image(systemName: actionIcon(for: action.name))
                                    }
                                    Text(action.name)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isLoading ? Color.gray : actionColor(for: action.name))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(isLoading)
                            
                            if isLoading {
                                Button(action: {
                                    onCancelAction()
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
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func actionIcon(for actionName: String?) -> String {
        guard let name = actionName?.lowercased() else { return "gear" }
        
        switch name {
        case "open", "unlock":
            return "lock.open"
        case "close", "lock":
            return "lock"
        case "start", "begin":
            return "play.circle"
        case "stop", "end":
            return "stop.circle"
        case "toggle":
            return "switch.2"
        case "reset":
            return "arrow.clockwise"
        default:
            return "gear"
        }
    }
    
    private func actionColor(for actionName: String?) -> Color {
        guard let name = actionName?.lowercased() else { return .blue }
        
        switch name {
        case "open", "unlock", "start", "begin":
            return .green
        case "close", "lock", "stop", "end":
            return .red
        case "toggle":
            return .orange
        case "reset":
            return .purple
        default:
            return .blue
        }
    }
}