import SwiftUI
import SpriteKit
import Combine

struct FireworksView: View {
    var color: SKColor

    var body: some View {
        GeometryReader { geometry in
            SpriteView(
                scene: FireworksScene(size: geometry.size, color: color),
                options: .allowsTransparency
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

final class FireworksScene: SKScene {
    var color: SKColor
    var animationTimerCancellable: Cancellable?

    init(size: CGSize, color: SKColor) {
        self.color = color
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.allowsTransparency = true

        animationTimerCancellable = Timer.publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard
                    let self = self,
                    let fireworks = SKEmitterNode(fileNamed: "Fireworks.sks")
                else { return }

                self.removeAllChildren()

                let randomPosition = CGPoint(
                    x: CGFloat.random(in: 0..<view.frame.maxX),
                    y: CGFloat.random(in: 0..<view.frame.maxY)
                )
                fireworks.position = randomPosition
                fireworks.isUserInteractionEnabled = false
                fireworks.particleColor = self.color
                fireworks.particleColorSequence = nil
                self.addChild(fireworks)
            }
    }

    deinit {
        animationTimerCancellable?.cancel()
    }
}
