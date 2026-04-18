import UIKit

extension UIViewController {
    
    private struct AssociatedLoaderKeys {
        static var overlayView: UInt8 = 0
        static var activityIndicator: UInt8 = 0
    }
    
    private var loaderOverlay: UIView? {
        get { return objc_getAssociatedObject(self, &AssociatedLoaderKeys.overlayView) as? UIView }
        set { objc_setAssociatedObject(self, &AssociatedLoaderKeys.overlayView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var loaderIndicator: UIActivityIndicatorView? {
        get { return objc_getAssociatedObject(self, &AssociatedLoaderKeys.activityIndicator) as? UIActivityIndicatorView }
        set { objc_setAssociatedObject(self, &AssociatedLoaderKeys.activityIndicator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Displays a beautiful, modern blurred loading pill.
    /// - Parameter isBlocking: If true, prevents touches on the screen and slightly dims the background.
    func showModernLoader(isBlocking: Bool = false) {
        if loaderOverlay != nil { return } // Already showing
        
        // Ensure this happens on the main thread
        DispatchQueue.main.async {
            let overlay = UIView(frame: self.view.bounds)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            if isBlocking {
                overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.4)
                overlay.isUserInteractionEnabled = true // Blocks touches from passing through
            } else {
                overlay.backgroundColor = .clear
                overlay.isUserInteractionEnabled = false // Lets touches pass through
            }
            
            // Modern frosted glass pill
            let blurEffect = UIBlurEffect(style: .systemThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 18
            blurView.clipsToBounds = true
            
            // Brand Pink Indicator
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.color = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
            indicator.startAnimating()
            
            blurView.contentView.addSubview(indicator)
            overlay.addSubview(blurView)
            
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), isBlocking {
                // Attach to window if it's a blocking loader so it covers navigation bars
                window.addSubview(overlay)
            } else {
                self.view.addSubview(overlay)
            }
            
            NSLayoutConstraint.activate([
                blurView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                blurView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                blurView.widthAnchor.constraint(equalToConstant: 80),
                blurView.heightAnchor.constraint(equalToConstant: 80),
                
                indicator.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: blurView.centerYAnchor)
            ])
            
            overlay.alpha = 0
            UIView.animate(withDuration: 0.25) {
                overlay.alpha = 1
            }
            
            self.loaderOverlay = overlay
            self.loaderIndicator = indicator
        }
    }
    
    /// Hides and removes the modern loading pill.
    func hideModernLoader() {
        DispatchQueue.main.async {
            guard let overlay = self.loaderOverlay else { return }
            
            UIView.animate(withDuration: 0.25, animations: {
                overlay.alpha = 0
            }) { _ in
                self.loaderIndicator?.stopAnimating()
                overlay.removeFromSuperview()
                self.loaderOverlay = nil
                self.loaderIndicator = nil
            }
        }
    }
}
