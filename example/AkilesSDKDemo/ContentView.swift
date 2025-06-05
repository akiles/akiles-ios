import SwiftUI
import AkilesSDK
import Combine

class ToastActionCallback: NSObject, ActionCallback {
    let onToast: (String, Bool) -> Void
    
    init(onToast: @escaping (String, Bool) -> Void) {
        self.onToast = onToast
    }
    
    func onSuccess() {
        onToast("Action completed successfully!", false)
    }
    
    func onError(_ error: Error) {
        onToast("Action failed: \(error.localizedDescription)", true)
    }
    
    func onInternetStatus(_ status: ActionInternetStatus) {
        onToast("Internet status: \(status.rawValue)", false)
    }
    
    func onInternetSuccess() {
        onToast("Internet operation completed successfully!", false)
    }
    
    func onInternetError(_ error: Error) {
        onToast("Internet operation failed: \(error.localizedDescription)", true)
    }
    
    func onBluetoothStatus(_ status: ActionBluetoothStatus) {
        onToast("Bluetooth status: \(status.rawValue)", false)
    }
    
    func onBluetoothStatusProgress(_ percent: Float) {
        onToast("Bluetooth progress: \(Int(percent))%", false)
    }
    
    func onBluetoothSuccess() {
        onToast("Bluetooth operation completed successfully!", false)
    }
    
    func onBluetoothError(_ error: Error) {
        onToast("Bluetooth operation failed: \(error.localizedDescription)", true)
    }
}

class ToastSyncCallback: NSObject, SyncCallback {
    let onToast: (String, Bool) -> Void
    let onProgress: (Float, SyncStatus) -> Void
    
    init(onToast: @escaping (String, Bool) -> Void, onProgress: @escaping (Float, SyncStatus) -> Void) {
        self.onToast = onToast
        self.onProgress = onProgress
    }
    
    func onStatus(_ status: SyncStatus) {
        let statusString: String
        switch status {
        case .scanning: statusString = "Scanning"
        case .connecting: statusString = "Connecting" 
        case .syncingDevice: statusString = "Syncing Device"
        case .syncingServer: statusString = "Syncing Server"
        @unknown default: statusString = "Unknown"
        }
        onToast("Sync status: \(statusString)", false)
        onProgress(0.0, status)
    }
    
    func onStatusProgress(_ percent: Float) {
        onToast("Sync progress: \(Int(percent))%", false)
        onProgress(percent, .syncingDevice) // Default to syncingDevice for progress updates
    }
}

struct ContentView: View {
    let akiles: Akiles
    
    @State private var sessionIDs: [String] = []
    @State private var newToken: String = ""
    @State private var selectedSessionID: String = ""
    @State private var statusMessage: String = ""
    @State private var statusIsError: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var gadgets: [Gadget] = []
    @State private var selectedGadget: Gadget? = nil
    @State private var gadgetToastMessage: String = ""
    @State private var gadgetToastIsError: Bool = false
    @State private var showGadgetToast: Bool = false
    
    // Hardware scanning state
    @State private var discoveredHardware: [Hardware] = []
    @State private var isScanning: Bool = false
    @State private var scanTask: Task<Void, Never>? = nil
    @State private var hardwareToastMessage: String = ""
    @State private var hardwareToastIsError: Bool = false
    @State private var showHardwareToast: Bool = false
    
    // NFC card scanning state
    @State private var scannedCard: Card? = nil
    @State private var isCardScanning: Bool = false
    @State private var showCardModal: Bool = false
    @State private var isCardUpdating: Bool = false
    @State private var nfcToastMessage: String = ""
    @State private var nfcToastIsError: Bool = false
    @State private var showNfcToast: Bool = false
    
    // Sync progress state
    @State private var syncProgress: Float = 0.0
    @State private var syncStatus: SyncStatus = .scanning
    @State private var isSyncing: Bool = false
    @State private var syncTask: Task<Void, Never>? = nil
    
