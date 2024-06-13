//
//  AsyncImageView.swift
//
//
//  Created by 李天培 on 2022/6/28.
//

import Combine
import SwiftUI

#if DEBUG

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AsyncImageView(image: "https://cdn.sapphire.microsoftapp.net/icons/glance/20220913/bg/glance_card_bg_trending_dark.png") { image in
                image
            } placeholder: {
                ProgressView()
            }
        }
    }
}
#endif

/// Protocol to which network session handling classes must conform to.
public protocol NetworkSessionProtocol {
    func request(for url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

class Session: NetworkSessionProtocol {
    private var cancellable = Set<AnyCancellable>()
    
    func request(for url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data as Data? }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink {
                completionHandler($0, nil, nil)
            }
            .store(in: &cancellable)
    }
}

public class NetworkSession {
    public static let shared = NetworkSession()
    private(set) var session: NetworkSessionProtocol = Session()
    public func updateSession(_ session: NetworkSessionProtocol) {
        self.session = session
    }
}

// MARK: - Image Loader
class ImageLoader: ObservableObject {
    private class Cache {
        static let shared = Cache()
        var imageData = [String: Data]()
    }
        
    @Published
    var imageData: Data?
    private var cache = Cache.shared
    
    func fetch(url urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if let data = cache.imageData[urlString] {
            imageData = data
        } else {
            NetworkSession.shared.session.request(for: url) { [weak self] data, _, _ in
                if let image = data {
                    self?.cache.imageData[urlString] = image
                    self?.imageData = image
                }
            }
        }
    }
}

/// automatically to load image data from url, bundle or system image
public struct AsyncImageView<Content: View, Placeholder: View>: View {
    @ObservedObject
    private var loader: ImageLoader
    private var image: String
    private var content: (Image) -> Content
    private var placeholder: () -> Placeholder
    private var bundle: Bundle?

    public init(
        image: String, bundle: Bundle? = nil, scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.image = image
        self.bundle = bundle
        loader = ImageLoader()
        self.content = content
        self.placeholder = placeholder
        loader.fetch(url: image)
    }

    public var body: some View {
        #if canImport(UIKit)
        if let imageData = loader.imageData, let remoteImage = PlatformImage(data: imageData) {
            content(Image(platformImage: remoteImage))
        } else if let localImage = PlatformImage(named: image, in: bundle, with: nil)
            ?? PlatformImage(systemName: image)
        {
            content(Image(platformImage: localImage))
        } else {
            ZStack {
                Color.clear
                placeholder()
            }
        }
        #elseif canImport(NSKit)
        if let imageData = loader.imageData, let remoteImage = PlatformImage(data: imageData) {
            content(Image(platformImage: remoteImage))
        } else if let localImage = PlatformImage(named: image, in: bundle, with: nil)
            ?? PlatformImage(systemName: image)
        {
            content(Image(platformImage: localImage))

        } else {
            ZStack {
                Color.clear
                placeholder()
            }
        }
        #endif

    }
}

// MARK: - Imagable

public enum Imagable {
    case image(image: PlatformImage)
    case url(String)
}

public struct ImagableView<Content: View, Placeholder: View>: View {
    public init(imagable: Imagable, @ViewBuilder content: @escaping (Image) -> Content, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.imagable = imagable
        self.content = content
        self.placeholder = placeholder
    }
    
    var imagable: Imagable
    @ViewBuilder
    var content: (Image) -> Content
    @ViewBuilder
    var placeholder: () -> Placeholder
    public var body: some View {
        switch imagable {
        case .image(let image):
            content(Image(platformImage: image))
        case .url(let url):
            CachedAsyncImage(url: URL(string: url)) { image in
                content(image)
            } placeholder: {
                placeholder()
            }
        }
    }
}
