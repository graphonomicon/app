import AppKit

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    private let session = Session()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
    func applicationWillFinishLaunching(_: Notification) {
//        mainMenu = Menu(session: session)
    }
    
    func applicationDidFinishLaunching(_: Notification) {
        registerForRemoteNotifications()
        Window(session: session).makeKeyAndOrderFront(nil)
        
//        Task
//            .detached {
//                await self.session.store.launch()
//            }
    }
    
    func applicationDidBecomeActive(_: Notification) {
//        if session.loading.value {
//            session.cloud.ready.notify(queue: .main) {
//                self.session.loading.value = false
//
//                Task {
//                    if await self.session.cloud.model.preferences.providers.isEmpty {
//                        self.showPreferencesWindow(nil)
//                    }
//
//                    await self.session.cloud.fetch()
//                }
//
//                Defaults.start()
//            }
//        } else {
//            session.cloud.pull.send()
//
//            Task {
//                await session.cloud.fetch()
//            }
//        }
    }
    
    func application(_: NSApplication, didReceiveRemoteNotification: [String : Any]) {
//        session.cloud.pull.send()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
    
    func anyWindow<T>() -> T? {
        windows
            .compactMap {
                $0 as? T
            }
            .first
    }
    
//    override func orderFrontStandardAboutPanel(_ sender: Any?) {
//        (anyWindow() ?? About())
//            .makeKeyAndOrderFront(nil)
//    }
//    
//    @objc func showPreferencesWindow(_ sender: Any?) {
//        (anyWindow() ?? Preferences(session: session))
//            .makeKeyAndOrderFront(nil)
//    }
//    
//    @objc func showSponsor(_ sender: Any?) {
//        (anyWindow() ?? Sponsor(session: session))
//            .makeKeyAndOrderFront(nil)
//    }
}