    // Action execution state
    @State private var actionTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack {
                        Text("Akiles SDK Demo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    // Status Message
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .padding()
                            .background(statusIsError ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                            .foregroundColor(statusIsError ? .red : .primary)
                            .cornerRadius(8)
                            .animation(.easeInOut, value: statusMessage)
                    }
                                        
                    // Session IDs Display
                    SessionIDsView(
                        sessionIDs: sessionIDs,
                        isLoading: isLoading,
                        onRefresh: {
                            await refreshSessionIDs()
                        }
                    )
                    
                    // Add Session Widget
                    AddSessionView(
                        token: $newToken,
                        isLoading: isLoading,
                        onAddSession: { token in
                            await addSession(token: token)
                        }
                    )
                    
                    // Session Management Widgets
                    if !sessionIDs.isEmpty {
                        SessionManagementView(
                            sessionIDs: sessionIDs,
                            selectedSessionID: $selectedSessionID,
                            isLoading: isLoading,
                            onRemoveSession: { id in
                                await removeSession(id: id)
                            },
                            onRefreshSession: { id in
                                await refreshSession(id: id)
                            }
                        )
                        
                        BulkActionsView(
                            isLoading: isLoading,
                            onRemoveAllSessions: {
                                await removeAllSessions()
                            },
                            onRefreshAllSessions: {
                                await refreshAllSessions()
                            }
                        )
                        
                        // Gadget Management Widgets
                        VStack(spacing: 12) {
                            GadgetSelectionView(
                                gadgets: gadgets,
                                selectedGadget: $selectedGadget,
                                isLoading: isLoading
                            )
                            
                            if selectedGadget != nil {
                                GadgetActionView(
                                    selectedGadget: selectedGadget!,
                                    selectedSessionID: selectedSessionID,
                                    isLoading: isLoading,
                                    onPerformAction: { sessionID, gadgetID, actionID in
                                        await performAction(sessionID: sessionID, gadgetID: gadgetID, actionID: actionID)
                                    },
                                    onCancelAction: {
                                        cancelAction()
                                    }
                                )
                            }
                            
                            // Gadget Toast Message
                            if showGadgetToast {
                                Text(gadgetToastMessage)
                                    .padding()
                                    .background(gadgetToastIsError ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                    .foregroundColor(gadgetToastIsError ? .red : .green)
                                    .cornerRadius(8)
                                    .animation(.easeInOut, value: showGadgetToast)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            showGadgetToast = false
                                        }
                                    }
                            }
                        }
                        
                        // Hardware Scanning Widgets
                        VStack(spacing: 12) {
                            HardwareScanView(
                                isScanning: isScanning,
                                isLoading: isLoading,
                                onScan: {
                                    await scanForHardware()
                                },
                                onCancelScan: {
                                    cancelScan()
                                }
                            )
                            
                            DiscoveredHardwareView(
                                discoveredHardware: discoveredHardware,
                                sessionIDs: sessionIDs,
                                selectedSessionID: $selectedSessionID,
                                isLoading: isLoading,
                                isSyncing: isSyncing,
                                syncProgress: syncProgress,
                                syncStatus: syncStatus,
                                onSync: { sessionID, hardwareID in
                                    await syncHardware(sessionID: sessionID, hardwareID: hardwareID)
                                },
                                onCancelSync: {
                                    cancelSync()
                                }
                            )
                            
                            // Hardware Toast Message
                            if showHardwareToast {
                                Text(hardwareToastMessage)
                                    .padding()
                                    .background(hardwareToastIsError ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                    .foregroundColor(hardwareToastIsError ? .red : .green)
                                    .cornerRadius(8)
                                    .animation(.easeInOut, value: showHardwareToast)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            showHardwareToast = false
                                        }
                                    }
                            }
                        }
                        
                        // NFC Card Scanning Widget
                        VStack(spacing: 12) {
                            NFCCardScanView(
                                isCardScanning: isCardScanning,
                                isLoading: isLoading,
                                onScanCard: {
                                    await scanNFCCard()
                                }
                            )
                            
                            // NFC Toast Message
                            if showNfcToast {
                                Text(nfcToastMessage)
                                    .padding()
                                    .background(nfcToastIsError ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                    .foregroundColor(nfcToastIsError ? .red : .green)
                                    .cornerRadius(8)
                                    .animation(.easeInOut, value: showNfcToast)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            showNfcToast = false
                                        }
                                    }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await refreshSessionIDs()
            }
        }
        .sheet(isPresented: $showCardModal) {
            if let card = scannedCard {
                CardInfoModal(
                    isPresented: $showCardModal,
                    card: card,
                    isUpdating: isCardUpdating,
                    onUpdateCard: {
                        await updateCard()
                    }
                )
            }
        }
    }
    
    // MARK: - API Functions
    
    private func refreshSessionIDs() async {
        isLoading = true
        do {
            // Retrieve all active session IDs from AkilesSDK
            sessionIDs = try await akiles.getSessionIDs()
            statusMessage = "Loaded \(sessionIDs.count) session(s)"
            statusIsError = false
            
            // Auto-load gadgets for the selected session if available
            if !selectedSessionID.isEmpty && sessionIDs.contains(selectedSessionID) {
                await loadGadgets(sessionID: selectedSessionID)
            } else if !sessionIDs.isEmpty {
                // If no session is selected, select the first one and load its gadgets
                selectedSessionID = sessionIDs.first!
                await loadGadgets(sessionID: selectedSessionID)
            } else {
                // Clear gadgets if no sessions available
                gadgets = []
                selectedGadget = nil
                selectedSessionID = ""
            }
        } catch {
            statusMessage = "Error getting sessions: \(error.localizedDescription)"
            statusIsError = true
            gadgets = []
            selectedGadget = nil
        }
        isLoading = false
    }
    
    private func addSession(token: String) async {
        guard !token.isEmpty else {
            statusMessage = "Please enter a token"
            statusIsError = true
            return
        }
        
        isLoading = true
        do {
            // Add a new session using the provided token
            let sessionID = try await akiles.addSession(token: token)
            statusMessage = "Added session: \(sessionID)"
            statusIsError = false
            newToken = ""
            await refreshSessionIDs()
        } catch {
            statusMessage = "Error adding session: \(error.localizedDescription)"
            statusIsError = true
        }
        isLoading = false
    }
    
    private func removeSession(id: String) async {
        isLoading = true
        do {
            // Remove the specified session from AkilesSDK
            try await akiles.removeSession(id: id)
            statusMessage = "Removed session: \(id)"
            statusIsError = false
            await refreshSessionIDs()
        } catch {
            statusMessage = "Error removing session: \(error.localizedDescription)"
            statusIsError = true
        }
        isLoading = false
    }
    
    private func removeAllSessions() async {
        isLoading = true
        do {
            // Remove all sessions from AkilesSDK
            try await akiles.removeAllSessions()
            statusMessage = "Removed all sessions"
            statusIsError = false
            await refreshSessionIDs()
        } catch {
            statusMessage = "Error removing all sessions: \(error.localizedDescription)"
            statusIsError = true
        }
        isLoading = false
    }
    
    private func refreshSession(id: String) async {
        isLoading = true
        do {
            // Refresh the specified session to update its token/status
            try await akiles.refreshSession(id: id)
            statusMessage = "Refreshed session: \(id)"
            statusIsError = false
        } catch {
            statusMessage = "Error refreshing session: \(error.localizedDescription)"
            statusIsError = true
        }
        isLoading = false
    }
    
    private func refreshAllSessions() async {
        isLoading = true
        do {
            // Refresh all active sessions to update their tokens/status
            try await akiles.refreshAllSessions()
            statusMessage = "Refreshed all sessions"
            statusIsError = false
        } catch {
            statusMessage = "Error refreshing all sessions: \(error.localizedDescription)"
            statusIsError = true
        }
        isLoading = false
    }
    
    private func loadGadgets(sessionID: String) async {
        guard !sessionID.isEmpty else {
            statusMessage = "Please select a session first"
            statusIsError = true
            return
        }
        
        isLoading = true
        do {
            // Retrieve all available gadgets for the specified session
            gadgets = try await akiles.getGadgets(sessionID: sessionID) 
            statusMessage = "Loaded \(gadgets.count) gadget(s) for session \(sessionID)"
            statusIsError = false
            selectedGadget = nil
        } catch {
            statusMessage = "Error loading gadgets: \(error.localizedDescription)"
            statusIsError = true
            gadgets = []
            selectedGadget = nil
        }
        isLoading = false
    }
    
    private func performAction(sessionID: String, gadgetID: String, actionID: String) async {
        isLoading = true
        
        actionTask = Task {
            let callback = ToastActionCallback { message, isError in
                DispatchQueue.main.async {
                    self.gadgetToastMessage = message
                    self.gadgetToastIsError = isError
                    self.showGadgetToast = true
                }
            }
            let options = ActionOptions.initWithDefaults()
            // Perform the specified action on the gadget using AkilesSDK
            await akiles.action(
                sessionID: sessionID,
                gadgetID: gadgetID,
                actionID: actionID,
                options: options,
                callback: callback
            )
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.actionTask = nil
            }
        }
        
        await actionTask?.value
    }
    
    private func scanForHardware() async {
        isScanning = true
        discoveredHardware.removeAll()
        statusMessage = "Scanning for hardware..."
        
        scanTask = Task {
            do {
                // Scan for nearby Akiles hardware devices
                try await akiles.scan { hardware in
                    DispatchQueue.main.async {
                        self.discoveredHardware.append(hardware)
                        self.statusMessage = "Found \(self.discoveredHardware.count) hardware device(s)"
                    }
                }
                
                DispatchQueue.main.async {
                    self.statusMessage = "Scan completed. Found \(self.discoveredHardware.count) hardware device(s)"
                    self.statusIsError = false
                    self.isScanning = false
                    self.scanTask = nil
                }
            } catch {
                DispatchQueue.main.async {
                    if !Task.isCancelled {
                        self.statusMessage = "Error scanning for hardware: \(error.localizedDescription)"
                        self.statusIsError = true
                    } else {
                        self.statusMessage = "Scan cancelled"
                        self.statusIsError = false
                    }
                    self.isScanning = false
                    self.scanTask = nil
                }
            }
        }
        
        await scanTask?.value
    }
    
    private func syncHardware(sessionID: String, hardwareID: String) async {
        guard !sessionID.isEmpty else {
            statusMessage = "Please select a session first"
            statusIsError = true
            return
        }
        
        isLoading = true
        isSyncing = true
        syncProgress = 0.0
        syncStatus = .scanning
        
        syncTask = Task {
            let callback = ToastSyncCallback(
                onToast: { message, isError in
                    DispatchQueue.main.async {
                        self.hardwareToastMessage = message
                        self.hardwareToastIsError = isError
                        self.showHardwareToast = true
                    }
                },
                onProgress: { progress, status in
                    DispatchQueue.main.async {
                        self.syncProgress = progress
                        self.syncStatus = status
                    }
                }
            )
            
            do {
                // Synchronize the hardware device with the specified session
                try await akiles.sync(
                    sessionID: sessionID,
                    hardwareID: hardwareID,
                    callback: callback
                )
                
                DispatchQueue.main.async {
                    self.statusMessage = "Sync completed for hardware: \(hardwareID)"
                    self.statusIsError = false
                    self.showHardwareToast(message: "Hardware sync completed successfully!", isError: false)
                    self.isLoading = false
                    self.isSyncing = false
                    self.syncProgress = 0.0
                    self.syncTask = nil
                }
            } catch {
                DispatchQueue.main.async {
                    if !Task.isCancelled {
                        self.statusMessage = "Error syncing hardware: \(error.localizedDescription)"
                        self.statusIsError = true
                        self.showHardwareToast(message: "Hardware sync failed", isError: true)
                    } else {
                        self.statusMessage = "Sync cancelled"
                        self.statusIsError = false
                        self.showHardwareToast(message: "Hardware sync cancelled", isError: false)
                    }
                    self.isLoading = false
                    self.isSyncing = false
                    self.syncProgress = 0.0
                    self.syncTask = nil
                }
            }
        }
        
        await syncTask?.value
    }
    
    private func scanNFCCard() async {
        isCardScanning = true
        statusMessage = "Scanning for NFC card..."

        do {
            // Scan for NFC cards using the device's NFC reader
            scannedCard = try await akiles.scanCard()
            statusMessage = "NFC card scanned successfully"
            statusIsError = false
            showCardModal = true
        } catch {
            statusMessage = "Error scanning NFC card: \(error.localizedDescription)"
            statusIsError = true
            showNfcToast(message: "Failed to scan NFC card", isError: true)
        }
        
        isCardScanning = false
    }
    
    private func updateCard() async {
        guard let card = scannedCard else { return }
        
        isCardUpdating = true
        
        do {
            // Update the NFC card to make it compatible with Akiles systems
            try await card.update()
            statusMessage = "Card updated successfully"
            statusIsError = false
            showNfcToast(message: "Card updated successfully!", isError: false)
            showCardModal = false
            scannedCard = nil
        } catch {
            statusMessage = "Error updating card: \(error.localizedDescription)"
            statusIsError = true
            showNfcToast(message: "Failed to update card", isError: true)
        }
        
        isCardUpdating = false
    }
    
    private func showHardwareToast(message: String, isError: Bool) {
        hardwareToastMessage = message
        hardwareToastIsError = isError
        showHardwareToast = true
    }
    
    private func showNfcToast(message: String, isError: Bool) {
        nfcToastMessage = message
        nfcToastIsError = isError
        showNfcToast = true
    }
    
    // MARK: - Cancellation Functions
    
    private func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        isScanning = false
        statusMessage = "Scan cancelled"
        statusIsError = false
    }
    
    private func cancelSync() {
        syncTask?.cancel()
        syncTask = nil
        isSyncing = false
        isLoading = false
        syncProgress = 0.0
        statusMessage = "Sync cancelled"
        statusIsError = false
    }
    
    private func cancelAction() {
        actionTask?.cancel()
        actionTask = nil
        isLoading = false
        gadgetToastMessage = "Action cancelled"
        gadgetToastIsError = false
        showGadgetToast = true
    }
}

#Preview {
    ContentView(akiles: Akiles())
}
