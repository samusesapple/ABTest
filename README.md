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
<br>

# AB Test
### 목적
---
Firebase를 이용한 AB Test 기능 학습
<br>
<br>

### Test 대상
얼럿창 상의 메세지 문구에 따른 사용자의 '이벤트 보기'버튼 탭 빈도수 비교 실험
<br>
<br>

### 비교군, 대조군 생성
<img width="787" alt="image" src="https://github.com/samusesapple/RemoteConfig-ABTest/assets/126672733/a89e7e23-927a-419c-b4fa-148c22ab41ab">
<br>
<br>

### 테스트 실행 코드
MainVC를 확장하여 얼럿창 테스트하는 메서드 추가
```
func presentEventAlert() {
        guard let remoteConfig = remoteConfig else { return }
        
        remoteConfig.fetch { status, _ in
            switch status {
            case .success:
                remoteConfig.activate()
            case .failure:
                print("ERROR: Failed fetching remoteConfig")
            default:
                break
            }
            
            
            let message = remoteConfig["message"].stringValue ?? ""
            let alert = UIAlertController(title: "깜짝 이벤트",
                                          message: message,
                                          preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "이벤트 보기",
                                              style: .default) { _ in
                Analytics.logEvent("event_message", parameters: nil)
            }
            let cancelAction = UIAlertAction(title: "취소",
                                             style: .cancel)
            
            [confirmAction, cancelAction].forEach(alert.addAction)
            
            self.present(alert, animated: true)
        }
    }
```
<br>
<br>

### 실험군, 대조군 반영 화면
<img width="447" alt="image" src="https://github.com/samusesapple/RemoteConfig-ABTest/assets/126672733/7a0a74b8-2100-435f-ac09-623aeb7e96d9">!
<img width="230" alt="image" src="https://github.com/samusesapple/RemoteConfig-ABTest/assets/126672733/604bbd11-aa6b-41f4-87f5-cf017469c39c">
<img width="447" alt="image" src="https://github.com/samusesapple/RemoteConfig-ABTest/assets/126672733/59604e1c-0434-4e15-a2c5-dc5f491912d0">
<img width="230" alt="image" src="https://github.com/samusesapple/RemoteConfig-ABTest/assets/126672733/599a398e-b898-44e0-b679-d850a79a60d8">
