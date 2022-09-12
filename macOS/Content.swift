import AppKit
import Coffee
import Combine

final class Content: NSView {
    private var subs = Set<AnyCancellable>()
    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer = Layer()
        wantsLayer = true

        timer
            .sink { [weak self] _ in
                self?.layer!.setNeedsDisplay()
            }
            .store(in: &subs)
    }
}
