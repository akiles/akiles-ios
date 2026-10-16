import SwiftUI
import PassKit
import AkilesSDK

struct AppleWalletView: View {
    let akiles: Akiles
    let selectedSessionID: String
    let isLoading: Bool

    @State private var memberID: String = ""
    @State private var isAdding: Bool = false
    @State private var resultMessage: String = ""
    @State private var resultIsError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Apple Wallet")
                .font(.headline)
                .fontWeight(.semibold)

            if akiles.isAppleWalletSupported() {
                Text("Add the selected session's access pass to Apple Wallet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Only needed for user sessions holding several memberships;
                // a member token always has exactly one.
                TextField("Member ID (optional)", text: $memberID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if isAdding {
                    HStack {
                        LoadingSpinner()
                        Text("Adding to Apple Wallet...")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                } else {
                    AddPassButton {
                        Task {
                            await addToAppleWallet()
                        }
                    }
                    .frame(height: 48)
                    .disabled(selectedSessionID.isEmpty || isLoading)
                    .opacity(selectedSessionID.isEmpty || isLoading ? 0.5 : 1)
                }
            } else {
                Text("Apple Wallet is not available on this device")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if !resultMessage.isEmpty {
                Text(resultMessage)
                    .font(.subheadline)
                    .foregroundColor(resultIsError ? .red : .green)
            }
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
    }

    private func addToAppleWallet() async {
        isAdding = true
        resultMessage = ""
        defer { isAdding = false }

        do {
            try await akiles.addToAppleWallet(
                sessionID: selectedSessionID,
                memberID: memberID.isEmpty ? nil : memberID
            )
            resultMessage = "Pass added to Apple Wallet"
            resultIsError = false
        } catch let error as NSError where error.code == ErrorCode.canceled.rawValue {
            resultMessage = "Canceled"
            resultIsError = false
        } catch {
            resultMessage = "Failed to add pass: \(error.localizedDescription)"
            resultIsError = true
        }
    }
}

// Apple requires its own "Add to Apple Wallet" button artwork.
private struct AddPassButton: UIViewRepresentable {
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> PKAddPassButton {
        let button = PKAddPassButton(addPassButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKAddPassButton, context: Context) {
        context.coordinator.action = action
    }

    final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func tapped() {
            action()
        }
    }
}
