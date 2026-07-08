//
//  EntryBrowser.swift
//

#if DEBUG
import SwiftUI
import SMIClientCore
import CoreData

struct EntryBrowser: View {
    static let title = "Entry Browser"

    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()

    @State private var entries: [any ConversationEntry] = []
    @State private var cleanState: [String: Bool] = [:]
    @State private var isFetching = false
    @State private var toast: Toast?
    @State private var selectedEntries: Set<String> = []
    @State private var isSelecting = false
    @State private var hasLoaded = false

    var body: some View {
        List {
            Section(header: Text("Actions")) {
                SettingsButton {
                    fetchEntries(behaviour: .localOnly)
                } label: {
                    Text("Load Local Entries")
                }

                SettingsButton {
                    fetchEntries(behaviour: .waitForNetwork)
                } label: {
                    Text("Fetch From Server")
                }

                SettingsButton {
                    deleteAllEntries()
                } label: {
                    Text("Delete All Entries")
                        .foregroundColor(.red)
                }

                SettingsButton {
                    deleteAndRefetch()
                } label: {
                    Text("Delete All & Re-fetch")
                        .foregroundColor(.orange)
                }

                if isSelecting && !selectedEntries.isEmpty {
                    SettingsButton {
                        markSelectedUnclean()
                    } label: {
                        Text("Mark Selected Unclean (\(selectedEntries.count))")
                            .foregroundColor(.orange)
                    }

                    SettingsButton {
                        markSelectedClean()
                    } label: {
                        Text("Mark Selected Clean (\(selectedEntries.count))")
                            .foregroundColor(.green)
                    }
                }

                SettingsButton {
                    markAllUnclean()
                } label: {
                    Text("Mark All Unclean")
                        .foregroundColor(.orange)
                }
            }

            Section(header: Text("Info")) {
                LabelledText("Conversation", text: configStore.conversationId, lineLimit: 1)
                LabelledText("Entry Count", text: "\(entries.count)", lineLimit: 1)

                let cleanCount = cleanState.values.filter { $0 }.count
                let uncleanCount = cleanState.values.filter { !$0 }.count
                LabelledText("Clean / Unclean", text: "\(cleanCount) / \(uncleanCount)", lineLimit: 1)

                if isFetching {
                    HStack {
                        ProgressView()
                        Text("Loading...")
                            .foregroundColor(.secondary)
                    }
                }
            }

            if !entries.isEmpty {
                Section(header: entryListHeader) {
                    ForEach(entries, id: \.identifier) { entry in
                        EntryRow(entry: entry,
                                 isClean: cleanState[entry.identifier] ?? true,
                                 isSelected: selectedEntries.contains(entry.identifier),
                                 isSelecting: isSelecting)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isSelecting {
                                    toggleSelection(entry.identifier)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    markEntryUnclean(entry)
                                } label: {
                                    Label("Unclean", systemImage: "xmark.circle")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    markEntryClean(entry)
                                } label: {
                                    Label("Clean", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            }
                    }
                }
            }
        }
        .navigationTitle(Self.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isSelecting ? "Done" : "Select") {
                    isSelecting.toggle()
                    if !isSelecting {
                        selectedEntries.removeAll()
                    }
                }
            }
        }
        .toastView(toast: $toast)
        .onAppear {
            guard !hasLoaded else { return }
            hasLoaded = true
            fetchEntries(behaviour: .localOnly)
        }
    }

    private var entryListHeader: some View {
        HStack {
            Text("Entries (\(entries.count))")
            Spacer()
            if isSelecting {
                Button(selectedEntries.count == entries.count ? "Deselect All" : "Select All") {
                    if selectedEntries.count == entries.count {
                        selectedEntries.removeAll()
                    } else {
                        selectedEntries = Set(entries.map { $0.identifier })
                    }
                }
                .font(.caption)
            }
        }
    }

    // MARK: - Data Operations

    private func fetchEntries(behaviour: QueryBehaviour) {
        isFetching = true
        let conversationId = configStore.conversationUUID
        let client = CoreFactory.create(withConfig: configStore.config).conversationClient(with: conversationId)

        client.entries(withLimit: 200,
                       fromTimestamp: nil,
                       direction: .descending,
                       behaviour: behaviour) { fetchedEntries, _, error in
            DispatchQueue.main.async {
                isFetching = false
                if let error = error {
                    toast = Toast(style: .error, message: "Error: \(error.localizedDescription)", width: 320)
                    return
                }
                let fetched = fetchedEntries ?? []
                var seen = Set<String>()
                entries = fetched.filter { seen.insert($0.identifier).inserted }
                refreshCleanState()
                toast = Toast(style: .success, message: "Loaded \(entries.count) entries", width: 280)
            }
        }
    }

    private func deleteAllEntries() {
        let conversationId = configStore.conversationUUID
        let client = CoreFactory.create(withConfig: configStore.config).conversationClient(with: conversationId)

        // NOTE: The SDK's deleteEntries completion handler has a known bug where
        // the completion block is never called. We fire-and-forget and update UI
        // optimistically after a short delay.
        client.deleteEntries { _ in }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            entries.removeAll()
            selectedEntries.removeAll()
            cleanState.removeAll()
            toast = Toast(style: .success, message: "All entries deleted", width: 280)
        }
    }

    private func deleteAndRefetch() {
        let conversationId = configStore.conversationUUID
        let client = CoreFactory.create(withConfig: configStore.config).conversationClient(with: conversationId)

        isFetching = true

        // NOTE: The SDK's deleteEntries completion handler has a known bug where
        // the completion block is never called. We work around this by firing the
        // delete and then fetching after a short delay to allow the delete to complete.
        client.deleteEntries { _ in }

        DispatchQueue.main.async {
            entries.removeAll()
            selectedEntries.removeAll()
            cleanState.removeAll()
        }

        // Give the delete operation time to complete before re-fetching
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            client.entries(withLimit: 200,
                           fromTimestamp: nil,
                           direction: .descending,
                           behaviour: .waitForNetwork) { fetchedEntries, _, fetchError in
                DispatchQueue.main.async {
                    isFetching = false
                    if let fetchError = fetchError {
                        toast = Toast(style: .warning,
                                      message: "Deleted but re-fetch failed: \(fetchError.localizedDescription)",
                                      width: 320)
                        return
                    }
                    entries = fetchedEntries ?? []
                    refreshCleanState()
                    toast = Toast(style: .success,
                                  message: "Re-fetched \(entries.count) entries from server",
                                  width: 320)
                }
            }
        }
    }

    // MARK: - Individual Delete

    private func deleteEntry(_ entry: any ConversationEntry) {
        guard let entryObject = entry as? NSObject,
              let managedObject = (entryObject as NSObject).value(forKey: "managedObject") as? NSManagedObject,
              let context = managedObject.managedObjectContext else {
            toast = Toast(style: .error, message: "Failed to delete entry", width: 240)
            return
        }

        context.performAndWait {
            context.delete(managedObject)
            do {
                try context.save()
            } catch {
                print("[EntryBrowser] Failed to save context after delete: \(error)")
            }
        }

        entries.removeAll { $0.identifier == entry.identifier }
        cleanState.removeValue(forKey: entry.identifier)
        selectedEntries.remove(entry.identifier)
        toast = Toast(style: .success, message: "Entry deleted", width: 200)
    }

    // MARK: - Clean/Unclean Operations

    /// Uses KVC to access the internal managed object backing a ConversationEntry
    /// and set its `clean` flag. This works because:
    /// - ConversationEntry protocol objects are NSObject subclasses (SMIConversationEntry)
    /// - SMIConversationEntry has an internal `managedObject` property (SMIConversationEntryMO)
    /// - SMIConversationEntryMO is an NSManagedObject with a `clean` BOOL attribute
    private func setCleanFlag(_ clean: Bool, on entry: any ConversationEntry) -> Bool {
        // Cast to NSObject to disambiguate value(forKey:) from SMITemplateable
        guard let entryObject = entry as? NSObject else {
            return false
        }

        // Get the internal managed object via KVC
        guard let managedObject = (entryObject as NSObject).value(forKey: "managedObject") as? NSManagedObject else {
            return false
        }

        guard let context = managedObject.managedObjectContext else {
            return false
        }

        var success = false
        context.performAndWait {
            managedObject.setValue(clean, forKey: "clean")
            do {
                try context.save()
                success = true
            } catch {
                print("[EntryBrowser] Failed to save context: \(error)")
            }
        }
        return success
    }

    private func readCleanFlag(on entry: any ConversationEntry) -> Bool? {
        // Cast to NSObject to disambiguate value(forKey:) from SMITemplateable
        guard let entryObject = entry as? NSObject else {
            return nil
        }

        guard let managedObject = (entryObject as NSObject).value(forKey: "managedObject") as? NSManagedObject else {
            return nil
        }

        var result: Bool?
        managedObject.managedObjectContext?.performAndWait {
            result = managedObject.value(forKey: "clean") as? Bool
        }
        return result
    }

    private func refreshCleanState() {
        var newState: [String: Bool] = [:]
        for entry in entries {
            if let isClean = readCleanFlag(on: entry) {
                newState[entry.identifier] = isClean
            }
        }
        cleanState = newState
    }

    private func markEntryUnclean(_ entry: any ConversationEntry) {
        if setCleanFlag(false, on: entry) {
            cleanState[entry.identifier] = false
            toast = Toast(style: .success, message: "Marked unclean", width: 200)
        } else {
            toast = Toast(style: .error, message: "Failed to mark unclean", width: 240)
        }
    }

    private func markEntryClean(_ entry: any ConversationEntry) {
        if setCleanFlag(true, on: entry) {
            cleanState[entry.identifier] = true
            toast = Toast(style: .success, message: "Marked clean", width: 200)
        } else {
            toast = Toast(style: .error, message: "Failed to mark clean", width: 240)
        }
    }

    private func markSelectedUnclean() {
        var count = 0
        for entry in entries where selectedEntries.contains(entry.identifier) {
            if setCleanFlag(false, on: entry) {
                cleanState[entry.identifier] = false
                count += 1
            }
        }
        toast = Toast(style: .success, message: "Marked \(count) entries unclean", width: 280)
    }

    private func markSelectedClean() {
        var count = 0
        for entry in entries where selectedEntries.contains(entry.identifier) {
            if setCleanFlag(true, on: entry) {
                cleanState[entry.identifier] = true
                count += 1
            }
        }
        toast = Toast(style: .success, message: "Marked \(count) entries clean", width: 280)
    }

    private func markAllUnclean() {
        var count = 0
        for entry in entries {
            if setCleanFlag(false, on: entry) {
                cleanState[entry.identifier] = false
                count += 1
            }
        }
        toast = Toast(style: .success, message: "Marked \(count) entries unclean", width: 280)
    }

    private func toggleSelection(_ identifier: String) {
        if selectedEntries.contains(identifier) {
            selectedEntries.remove(identifier)
        } else {
            selectedEntries.insert(identifier)
        }
    }
}

