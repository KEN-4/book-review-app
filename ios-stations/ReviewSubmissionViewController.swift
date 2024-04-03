import UIKit
import Alamofire
import KeychainAccess

class ReviewSubmissionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var uiLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var BookDetailPlaceholder: UILabel!
    @IBOutlet weak var BookReviewPlaceholder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Network.shared.isOnline() {
            // オンライン時の処理
        } else {
            // オフライン時の処理
            let alert = UIAlertController(title: "オフラインです", message: "インターネット接続が必要です。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        titleTextField.delegate = self
        urlTextField.delegate = self
        detailTextView.delegate = self
        reviewTextView.delegate = self
        
        BookDetailPlaceholder.text = "BookDetail"
        BookReviewPlaceholder.text = "BookReview"
        
        updateSubmitButtonState()
    }
    
    //textFieldにテキストが入力されたり変更されたりするときに呼ばれるdelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // ボタンの状態を更新
        updateSubmitButtonState()
        return true
    }
    
    //textViewにテキストが入力されたり変更されたりするときに呼ばれるdelegate
    // TextViewのテキストが変更されたときに呼ばれる
    func textViewDidChange(_ textView: UITextView) {
        // プレースホルダーの表示/非表示を切り替える
        if textView == detailTextView {
            BookDetailPlaceholder.isHidden = !textView.text.isEmpty
        } else if textView == reviewTextView {
            BookReviewPlaceholder.isHidden = !textView.text.isEmpty
        }
        // ボタンの状態を更新
        updateSubmitButtonState()
    }
    
    func updateSubmitButtonState() {
        // 全てのTextFieldに入力があるか確認
        // textがnillの場合,trueを返す→!で反転するからfalseを返す
        let isTitleEntered = !(titleTextField.text?.isEmpty ?? true)
        let isUrlEntered = !(urlTextField.text?.isEmpty ?? true)
        let isDetailEntered = !(detailTextView.text?.isEmpty ?? true)
        let isReviewEntered = !(reviewTextView.text?.isEmpty ?? true)
        // ボタンの有効/無効を切り替え
        submitButton.isEnabled = isTitleEntered && isUrlEntered && isDetailEntered && isReviewEntered
    }
    
//    @IBOutlet weak var bottomConsraint: NSLayoutConstraint!
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, title.isTitle() else {
            self.uiLabel.text = "タイトルは3文字以上で入力してください"
            return
        }
//        bottomConsraint.constant = 10
        
        guard let url = urlTextField.text, url.isURL() else {
            self.uiLabel.text = "有効なURLを入力してください"
            return
        }
        guard let detail = detailTextView.text, detail.isDetail() else {
            self.uiLabel.text = "詳細情報は3文字以上で入力してください"
            return
        }
        guard let review = reviewTextView.text, review.isReview() else {
            self.uiLabel.text = "レビューは3文字以上で入力してください"
            return
        }
        submitReview(title: title, url: url, detail: detail, review: review)
    }
    
    // ここでバリデーション済みの引数を指定する
    private func submitReview(title: String, url: String, detail: String, review: String) {
        let keychain = Keychain(service: "jp.co.techbowl.ios-stations-user")
        guard let token = keychain[TokenKey.token] else {
            print("認証トークンがありません")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let parameters: Parameters = [
            "title": title,
            "url": url,
            "detail": detail,
            "review": review
        ]
        
        AF.request("https://railway.bookreview.techtrain.dev/books", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(_):
                print("レビュー投稿に成功しました")
                DispatchQueue.main.async {
                    self.uiLabel.text = "レビュー投稿に成功しました"
                }
            case .failure(let error):
                print("レビュー投稿に失敗しました: \(error)")
                DispatchQueue.main.async {
                    self.uiLabel.text = "レビュー投稿に失敗しました"
                }
            }
        }
    }
}
