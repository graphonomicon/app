import AppKit
import Coffee

final class Window: NSWindow {
    init(session: Session) {
        super.init(contentRect: .init(x: 0,
                                      y: 0,
                                      width: 800,
                                      height: 800),
                   styleMask: [.closable, .titled, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)
        minSize = .init(width: 800, height: 800)
        center()
        toolbar = .init()
        isReleasedWhenClosed = false
        collectionBehavior = .fullScreenNone
        tabbingMode = .disallowed
        titlebarAppearsTransparent = true
        
//        let scroll = Scroll()
//        scroll.contentView.postsBoundsChangedNotifications = false
//        scroll.contentView.postsFrameChangedNotifications = false
//        scroll.backgroundColor = .white
////        scroll.drawsBackground = true
//        scroll.hasHorizontalScroller = true
//        scroll.horizontalScroller!.controlSize = .mini
//        scroll.maxMagnification = 2
//        scroll.minMagnification = 0.01
//        scroll.allowsMagnification = true
//        contentView!.addSubview(scroll)
        
        let content = Content(session: session)
        contentView!.addSubview(content)
        
//        scroll.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
//        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
//        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
//        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
//        
//        scroll.documentView!.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        content.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        content.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        content.widthAnchor.constraint(equalToConstant: 800).isActive = true
        content.heightAnchor.constraint(equalToConstant: 800).isActive = true
    }
    
    override func close() {
        super.close()
        NSApp.terminate(nil)
    }
}
