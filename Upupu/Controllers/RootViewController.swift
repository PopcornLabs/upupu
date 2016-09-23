//
//  RootViewController.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/29/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

import InAppSettingsKit
import SwiftyDropbox

class RootViewController: UINavigationController, CameraViewControllerDelegate,
UploadViewControllerDelegate, IASKSettingsDelegate {

    private var cameraViewController: CameraViewController!
    private var uploadViewController: UploadViewController!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    private func initialize() {
        cameraViewController = CameraViewController()
        cameraViewController.delegate = self

        uploadViewController = UploadViewController()
        uploadViewController.delegate = self

        navigationBar.barStyle = UIBarStyle.BlackOpaque
        navigationBar.hidden = true

        pushViewController(cameraViewController, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func shouldAutorotate() -> Bool {
        return UIDevice.currentDevice().orientation == .Portrait
    }

    // MARK: - CameraViewControllerDelegate

    func cameraViewController(cameraViewController: CameraViewController,
                              didFinishedWithImage image: UIImage?) {
        uploadViewController.image = image
        uploadViewController.shouldSavePhotoAlbum = !cameraViewController.isSourcePhotoLibrary

        pushViewController(uploadViewController, animated: true)
    }

    // MARK: - UploadViewControllerDelegate

    func uploadViewControllerDidReturn(uploadViewController: UploadViewController) {
        cameraViewController.isSourcePhotoLibrary = false

        popViewControllerAnimated(true)
    }

    func uploadViewControllerDidFinished(uploadViewController: UploadViewController) {
        popViewControllerAnimated(true)
    }

    func uploadViewControllerDidSetup(uploadViewController: UploadViewController) {
        let settingsViewController = IASKAppSettingsViewController()
        settingsViewController.delegate = self
        settingsViewController.showCreditsFooter = false

        if Constants.Dropbox.kDBAppKey.isEmpty ||
            Constants.Dropbox.kDBAppKey == "YOUR_DROPBOX_APP_KEY" {
            let hiddenKeys = ["dropbox_group_pref",
                              "dropbox_enabled_pref",
                              "dropbox_link_pref",
                              "dropbox_link_pref",
                              "dropbox_account_pref",
                              "dropbox_location_pref"]
            settingsViewController.hiddenKeys = Set(hiddenKeys)
        }

        let navigationContoller = UINavigationController(rootViewController: settingsViewController)
        navigationContoller.modalTransitionStyle = .CoverVertical

        presentViewController(navigationContoller, animated: true, completion: nil)
    }

    // MARK: - IASKSettingsDelegate

    func settingsViewControllerDidEnd(sender: IASKAppSettingsViewController) {
        sender.dismissViewControllerAnimated(true, completion: nil)
    }

    func settingsViewController(sender: IASKAppSettingsViewController,
                                buttonTappedForSpecifier specifier: IASKSpecifier) {
        if specifier.key() == "dropbox_link_pref" {
            if Dropbox.authorizedClient == nil {
                Dropbox.authorizeFromController(self)
                sender.dismissViewControllerAnimated(true, completion: nil)
            } else {
                Dropbox.unlinkClient()
                Settings.dropboxEnabled = false
                Settings.dropboxLinkButtonTitle = "Connect to Dropbox"
                Settings.dropboxAccount = ""
            }
        }
    }

}
