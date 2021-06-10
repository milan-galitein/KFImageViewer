//
//  KingfisherSource.swift
//  KFImageViewer
//
//

import Kingfisher

/// Input Source to image using Kingfisher
public class KingfisherSource: NSObject, InputSource {
    /// url to load
    public var url: URL

    /// placeholder used before image is loaded
    public var placeholder: UIImage?
    
    /// options for displaying, ie. [.transition(.fade(0.2))]
    public var options: KingfisherOptionsInfo?

    /// Initializes a new source with a URL
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    /// - parameter options: options for displaying
    public init(url: URL, placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.options = options
        super.init()
    }

    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    /// - parameter options: options for displaying
    public init?(urlString: String, placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = nil) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            self.placeholder = placeholder
            self.options = options
            super.init()
        } else {
            return nil
        }
    }

    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        if Api.isPreferredNetworkAvailable(), let token = Settings.getInstance().apiToken {
            let modifier = AnyModifier { request in
                var r = request
                r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return r
            }
            let resource = ImageResource(downloadURL: self.url)
            imageView.kf.setImage(
                with: resource,
                placeholder: nil,
                options: [
                    .requestModifier(modifier)
                ]) { result in
                switch result {
                case .success(let value):
                    callback(value.image)
                    break;
                case .failure(_):
                    break;
                }
            }
        }
    }
    
    public func loadWithProgress(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void, progress: @escaping (CGFloat) -> Void) {
        if Api.isPreferredNetworkAvailable(), let token = Settings.getInstance().apiToken {
            let modifier = AnyModifier { request in
                var r = request
                r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return r
            }
            let resource = ImageResource(downloadURL: self.url)
            imageView.kf.setImage(
                with: resource,
                placeholder: nil,
                options: [
                    .requestModifier(modifier)
                ]) { (recieved,total) in
                progress((CGFloat(recieved)/CGFloat(total)))
            } completionHandler: { result in
                switch result {
                case .success(let value):
                    callback(value.image)
                    break;
                case .failure(_):
                    break;
                }
            }
        }
    }
    
    public func cancelLoad(on imageView: UIImageView) {
        imageView.kf.cancelDownloadTask()
    }
}