// MARK: - Entry Row View

private struct EntryRow: View {
    let entry: any ConversationEntry
    let isClean: Bool
    let isSelected: Bool
    let isSelecting: Bool

    var body: some View {
        HStack {
            if isSelecting {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }

            // Clean/Unclean indicator
            Circle()
                .fill(isClean ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entryTypeLabel)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(entryTypeColor.opacity(0.2))
                        .foregroundColor(entryTypeColor)
                        .cornerRadius(4)

                    if !isClean {
                        Text("UNCLEAN")
                            .font(.system(.caption2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }

                    Spacer()

                    Text(statusLabel)
                        .font(.caption2)
                        .foregroundColor(statusColor)
                }

                Text(entry.senderDisplayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let payload = entry.payload as? TextMessage {
                    Text(payload.text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Text(entry.identifier)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    Text(entry.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(isClean ? Color.clear : Color.orange.opacity(0.05))
    }

    private var entryTypeLabel: String {
        switch entry.type {
        case ConversationEntryTypes.message, ConversationEntryTypes.messageUpdated:
            return "MSG"
        case ConversationEntryTypes.typingIndicator:
            return "TYP"
        case ConversationEntryTypes.participantChanged:
            return "PRT"
        case ConversationEntryTypes.routingWorkResult, ConversationEntryTypes.routingResult:
            return "RTE"
        case ConversationEntryTypes.sessionStatusChanged:
            return "SES"
        case ConversationEntryTypes.choice, ConversationEntryTypes.selection:
            return "CHC"
        case ConversationEntryTypes.readAck, ConversationEntryTypes.deliveryAck:
            return "ACK"
        case ConversationEntryTypes.closeConversation:
            return "CLS"
        case ConversationEntryTypes.streamingToken:
            return "STR"
        default:
            return "OTR"
        }
    }

    private var entryTypeColor: Color {
        switch entry.type {
        case ConversationEntryTypes.message, ConversationEntryTypes.messageUpdated:
            return .blue
        case ConversationEntryTypes.typingIndicator:
            return .gray
        case ConversationEntryTypes.participantChanged:
            return .green
        case ConversationEntryTypes.routingWorkResult, ConversationEntryTypes.routingResult:
            return .purple
        case ConversationEntryTypes.sessionStatusChanged, ConversationEntryTypes.closeConversation:
            return .orange
        case ConversationEntryTypes.choice, ConversationEntryTypes.selection:
            return .teal
        case ConversationEntryTypes.readAck, ConversationEntryTypes.deliveryAck:
            return .indigo
        default:
            return .secondary
        }
    }

    private var statusLabel: String {
        switch entry.status {
        case .error:
            return "Error"
        case .sending:
            return "Sending"
        case .sent:
            return "Sent"
        case .delivered:
            return "Delivered"
        case .read:
            return "Read"
        default:
            return entry.status.rawValue
        }
    }

    private var statusColor: Color {
        switch entry.status {
        case ConversationEntryStatus.error:
            return .red
        case ConversationEntryStatus.sending:
            return .orange
        case ConversationEntryStatus.sent:
            return .blue
        case ConversationEntryStatus.delivered:
            return .green
        case ConversationEntryStatus.read:
            return .green
        default:
            return .secondary
        }
    }
}

#Preview {
    WrappedNavigationStack {
        EntryBrowser()
    }
}
#endif
