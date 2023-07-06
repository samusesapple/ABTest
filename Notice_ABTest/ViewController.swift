//
//  ViewController.swift
//  Notice_ABTest
//
//  Created by Sam Sung on 2023/07/06.
//

import UIKit
import FirebaseRemoteConfig

class ViewController: UIViewController {

    var remoteConfig: RemoteConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0
        
        // set remoteConfig's setting
        remoteConfig?.configSettings = setting
        
        // set default value with plist
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        setRemoteConfigFromFirebase()
    }
}

extension ViewController {
    func setRemoteConfigFromFirebase() {
        guard let remoteConfig = remoteConfig else { return }
        remoteConfig.fetch { [weak self] status, _ in
            switch status {
            case .success:
                remoteConfig.activate()
            case .failure:
                print("ERROR: Failed Fetching Config")
            default:
                break
            }
            
            guard let self = self else { return }
            // 알림창 보여지는 경우
            if !self.isNoticeHidden(remoteConfig) {
                let noticeVC = NoticeViewController(nibName: "NoticeViewController",
                                                    bundle: nil)
                noticeVC.modalPresentationStyle = .custom
                noticeVC.modalTransitionStyle = .crossDissolve
                
                // firebase에서는 띄어쓰기를 '\\n'으로 표기하기에 '\n'으로 변환 필요
                let title = (remoteConfig["title"].stringValue ?? "")
                    .replacingOccurrences(of: "\\n", with: "\n")
                let detail = (remoteConfig["detail"].stringValue ?? "")
                    .replacingOccurrences(of: "\\n", with: "\n")
                let date = (remoteConfig["date"].stringValue ?? "")
                    .replacingOccurrences(of: "\\n", with: "\n")
                
                noticeVC.noticeContents = (title, detail, date)
                
                self.present(noticeVC, animated: true)
            }
        }
    }
    
    func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
        return remoteConfig["isHidden"].boolValue
    }
}
