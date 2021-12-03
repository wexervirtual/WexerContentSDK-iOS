//
//  ViewModel.swift
//  WexerSDKSampleApp
//
//  Created by Ishita Agarwal on 26/03/20.
//  Copyright © 2020 DMI. All rights reserved.
//

import UIKit
import WexerContentSDK

class ViewModel: NSObject {
  
  typealias ExitCallback = (_ value: Int) -> Void
  @objc dynamic var playStarted: Bool
  var errorMessage = ""
  var ondemandclass: WCSDKOndemandClass?
  var eventHandler: WCSDKPlayerEvents?
  var isPlayerInProgress = false
  
  override init() {
    playStarted = false
    super.init()
  }
  
  func initializeSDK() {
    #error("Fill info here to initialize sdk")
    let config = WCSDKConfig(baseURL: "",
                             secretKey: "",
                             apiKey: "", tenantId: "",
                             localyticsKey: "")//
    WCSDK.initialize(config: config)
  }
  
  func startSession(userName: String, completionBlock: @escaping(NSError?) -> Void) {
    WCSDK.startSession(userName: userName) { (error) in
      completionBlock(error)
    }
  }
  
  func getClasses(completionBlock: @escaping(WCSDKOndemandClass?, NSError?) -> Void) {
    WCSDK.getOndemandClasses(page: 1, pageSize: 20, sort: "", order: "") { [weak self] (response, error) in
      if error != nil {
        completionBlock(nil, error)
      } else {
        let responseclasses = response! as WCSDKOndemandClassResponse
        self?.ondemandclass = responseclasses.items.first
        print("total classes ",responseclasses.items.count)
        completionBlock(self?.ondemandclass, error)
        
      }
    }
  }
  
  func playContent(ondemandContent: WCSDKOndemandClass, parentView: UIView?,
                   overlayView: OverlayView?, completionBlock: @escaping(Int) -> Void) {
    
    playStarted = false
    WCSDK.activateSubscription(subscription:
                                WCSDKUserSubscriptionRequest(startDate: Date(),
                                                             subscriptionId: "contentdemo_sdk")) { [weak self]( error) in
      DispatchQueue.main.async {
        if error == nil {
          self?.isPlayerInProgress = true
          let viewConfig = WCSDKVideoViewBuilder(ondemandClassInfo: ondemandContent)
          //                let autoPlay = false
          //                viewConfig.setAutoPlay(enable: autoPlay)
          if overlayView != nil {
            overlayView?.showOverlay()
            //                  overlayView?.isPlay = autoPlay
            //                  if autoPlay == true {
            //                    overlayView?.playBtn.setImage(UIImage(named: "pause"), for: .normal)
            //                  } else {
            //                    overlayView?.playBtn.setImage(UIImage(named: "play"), for: .normal)
            //                  }
            overlayView?.playBtn.setImage(UIImage(named: "pause"), for: .normal)
            viewConfig.setEventReceiver(receiver: overlayView!)
          } else {
            viewConfig.setPlayButtonImage(image: UIImage(named: "play") ?? UIImage())
            viewConfig.setPauseButtonImage(image: UIImage(named: "pause") ?? UIImage())
            viewConfig.setExitButtonImage(image: UIImage(named: "close") ?? UIImage())
            viewConfig.setTitleTextColor(color: UIColor.white)
            viewConfig.setTitleFont(font: UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.heavy))
          }
          viewConfig.startVideoIn(parentView: parentView,
                                  overlayView: overlayView) { [weak self] (events, error) in
            if error == nil {
              self?.playStarted = true
              overlayView?.eventHandler = events
              self?.eventHandler = events
            } else {
              print(error ?? "")
              self?.errorMessage = error?.userInfo["message"] as? String ?? ""
              completionBlock(-1)
            }
          }
        } else {
          completionBlock(-1)
        }
      }
    }
  }
  
}
