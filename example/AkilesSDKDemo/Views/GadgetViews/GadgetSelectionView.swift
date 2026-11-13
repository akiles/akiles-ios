import SwiftUI
import AkilesSDK

struct GadgetSelectionView: View {
    let gadgets: [Gadget]
    @Binding var selectedGadget: Gadget?
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Gadgets")
                .font(.headline)
                .fontWeight(.semibold)
            
            if gadgets.isEmpty {
                Text("No gadgets available. Select a session above to load gadgets.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Gadget:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Select Gadget", selection: $selectedGadget) {
                        Text("Select a gadget").tag(nil as Gadget?)
                        ForEach(gadgets, id: \.id) { gadget in
                            Text("\(gadget.name) (\(gadget.id))").tag(gadget as Gadget?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 80)
                    .clipped()
                    .disabled(isLoading)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}