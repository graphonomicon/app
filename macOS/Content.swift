import AppKit
import Coffee
import Combine

final class Content: NSView {
    private var subs = Set<AnyCancellable>()
    private let model = Layer.Model()
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer = Layer(model: model)
        wantsLayer = true

        timer
            .sink { [weak self] _ in
                self?.layer!.setNeedsDisplay()
            }
            .store(in: &subs)
        
        model.origin = .init(x: 400, y: 400)
    }
    
    override func magnify(with event: NSEvent) {
        super.magnify(with: event)
        model.zoom = max(min(25, model.zoom * (1 + event.magnification)), 0.1)
        
        if model.zoom <= 1 {
            model.origin = .init(x: bounds.midX, y: bounds.midY)
        } else {
            if event.magnification <= 0 {
                model.origin.x += (model.origin.x - bounds.midX) / -50
                model.origin.y += (model.origin.y - bounds.midY) / -50
            } else {
                model.origin.x += (bounds.midX - event.locationInWindow.x) / 50
                model.origin.y += (bounds.midY - event.locationInWindow.y) / 50
            }
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        if model.zoom > 1 {
            model.origin.x += event.deltaX
            model.origin.y -= event.deltaY
        }
    }
}
