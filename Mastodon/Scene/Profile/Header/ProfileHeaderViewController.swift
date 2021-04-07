//
//  ProfileHeaderViewController.swift
//  Mastodon
//
//  Created by MainasuK Cirno on 2021-3-29.
//

import os.log
import UIKit

protocol ProfileHeaderViewControllerDelegate: class {
    func profileHeaderViewController(_ viewController: ProfileHeaderViewController, viewLayoutDidUpdate view: UIView)
    func profileHeaderViewController(_ viewController: ProfileHeaderViewController, pageSegmentedControlValueChanged segmentedControl: UISegmentedControl, selectedSegmentIndex index: Int)
}

final class ProfileHeaderViewController: UIViewController {

    static let segmentedControlHeight: CGFloat = 32
    static let segmentedControlMarginHeight: CGFloat = 20
    static let headerMinHeight: CGFloat = segmentedControlHeight + 2 * segmentedControlMarginHeight
    
    weak var delegate: ProfileHeaderViewControllerDelegate?
    
    let profileBannerView = ProfileHeaderView()
    let pageSegmentedControl: UISegmentedControl = {
        let segmenetedControl = UISegmentedControl(items: ["A", "B"])
        segmenetedControl.selectedSegmentIndex = 0
        return segmenetedControl
    }()

    private var isBannerPinned = false
    private var bottomShadowAlpha: CGFloat = 0.0

    private var isAdjustBannerImageViewForSafeAreaInset = false
    private var containerSafeAreaInset: UIEdgeInsets = .zero

    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension ProfileHeaderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Asset.Colors.Background.systemGroupedBackground.color

        profileBannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileBannerView)
        NSLayoutConstraint.activate([
            profileBannerView.topAnchor.constraint(equalTo: view.topAnchor),
            profileBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        profileBannerView.preservesSuperviewLayoutMargins = true
        
        pageSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageSegmentedControl)
        NSLayoutConstraint.activate([
            pageSegmentedControl.topAnchor.constraint(equalTo: profileBannerView.bottomAnchor, constant: ProfileHeaderViewController.segmentedControlMarginHeight),
            pageSegmentedControl.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            pageSegmentedControl.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: pageSegmentedControl.bottomAnchor, constant: ProfileHeaderViewController.segmentedControlMarginHeight),
            pageSegmentedControl.heightAnchor.constraint(equalToConstant: ProfileHeaderViewController.segmentedControlHeight).priority(.defaultHigh),
        ])
        
        pageSegmentedControl.addTarget(self, action: #selector(ProfileHeaderViewController.pageSegmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isAdjustBannerImageViewForSafeAreaInset {
            isAdjustBannerImageViewForSafeAreaInset = true
            profileBannerView.bannerImageView.frame.origin.y = -containerSafeAreaInset.top
            profileBannerView.bannerImageView.frame.size.height += containerSafeAreaInset.top
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        delegate?.profileHeaderViewController(self, viewLayoutDidUpdate: view)
        view.layer.setupShadow(color: UIColor.black.withAlphaComponent(0.12), alpha: Float(bottomShadowAlpha), x: 0, y: 2, blur: 2, spread: 0, roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: .zero)
    }
    
}

extension ProfileHeaderViewController {

    @objc private func pageSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        os_log(.info, log: .debug, "%{public}s[%{public}ld], %{public}s: selectedSegmentIndex: %ld", ((#file as NSString).lastPathComponent), #line, #function, sender.selectedSegmentIndex)
        delegate?.profileHeaderViewController(self, pageSegmentedControlValueChanged: sender, selectedSegmentIndex: sender.selectedSegmentIndex)
    }
    
}

extension ProfileHeaderViewController {
    
    func updateHeaderContainerSafeAreaInset(_ inset: UIEdgeInsets) {
        containerSafeAreaInset = inset
    }
    
    private func updateHeaderBottomShadow(progress: CGFloat) {
        let alpha = min(max(0, 10 * progress - 9), 1)
        if bottomShadowAlpha != alpha {
            bottomShadowAlpha = alpha
            view.setNeedsLayout()
        }
    }
    
    func updateHeaderScrollProgress(_ progress: CGFloat) {
        // os_log(.info, log: .debug, "%{public}s[%{public}ld], %{public}s: progress: %.2f", ((#file as NSString).lastPathComponent), #line, #function, progress)
        updateHeaderBottomShadow(progress: progress)
                
        let bannerImageView = profileBannerView.bannerImageView
        guard bannerImageView.bounds != .zero else {
            // wait layout finish
            return
        }
        
        let bannerContainerInWindow = profileBannerView.convert(profileBannerView.bannerContainerView.frame, to: nil)
        let bannerContainerBottomOffset = bannerContainerInWindow.origin.y + bannerContainerInWindow.height
        
        if bannerContainerInWindow.origin.y > containerSafeAreaInset.top {
            bannerImageView.frame.origin.y = -bannerContainerInWindow.origin.y
            bannerImageView.frame.size.height = bannerContainerInWindow.origin.y + bannerContainerInWindow.size.height
        } else if bannerContainerBottomOffset < containerSafeAreaInset.top {
            bannerImageView.frame.origin.y = -containerSafeAreaInset.top
            let bannerImageHeight = bannerContainerInWindow.size.height + containerSafeAreaInset.top + (containerSafeAreaInset.top - bannerContainerBottomOffset)
            bannerImageView.frame.size.height = bannerImageHeight
        } else {
            bannerImageView.frame.origin.y = -containerSafeAreaInset.top
            bannerImageView.frame.size.height = bannerContainerInWindow.size.height + containerSafeAreaInset.top
        }
        
        // TODO: handle titleView
    }
    
}