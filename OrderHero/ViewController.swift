//
//  ViewController.swift
//  OrderHero
//
//  Created by delivery LAB on 2021/10/14.
//

import UIKit
import WebKit /*웹뷰 사용을 위한 라이브러리*/
import Lottie /*로티 사용을 위한 라이브러리*/
import OneSignal

let main_url = "https://orderherodl.cafe24.com/main_home.php"

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet var mainWebView: WKWebView!
    @IBOutlet var mainView: UIView!
   
    var isTherePush = false; //푸시가 있는지
    var pushURL=URL(string: main_url); //푸시된 URL
    var isThereLinkURL = false; //외부 딥링크 URL이 있는지.
    var linkURL = URL(string:""); //외부 딥링크 URL.
    
    override func loadView() {
        super.loadView()
    
    /* 웹뷰 설정 */
        mainWebView.uiDelegate = self
        mainWebView.navigationDelegate = self
        mainWebView?.allowsBackForwardNavigationGestures = true  //뒤로가기 제스쳐 허용
        if #available(iOS 14.0, *) { //자바스크립트 허용
            self.mainWebView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
            self.mainWebView.configuration.preferences.javaScriptEnabled = true
        }
    /* ./웹뷰 설정 */
        
    /* 원시그널 푸시 등록 */
        let osNotificationOpenedBlock: OSNotificationOpenedBlock = { result in
          let notification: OSNotification = result.notification
          print("launchURL: ", notification.launchURL ?? "no launch url")
            if let pushurl = notification.launchURL {
                //url 저장
                self.pushURL = URL(string: pushurl)
                //isTherePush를 True로
                self.isTherePush = true
                
                //현재 웹뷰에 열려있는 페이지가 있는지 확인.
                self.mainWebView.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
                    /* 현재 페이지가 없음 */
                    if error != nil {
                                    // the main web view has turned blank
                                    // do something like reload the page
                        print("웹뷰생성 후 푸시 열기")
                        let url = URL(string: main_url)
                        let request = URLRequest(url: url!)
                        self.mainWebView.load(request)
                    }
                    /* 현재 페이지 존재 */
                    else {
                        print("웹뷰 새로고침 후 푸시 열기")
                        self.mainWebView.reload()
                    }
                }
                /* ./evaluateJavaScript */
            
            }
            /* ./if have launch URL */
     
        }
        
        OneSignal.setNotificationOpenedHandler(osNotificationOpenedBlock)
    /* ./원시그널 푸시 등록 */

        
    }
    /* ./loadView() */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 로티(로딩이미지) */
        let animationView = AnimationView(name:"data")
        view.addSubview(animationView)
        animationView.frame = view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        
        animationView.play{ (finish) in print("animation finished")
            animationView.removeFromSuperview()
        }
        /* 로티(로딩이미지) */
        
        /* 메인페이지 띄우기 */
        let url = URL(string: main_url)
        let request = URLRequest(url: url!)
        mainWebView.load(request)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* 앱 resume 시, 웹페이지가 사라졌으면 다시 띄우기 */
        self.mainWebView.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
            if error != nil {
                            // the main web view has turned blank
                            // do something like reload the page
                print("웹 다시로드")
                let url = URL(string: main_url)
                let request = URLRequest(url: url!)
                self.mainWebView.load(request)
            }
 
        }
    }

    /* tel,sms,kakaolink 처리*/
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        print(navigationAction.request.url?.absoluteString ?? "")
        
        // 결제, sms, tel 처리
        // 스키마가 http,http가 아니면 open(_ url:) 메소드를 호출합니다.
        if let url = navigationAction.request.url
            , ["http", "https"].contains(url.scheme)==false {

            print("외부 링크 실행")
            // 외부 실행.
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            decisionHandler(.cancel)
            return
        }
        
        // 카카오 플러스친구 처리
        // 호스트에 pf.이 포함되어 있으면 open(_ url:) 메소드를 호출합니다.
        if let url = navigationAction.request.url
            , url.host?.contains("pf.")==true {
            
            print("플러스친구 링크 실행")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            decisionHandler(.cancel)
            return
        }

        
        decisionHandler(.allow)
    }
    
    //웹뷰 로드가 끝났을 때 호출 되는 함수.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        /* 푸시 처리 */
        if(isTherePush == true) {
            let request = URLRequest(url: self.pushURL!)
            mainWebView.load(request)
            isTherePush = false
        }
        
        if(isThereLinkURL == true) {
            let request = URLRequest(url:self.linkURL!)
            mainWebView.load(request)
            isThereLinkURL = false
        }
        
        if(mainWebView.url == URL(string: main_url) ) {
        /* Push Player ID DB저장을 위한 코드 */
            //device user id 획득
            if let deviceState = OneSignal.getDeviceState() {
                let userId = deviceState.userId
                print("OneSignal Push Player ID: ", userId ?? "called too early, not set yet")
               
                //실행할 script문 생성
                var action = "var iframe = document.createElement('iframe'); "
                  action += "iframe.style.css = 'display:none;'; "
                  action += "iframe.id = 'myFrame'; "
                  action += "iframe.name = 'myFrame'; "
                  action += "iframe.scrolling = 'no'; "
                  action += "iframe.frameborder = '0'; "
                  action += "iframe.width = 0; "
                  action += "iframe.height = 0; "
                  action += "document.body.appendChild(iframe); "
                  action += "iframe.src = './onesignaluserID_IOS.php?app_id="
                  action += userId!
                  action += "&use_info=ios';"
                print(action)
                //script문 실행
                self.mainWebView.evaluateJavaScript(action) { (result, error) in
                    if error != nil {
                        print("실패: app_id, use_info DB추가")
                        print(error!)
                    }
                    else {
                        print("성공: app_id, use_info DB추가")
                    }
                }
                
            }
        }
        /* ./Push Player ID DB저장을 위한 코드 */
    }
    
    /* 웹뷰 중복 reload 방지 */
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            mainWebView.reload()
        }
    
    /* <a target = '_blank'></a> 처리 */
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    
    
    /* 자바스크립트 alert() 처리 */
        //javaScript의 alert을 띄웁니다. [확인]버튼
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
                completionHandler()
            }))
            
            present(alertController, animated: true, completion: nil)
        }
        //javaScript의 alert을 띄웁니다. [확인], [취소]버튼
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
                completionHandler(true)
            }))
            
            alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
                completionHandler(false)
            }))
            
            present(alertController, animated: true, completion: nil)
        }
        
        //javaScript의 alert을 띄웁니다. [확인], [취소]버튼 + 텍스트 입력 패널
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            
            let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.text = defaultText
            }
            
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
                if let text = alertController.textFields?.first?.text {
                    completionHandler(text)
                } else {
                    completionHandler(defaultText)
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
                completionHandler(nil)
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    /* ./자바스크립트 alert() 처리  */
    
    
}

