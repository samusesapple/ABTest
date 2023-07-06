# ABTest
### 목적
---
Firebase를 이용한 App 구성 요소 제어, AB Test 기능 학습 및 구현
<br>
<br>

### 제어 대상
---
1. MainVC: NoticeVC present 여부
2. NoticeVC.xib : titleLabel.text, detailLabel.text, dateLabel.text 제어
<br>
<br>

### 제어 로직
---
#### 1. MainVC
   ```
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
   ```
   ```
       func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
        return remoteConfig["isHidden"].boolValue
    }
   ```

#### 2. NoticeVC
      ```
      var noticeContents: (title: String, detail: String, date: String)?
      // title, detail, date
      @IBOutlet var noticeView: UIView!
        
      @IBOutlet weak var titleLabel: UILabel!
      @IBOutlet weak var detailLabel: UILabel!
      @IBOutlet weak var dateLabel: UILabel!

      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        
        configureUI()
      }
      
      private func configureUI() {
          view.backgroundColor = .black.withAlphaComponent(0.3)
          
          guard let noticeContents = noticeContents else { return }
          
          titleLabel.text = noticeContents.title
          detailLabel.text = noticeContents.detail
          dateLabel.text = noticeContents.date
      }
  
