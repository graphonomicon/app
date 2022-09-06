import AppKit
import Coffee
import Combine
import MetalKit

final class Content: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .white
        
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let view = Miew2(device: device)
        else { return }
        addSubview(view)
    }
}
