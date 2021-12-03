//
//  OverlayView.swift
//  WexerSDKSampleApp
//
//  Created by Ishita Agarwal on 28/06/20.
//  Copyright © 2020 DMI. All rights reserved.
//

import UIKit
import WexerContentSDK

class OverlayView: UIView, WCSDKPlayerEventsListner {

  @IBOutlet var contentView: UIView!
  @IBOutlet var playBtn: UIButton!
  @IBOutlet var closeBtn: UIButton!
  @IBOutlet var fullscreenBtn: UIButton!
  @IBOutlet var viewTap: UIView!
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var loader: UIActivityIndicatorView!
  var eventHandler: WCSDKPlayerEvents?
  var isInFullScreenMode = false
  var isPlay = false
  var isReady = false
  var isProgressUpdated = false
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
       initSubviews()
   }

   override init(frame: CGRect) {
       super.init(frame: frame)
       initSubviews()
   }

   func initSubviews() {
       // standard initialization logic
       let nib = UINib(nibName: "OverlayView", bundle: nil)
       nib.instantiate(withOwner: self, options: nil)
       contentView.frame = bounds
       addSubview(contentView)
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
    self.contentView.addGestureRecognizer(tapGesture)
    self.slider.setValue(0, animated: false)
    self.slider.addTarget(self, action: #selector(sliderMoved), for: UIControl.Event.touchUpInside)
    self.slider.addTarget(self, action: #selector(sliderMoved), for: UIControl.Event.touchCancel)
    self.slider.addTarget(self, action: #selector(sliderMoved), for: UIControl.Event.touchDown)
    self.slider.addTarget(self, action: #selector(sliderValueChanged), for: UIControl.Event.valueChanged)

   }

  @objc func didTap(sender: UITapGestureRecognizer) {
     UIView.animate(withDuration: 0) {
       self.showOverlay()
     }
   }
  @objc func sliderMoved() {
    self.eventHandler?.seekTo(timeValue: self.slider.value)
    self.slider.isUserInteractionEnabled = true
  }
 @objc func sliderValueChanged() {
  self.slider.isUserInteractionEnabled = false
  isProgressUpdated = true
  self.playBtn.isHidden = true
  self.fullscreenBtn.isHidden = true
  }

  func showOverlay() {
    //print("show overlay tapped")
    if !isReady {
      return
    }
    DispatchQueue.main.async { [weak self] in
      if self?.viewTap.alpha == 0.0 {
        self?.playBtn.isHidden = false
        self?.closeBtn.isHidden = false
        self?.fullscreenBtn.isHidden = false
        self?.viewTap.alpha = 0.6
        self?.playBtn.alpha = 1.0
        self?.closeBtn.alpha = 1.0
        self?.fullscreenBtn.alpha = 1.0

      } else {
        self?.hideOverlay()
      }
    }
  }

  func hideOverlay() {
    self.viewTap.alpha = 0
    self.playBtn.alpha = 0
    self.closeBtn.alpha = 0
    self.fullscreenBtn.alpha = 0
    self.playBtn.isHidden = true
    self.closeBtn.isHidden = true
    self.fullscreenBtn.isHidden = true

  }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  @IBAction func playBtnClicked(_ sender: Any) {
    if isPlay {
      self.playBtn.setImage(UIImage(named: "play"), for: .normal)
      eventHandler?.pauseVideo()
    } else {
      self.playBtn.setImage(UIImage(named: "pause"), for: .normal)
      eventHandler?.playVideo()
    }
    isPlay = !isPlay
  }

  @IBAction func fullscreenBtnClicked(_ sender: Any) {
    if !isInFullScreenMode {
      isInFullScreenMode = true
      eventHandler?.enterFullScreen()
    } else {
      isInFullScreenMode = false
      eventHandler?.exitFullScreen()

    }
  }

  @IBAction func closeBtnTapped(_ sender: Any) {
    eventHandler?.stopVideo()
  }

  func playerStatus(status: Int) {
    print("play status", status)

   }

   func playerExit(duration: Int) {
     print("play exit", duration)
   }

   func currentVideoPosition(durationPlayedSeconds: Float) {
//     print("currentVideoPosition ",durationPlayedSeconds)
    if isProgressUpdated == false {
      self.slider.value = durationPlayedSeconds
    }
   }

   func totalVideoDuration(totalDuration: Float) {
//     print("totalVideoDuration ",totalDuration)
    self.slider.maximumValue = totalDuration
   }

   func playbackBufferEmpty() {
    self.loader.isHidden = false
    isReady = false
     self.playBtn.isHidden = true
     self.fullscreenBtn.isHidden = true
   }

   func playbackLikelyToKeepUp() {
    self.loader.isHidden = true
    isReady = true
    if isProgressUpdated {
      self.playBtn.isHidden = false
      self.fullscreenBtn.isHidden = false
    }
    isProgressUpdated = false

   }

}
