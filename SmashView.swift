import SwiftUI
import SpriteKit

struct SmashView: View {
    // MARK: - LOCAL STATE (No Core Data)
    @State private var demotivatingWords: [String] = []
    @State private var currentInput: String = ""
    
    // Game State
    @State private var isPlayingGame = false
    @State private var isBreathing = false
    
    // Create the SpriteKit Scene
    var scene: SKScene {
        let scene = SmashHitScene()
        // Use the local array
        scene.wordsToShatter = demotivatingWords.isEmpty ? ["DOUBT", "FEAR", "LAZY"] : demotivatingWords
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .black
        
        // Callback: When game is won, clear the list
        scene.onGameWon = {
            clearAllWords()
        }
        return scene
    }

    var body: some View {
        ZStack {
            // Consistent Dark Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            if isPlayingGame {
                // MARK: - PHASE 2: THE GAME
                ZStack {
                    SpriteView(scene: scene)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.scale(scale: 1.5).combined(with: .opacity))
                    
                    VStack {
                        HStack {
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isPlayingGame = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding()
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            } else {
                // MARK: - PHASE 1: THE INPUT FORM
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("MENTAL BLOCKS")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                            .tracking(2)
                        
                        Text("What is stopping you?")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 60)
                    
                    // Glass Input Field
                    HStack {
                        TextField("e.g. Fear of failure", text: $currentInput)
                            .foregroundColor(.white)
                            .accentColor(.cyan)
                            .padding()
                            .submitLabel(.done)
                            .onSubmit { addWord() }
                        
                        Button(action: addWord) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.cyan)
                                .shadow(color: .cyan.opacity(0.5), radius: 10)
                        }
                        .padding(.trailing, 5)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Glass Chips List (Using Local Array)
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(demotivatingWords, id: \.self) { word in
                                HStack {
                                    Text(word.uppercased())
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Spacer()
                                    
                                    Button(action: { deleteWord(word) }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundColor(.white.opacity(0.5))
                                            .padding(8)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                )
                                .transition(.scale)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // The "Tech Glass" Button
                    if !demotivatingWords.isEmpty {
                        Button(action: triggerCinematicTransition) {
                            HStack(spacing: 10) {
                                Image(systemName: "hammer.fill")
                                Text("SHATTER DOUBTS")
                                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .background(
                                LinearGradient(colors: [Color.cyan.opacity(0.4), Color.blue.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: isBreathing ? 20 : 5)
                            .scaleEffect(isBreathing ? 1.02 : 1.0)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 110) // Padding for Tab Bar
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                isBreathing = true
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
    }
    
    // MARK: - Local Logic (No Core Data)
    func addWord() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !demotivatingWords.contains(trimmed) {
            withAnimation {
                demotivatingWords.insert(trimmed, at: 0)
                currentInput = ""
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func deleteWord(_ word: String) {
        withAnimation {
            demotivatingWords.removeAll { $0 == word }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
    
    func clearAllWords() {
        demotivatingWords.removeAll()
    }
    
    func triggerCinematicTransition() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        withAnimation(.easeInOut(duration: 0.8)) {
            isPlayingGame = true
        }
    }
}

// MARK: - SPRITEKIT SCENE (Unchanged)
class SmashHitScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    var wordsToShatter: [String] = []
    var onGameWon: (() -> Void)? // Callback to clear list
    
    let ballCategory: UInt32 = 0x1 << 0
    let glassCategory: UInt32 = 0x1 << 1
    
    var glassCount = 0
    var motivationLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.5)
        physicsWorld.contactDelegate = self
        
        createMotivationBackground()
        
        let spacing: CGFloat = 100
        let startY = CGFloat(wordsToShatter.count - 1) * (spacing / 2)
        
        for (index, word) in wordsToShatter.enumerated() {
            let randomX = CGFloat.random(in: -70...70)
            let yPos = startY - (CGFloat(index) * spacing)
            spawnGlassPane(text: word.uppercased(), position: CGPoint(x: randomX, y: yPos))
        }
    }
    
    func createMotivationBackground() {
        motivationLabel = SKLabelNode(text: "MIND CLEARED.")
        motivationLabel.fontName = "AvenirNext-Heavy"
        motivationLabel.fontSize = 35
        motivationLabel.fontColor = .green
        motivationLabel.position = CGPoint(x: 0, y: 0)
        motivationLabel.zPosition = -10
        motivationLabel.alpha = 0.0
        addChild(motivationLabel)
    }
    
    func spawnGlassPane(text: String, position: CGPoint) {
        glassCount += 1
        let width = max(150.0, CGFloat(text.count * 18))
        let glass = SKShapeNode(rectOf: CGSize(width: width, height: 60), cornerRadius: 8)
        glass.fillColor = UIColor.cyan.withAlphaComponent(0.15)
        glass.strokeColor = UIColor.white.withAlphaComponent(0.6)
        glass.lineWidth = 2
        glass.position = position
        
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        glass.addChild(label)
        
        glass.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: 60))
        glass.physicsBody?.isDynamic = false
        glass.physicsBody?.categoryBitMask = glassCategory
        glass.physicsBody?.contactTestBitMask = ballCategory
        addChild(glass)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        shootBall(towards: touch.location(in: self))
    }
    
    func shootBall(towards target: CGPoint) {
        let ball = SKShapeNode(circleOfRadius: 10)
        ball.fillColor = .white
        ball.strokeColor = .lightGray
        ball.lineWidth = 2
        let startPoint = CGPoint(x: 0, y: -size.height / 2 + 50)
        ball.position = startPoint
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.mass = 4.0
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = glassCategory
        addChild(ball)
        
        let dx = target.x - startPoint.x
        let dy = target.y - startPoint.y
        let angle = atan2(dy, dx)
        let speed: CGFloat = 7000.0
        ball.physicsBody?.applyForce(CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var glassBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask == glassCategory { glassBody = contact.bodyA }
        else if contact.bodyB.categoryBitMask == glassCategory { glassBody = contact.bodyB }
        else { return }
        if let glassNode = glassBody.node { shatter(node: glassNode, impactPoint: contact.contactPoint) }
    }
    
    func shatter(node: SKNode, impactPoint: CGPoint) {
        node.removeFromParent()
        glassCount -= 1
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Visual FX
        let flash = SKShapeNode(rectOf: size)
        flash.fillColor = .white
        flash.zPosition = 100
        flash.alpha = 0.8
        addChild(flash)
        flash.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.removeFromParent()]))

        for _ in 0..<25 { spawnShard(at: node.position, impactPoint: impactPoint) }
        
        if glassCount <= 0 { triggerWin() }
    }
    
    func spawnShard(at origin: CGPoint, impactPoint: CGPoint) {
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: 10...40)))
        path.addLine(to: CGPoint(x: CGFloat.random(in: 10...30), y: CGFloat.random(in: -10...10)))
        path.closeSubpath()
        
        let shard = SKShapeNode(path: path)
        shard.fillColor = UIColor.cyan.withAlphaComponent(0.3)
        shard.strokeColor = UIColor.white.withAlphaComponent(0.8)
        shard.lineWidth = 1
        shard.position = CGPoint(x: origin.x + CGFloat.random(in: -50...50), y: origin.y + CGFloat.random(in: -20...20))
        shard.physicsBody = SKPhysicsBody(polygonFrom: path)
        shard.physicsBody?.isDynamic = true
        shard.physicsBody?.mass = 0.1
        addChild(shard)
        
        let push = CGVector(dx: (shard.position.x - impactPoint.x) * 2.5, dy: (shard.position.y - impactPoint.y) * 2.5)
        shard.physicsBody?.applyImpulse(push)
        shard.physicsBody?.applyAngularImpulse(CGFloat.random(in: -0.1...0.1))
        shard.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.fadeOut(withDuration: 0.6), SKAction.removeFromParent()]))
    }
    
    func triggerWin() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        motivationLabel.run(SKAction.group([
            SKAction.fadeAlpha(to: 1.0, duration: 1.0),
            SKAction.scale(to: 1.2, duration: 1.0)
        ]))
        
        // Trigger callback to SwiftUI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onGameWon?()
        }
    }
}
