//
//  GifView.swift
//  DrawingApp
//
//  Created by Martin Krcma on 01.12.2023.
//

import SwiftUI
import FLAnimatedImage

enum URLType {
    
    case name(String)
    case url(URL)
    
    var url: URL? {
        switch self {
        case .name(let name):
            return Bundle.main.url(forResource: name, withExtension: "gif")
        case .url(let remoteURL):
            return remoteURL
        }
    }
}

struct GIFView: UIViewRepresentable {

    var type: URLType
    @Binding var isActive: Bool
    var durationToShow: TimeInterval

    class Coordinator: NSObject {
        var parent: GIFView

        init(parent: GIFView) {
            self.parent = parent
        }

        @objc func playGIF() {
            guard let url = parent.type.url else { return }
            if let data = try? Data(contentsOf: url) {
                let image = FLAnimatedImage(animatedGIFData: data)
                DispatchQueue.main.async {
                    self.parent.imageView.animatedImage = image
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.parent.durationToShow) {
                        self.parent.isActive = false
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isActive {
            context.coordinator.playGIF()
        }
    }

    private let imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()
}
