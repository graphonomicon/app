import AppKit

final class Window: NSWindow {
    init(session: Session) {
        super.init(contentRect: .init(x: 0,
                                      y: 0,
                                      width: 800,
                                      height: 800),
                   styleMask: [.closable, .miniaturizable, .resizable, .titled, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)
        minSize = .init(width: 800, height: 800)
        center()
        toolbar = .init()
        isReleasedWhenClosed = false
        collectionBehavior = .fullScreenNone
        setFrameAutosaveName("Window")
        tabbingMode = .disallowed
        titlebarAppearsTransparent = true
        
        let bar = NSTitlebarAccessoryViewController()
        bar.view = NSView()
        bar.layoutAttribute = .top
        addTitlebarAccessoryViewController(bar)
        
        let content = Content(session: session)
        contentView!.addSubview(content)
        
        content.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    override func close() {
        super.close()
        NSApp.terminate(nil)
    }
}
