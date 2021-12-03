//
//  ViewController.swift
//  WexerSDKSampleApp
//
//  Created by Ishita Agarwal on 26/03/20.
//  Copyright © 2020 DMI. All rights reserved.
//

import UIKit
import WexerContentSDK

class ViewController: UIViewController, WCSDKPlayerEventsListner {

  @IBOutlet weak var viewSession: UIView!
  @IBOutlet weak var viewPerform: UIView!
  @IBOutlet weak var txtUserName: UITextField!
  @IBOutlet weak var txtClassId: UITextField!
  @IBOutlet weak var loader: UIActivityIndicatorView!
//  @IBOutlet weak var lblTotalTime: UILabel!
  @IBOutlet weak var viewVideo: UIView!
  @IBOutlet weak var btnFullScreen: UIButton!
  @IBOutlet weak var btnInView: UIButton!
  @IBOutlet weak var btnCustom: UIButton!
  @IBOutlet weak var lblClassName: UILabel!
  @IBOutlet weak var lblInitialize: UILabel!
  @IBOutlet weak var btnInitialize: UIButton!

  var customOverlayView: OverlayView!
  var viewModel: ViewModel = ViewModel()

  @IBAction func initializeSDKClicked(_ sender: Any) {
    viewModel.initializeSDK()
    viewSession.isHidden = false
    viewVideo.isHidden = true
  }

  @IBAction func startSessionClicked(_ sender: Any) {
    txtUserName.resignFirstResponder()
    if txtUserName.text?.count ?? 0 > 0 {
       loader.isHidden = false
      loader.startAnimating()
      txtUserName.resignFirstResponder()
         viewModel.startSession(userName: txtUserName.text ?? "") { [weak self](error) in
          self?.viewModel.getClasses { (ondemand, error) in
            DispatchQueue.main.async {
              if error != nil {
                self?.loader.isHidden = true
               self?.showToast(message: error?.userInfo["message"] as? String  ?? "error")
              } else {
                self?.viewPerform.isHidden = false
                self?.viewVideo.isHidden = false
                self?.loader.isHidden = true
                self?.btnInitialize.isEnabled = false
                self?.btnInitialize.alpha = 0.6
               self?.viewSession.isHidden = true
                self?.lblClassName.text = ondemand?.className
               self?.viewSession.updateConstraint(attribute: NSLayoutConstraint.Attribute.height, constant: 0)
               self?.viewSession.updateConstraint(attribute: NSLayoutConstraint.Attribute.top, constant: 0)
              }
            }
          }

      }
    } else {
      self.showToast(message: "Enter UserId/Name to start session")
    }
  }
  // Launch player in landscape full screen mode
  @IBAction func fullScreenClicked(_ sender: Any) {
    if viewModel.isPlayerInProgress {
      viewModel.eventHandler?.stopVideo()
    }
    self.customOverlayView = nil
    self.performClassClicked(parentView: nil)
  }
  // Launch player in view provided
  @IBAction func inViewClicked(_ sender: Any) {
    if viewModel.isPlayerInProgress {
      viewModel.eventHandler?.stopVideo()
    }
    self.customOverlayView = nil
    self.performClassClicked(parentView: self.viewVideo)

  }
  // Launch player in view provided & add your own overlay class
  @IBAction func customClicked(_ sender: Any) {
    if viewModel.isPlayerInProgress {
      viewModel.eventHandler?.stopVideo()
    }
    customOverlayView = OverlayView(frame: CGRect.zero)
    self.performClassClicked(parentView: self.viewVideo)
  }

  func performClassClicked(parentView: UIView?) {
    //43794
    loader.isHidden = true
    viewModel.playContent(ondemandContent: viewModel.ondemandclass!,
                          parentView: parentView, overlayView: customOverlayView) {  (_) in

    }
  }
  @IBAction func enableFullScreen(_ sender: Any) {
    viewModel.eventHandler?.enterFullScreen()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    viewSession.isHidden = true
    viewPerform.isHidden = true
    loader.isHidden = true
    viewVideo.isHidden = true
//    lblTotalTime.isHidden = true
    _ = viewModel.observe(\.playStarted) { [weak self] (_, _) in
      self?.loader.isHidden = true
    }

  }

  func playerExit(duration: Int) {
    viewModel.isPlayerInProgress = false
    self.customOverlayView = nil
  }

}

extension UIView {

  func updateConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        if let constraint = (self.constraints.filter {$0.firstAttribute == attribute}.first) {
            constraint.constant = constant
            self.layoutIfNeeded()
        }
    }
}

extension UIViewController {

func showToast(message: String) {

    let toastLabel = UILabel()
    toastLabel.text = message
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = UIFont(name: "System", size: 12.0)
    toastLabel.textAlignment = .center
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds  =  true
    let textSize: CGSize = toastLabel.intrinsicContentSize
    let labelWidth = min(textSize.width, self.view.frame.width - 40)
    toastLabel.frame = CGRect(x: (self.view.frame.size.width - (labelWidth + 30))/2,
                              y: self.view.frame.size.height-100, width: labelWidth + 30, height: 35)
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(_) in
        toastLabel.removeFromSuperview()
    })
} }
