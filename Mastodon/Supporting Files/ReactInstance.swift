import Foundation
import ReactNativeHost

final class ReactInstance: NSObject, RNXHostConfig {
    static func jsBundleURL() -> URL? {
        RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index") { nil }
    }

    var remoteBundleURL: URL? {
        didSet {
            initReact(bundleRoot: bundleRoot, onDidInitialize: { /* noop */ })
        }
    }

    private(set) var host: ReactNativeHost?
    private var bundleRoot: String?

    override init() {
        #if DEBUG
        remoteBundleURL = ReactInstance.jsBundleURL()
        #endif

        super.init()

        #if USE_TURBOMODULE
        RCTEnableTurboModule(true)
        #endif
    }

    init(forTestingPurposesOnly: Bool) {
        assert(forTestingPurposesOnly)
    }

    func initReact(bundleRoot: String?, onDidInitialize: @escaping () -> Void) {
        if host != nil {
            if remoteBundleURL == nil {
                // When loading the embedded bundle, we must disable remote
                // debugging to prevent the bridge from getting stuck in
                // -[RCTWebSocketExecutor executeApplicationScript:sourceURL:onComplete:]
                RCTDevSettings().isDebuggingRemotely = false
            }
            return
        }

        self.bundleRoot = bundleRoot

        let reactNativeHost = ReactNativeHost(self)
        host = reactNativeHost

        onDidInitialize()
    }

    // MARK: - RNXHostConfig details

    func onFatalError(_ error: Error) {
        guard let nsError = error as NSError? else {
            print(error.localizedDescription)
            return
        }

        let message = RCTFormatError(
            nsError.localizedDescription,
            nsError.userInfo[RCTJSStackTraceKey] as? [[String: Any]],
            9001
        )
        print(message ?? nsError.localizedDescription)
    }

    // MARK: - RCTBridgeDelegate details

    func sourceURL(for _: RCTBridge!) -> URL? {
        if let remoteBundleURL = remoteBundleURL {
            return remoteBundleURL
        }

        let embeddedBundleURL = entryFiles()
            .lazy
            .map {
                Bundle.main.url(
                    forResource: $0,
                    withExtension: "jsbundle"
                )
            }
            .first(where: { $0 != nil })
        return embeddedBundleURL ?? ReactInstance.jsBundleURL()
    }

    // MARK: - Private

    private func entryFiles() -> [String] {
        #if os(iOS)
        let extensions = [".ios", ".mobile", ".native", ""]
        #elseif os(macOS)
        let extensions = [".macos", ".native", ""]
        #endif

        guard let bundleRoot = bundleRoot else {
            return extensions.reduce(into: []) { files, ext in
                files.append("index" + ext)
                files.append("main" + ext)
            }
        }

        return extensions.map { bundleRoot + $0 }
    }

    @objc
    private func onRemoteBundleURLReceived(_ notification: Notification) {
        guard var urlComponents = notification.userInfo?["url"] as? URLComponents else {
            return
        }

        urlComponents.queryItems = [URLQueryItem(name: "platform", value: "ios")]
        remoteBundleURL = urlComponents.url
    }
}

func createReactRootView(_ reactInstance: ReactInstance, componentName: String, initialProperties: [AnyHashable: Any]?) -> UIView? {
    reactInstance.initReact(bundleRoot: "index") {}
    guard let host = reactInstance.host else {
        assertionFailure("Failed to initialize ReactNativeHost")
        return nil
    }
    
    let view = host.view(
        moduleName: componentName,
        initialProperties: initialProperties
    )
    return view
}
