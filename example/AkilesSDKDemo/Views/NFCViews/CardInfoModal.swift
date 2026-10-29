import SwiftUI
import AkilesSDK

struct CardInfoModal: View {
    @Binding var isPresented: Bool
    let card: Card
    let isUpdating: Bool
    let onUpdateCard: () async -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Card Status Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Card Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Card Type:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text(card.isAkilesCard() ? "Akiles Card" : "Standard NFC Card")
                                .font(.subheadline)
                                .foregroundColor(card.isAkilesCard() ? .green : .orange)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("NFC UID:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text(formatUID(card.getUid()))
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        if card.isAkilesCard() {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("This card is already configured for Akiles")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("This card needs to be updated for Akiles")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                
                // Update Button Section
                if !card.isAkilesCard() {
                    VStack(spacing: 12) {
                        Text("Update Card")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Updating the card will configure it to work with Akiles systems. This process may take a few seconds.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            Task {
                                await onUpdateCard()
                            }
                        }) {
                            HStack {
                                if isUpdating {
                                    LoadingSpinner()
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                                Text(isUpdating ? "Updating Card..." : "Update Card for Akiles")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isUpdating ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(isUpdating)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Scanned Card", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
    
    private func formatUID(_ data: Data) -> String {
        return data.map { String(format: "%02X", $0) }.joined(separator: ":")
    }
}