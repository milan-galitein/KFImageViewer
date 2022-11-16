//
//  FullScreenSlideshowViewController.swift
//  KFImageViewer
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit

@objcMembers
open class FullScreenSlideshowViewController: UIViewController {

    open var slideshow: KFImageViewer = {
        let slideshow = KFImageViewer()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFit
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]

        return slideshow
    }()
    /// Share button
    open var shareButton = UIButton()
    open var shareImageView = UIImageView()

    /// Close button
    open var closeButton = UIButton()
    open var closeImageView = UIImageView()

    /// Close button frame
    open var closeButtonFrame: CGRect?

    /// Closure called on page selection
    open var pageSelected: ((_ page: Int) -> Void)?

    /// Index of initial image
    open var initialPage: Int = 0

    /// Input sources to
     open var inputs: [InputSource]?

    /// Background color
    open var backgroundColor = UIColor.black

    /// Enables/disable zoom
    open var zoomEnabled = true {
        didSet {
            slideshow.zoomEnabled = zoomEnabled
        }
    }

    fileprivate var isInit = true

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        slideshow.backgroundColor = backgroundColor

        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }

        view.addSubview(slideshow)

        // close button configuration
        shareButton.setImage(UIImage(named: "ic_share_white", in: Bundle(for: type(of: self)), compatibleWith: nil), for: UIControl.State())
        shareButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.share), for: UIControl.Event.touchUpInside)
        closeButton.setImage(UIImage(named: "ic_cross_white", in: Bundle(for: type(of: self)), compatibleWith: nil), for: UIControl.State())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControl.Event.touchUpInside)

        view.addSubview(closeButton)
        view.addSubview(shareButton)
    }

    override open var prefersStatusBarHidden: Bool {
        return true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isInit {
            isInit = false
            slideshow.setCurrentPage(initialPage, animated: false)
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        slideshow.slideshowItems.forEach { $0.cancelPendingLoad() }
    }

    open override func viewDidLayoutSubviews() {
        if !isBeingDismissed {
            let safeAreaInsets: UIEdgeInsets
            if #available(iOS 11.0, *) {
                safeAreaInsets = view.safeAreaInsets
            } else {
                safeAreaInsets = UIEdgeInsets.zero
            }
            shareButton.frame = CGRect(x: max(10, safeAreaInsets.left), y: max(UIScreen.main.bounds.height - 50, safeAreaInsets.top) + 5, width: 40, height: 40)
            closeButton.frame = closeButtonFrame ?? CGRect(x: max(UIScreen.main.bounds.width - 50, safeAreaInsets.right), y: max(10, safeAreaInsets.top), width: 40, height: 40)

        }

        slideshow.frame = view.frame
    }

    @objc func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }

        dismiss(animated: true, completion: nil)
    }
    
    @objc func share() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Download", comment: "Download title"), style: .default , handler:{ (UIAlertAction)in
            self.downloadImage()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Share", comment: "Share title"), style: .default , handler:{ (UIAlertAction)in
            self.shareImage()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismiss title"), style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
          
        })
    }
    
    // share image
    func shareImage() {
        if let image = slideshow.currentSlideshowItem?.imageView.image {
            let imageToShare = [image]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func downloadImage() {
        if let image = slideshow.currentSlideshowItem?.imageView.image {
            self.writeToPhotoAlbum(image: image)
        }
       
   }
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.showToast(message: NSLocalizedString("Downloaded", comment: "downloaded"), font: UIFont.systemFont(ofSize: 15))
    }
}

extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
