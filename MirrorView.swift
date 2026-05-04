//
//  MirrorView.swift
//  Jolt
//
//  Created by user@5 on 19/02/26.
//
import SwiftUI
import ARKit
import SceneKit

struct MirrorView: View {
    @State private var message = "Look into your eyes..."
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // The AR Camera Feed
            ARViewContainer(message: $message)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8) // Make it look moody
            
            VStack {
                Spacer()
                Text(message)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
    }
}

// The Bridge between SwiftUI and ARKit
struct ARViewContainer: UIViewRepresentable {
    @Binding var message: String
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        
        // Check if Face Tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return arView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        // This runs every single frame (60 times a second)
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            
            // Get Eye Blink Data (0.0 = Open, 1.0 = Closed)
            let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            
            // FIX: Capture the 'parent' struct here so we don't capture 'self' inside the closure
            let parentCopy = self.parent
            
            DispatchQueue.main.async {
                if leftEyeBlink > 0.8 && rightEyeBlink > 0.8 {
                    parentCopy.message = "Don't close your eyes!"
                } else {
                    parentCopy.message = "Maintain Contact."
                }
            }
        }
    }
}
