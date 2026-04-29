import Foundation
import Network

// Sends search results to any TCP client (glasses companion app) on port 8081.
// Protocol: newline-delimited JSON with type "search_result" | "clear"
@MainActor
final class GlassesDisplayServer: ObservableObject {
    @Published private(set) var clientCount: Int = 0
    @Published private(set) var localIP: String? = nil

    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let port: NWEndpoint.Port = 8081

    func start() {
        localIP = resolveLocalIP()
        guard listener == nil else { return }
        guard let l = try? NWListener(using: .tcp, on: port) else { return }
        listener = l
        l.stateUpdateHandler = { _ in }
        l.newConnectionHandler = { [weak self] conn in
            Task { @MainActor in self?.accept(conn) }
        }
        l.start(queue: .main)
    }

    func stop() {
        listener?.cancel()
        listener = nil
        connections.forEach { $0.cancel() }
        connections.removeAll()
        clientCount = 0
    }

    func sendResult(query: String, answer: String, source: String) {
        let payload: [String: Any] = [
            "type": "search_result",
            "query": query,
            "answer": answer,
            "source": source,
        ]
        send(payload)
    }

    func sendClear() {
        send(["type": "clear"])
    }

    private func send(_ payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8) else { return }
        let frame = (json + "\n").data(using: .utf8)!
        connections.forEach { $0.send(content: frame, completion: .idempotent) }
    }

    private func accept(_ conn: NWConnection) {
        connections.append(conn)
        clientCount = connections.count
        conn.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                if case .cancelled = state { self?.remove(conn) }
                if case .failed = state { self?.remove(conn) }
            }
        }
        conn.start(queue: .main)
    }

    private func remove(_ conn: NWConnection) {
        connections.removeAll { $0 === conn }
        clientCount = connections.count
    }

    private func resolveLocalIP() -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }
        var ptr = ifaddr
        while let cur = ptr {
            let addr = cur.pointee
            if addr.ifa_addr.pointee.sa_family == UInt8(AF_INET),
               String(cString: addr.ifa_name) == "en0" {
                var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(addr.ifa_addr, socklen_t(addr.ifa_addr.pointee.sa_len),
                            &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
                return String(cString: host)
            }
            ptr = addr.ifa_next
        }
        return nil
    }
}
