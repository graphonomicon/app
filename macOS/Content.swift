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
        layer!.backgroundColor = .white
        wantsLayer = true

        timer
            .sink { [weak self] _ in
                self?.layer!.setNeedsDisplay()
            }
            .store(in: &subs)
    }
    
    override func scrollWheel(with event: NSEvent) {
        model.zoom += event.deltaY / 300
        
        if event.deltaY >= 0 {
            if event.locationInWindow.x > bounds.midX {
                model.origin.x -= 2
            } else {
                model.origin.x += 2
            }
            
            if event.locationInWindow.y > bounds.midY {
                model.origin.y -= 2
            } else {
                model.origin.y += 2
            }
        } else {
            if model.origin.x > 0 {
                model.origin.x -= min(2, model.origin.x)
            } else if model.origin.x < 0 {
                model.origin.x += max(-2, model.origin.x)
            }
            
            if model.origin.y > 0 {
                model.origin.y -= min(2, model.origin.y)
            } else if model.origin.y < 0 {
                model.origin.y += max(2, -model.origin.y)
            }
        }
    }
}
