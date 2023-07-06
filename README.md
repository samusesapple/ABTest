# RemoteConfig
### 목적
---
Firebase를 이용한 RemoteConfig 기능 학습
<br>
<br>

### 제어 대상
---
1. MainVC: NoticeVC present 여부
2. NoticeVC.xib : titleLabel.text, detailLabel.text, dateLabel.text 제어
<br>
<br>

### 조건 설정 
---
<img width="676" alt="image" src="https://github.com/samusesapple/ABTest/assets/126672733/6d44661f-eb2d-4cad-8f10-ba8299c4f605">
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
<br>
<br>

### 제어 결과
---
#### xib 파일
<img width="188" alt="image" src="https://github.com/samusesapple/ABTest/assets/126672733/c3efa5a1-de5e-4690-9872-4f4adef1f721">

#### 한글 / 영어
<img width="200" alt="image" src="https://github.com/samusesapple/ABTest/assets/126672733/27c940ea-62c4-4e83-95c6-2c51fda1f957">
<img width="200" alt="image" src="https://github.com/samusesapple/ABTest/assets/126672733/8790e1f0-27b7-4e2f-8174-edc65b8bbe4b">
<br>
<br>

#AB Test
### 목적
---
Firebase를 이용한 AB Test 학습
<br>
<br>

### Test 주제
메세지 문구에 따른 사용자의 확인버튼 탭 빈도수 비교 실험
<br>
<br>

### 실험 비교 케이스 선정
<img width="787" alt="image" src="https://github.com/samusesapple/RemoteConfig-ABTest/assets/126672733/a89e7e23-927a-419c-b4fa-148c22ab41ab">

  


