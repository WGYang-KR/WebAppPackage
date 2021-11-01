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

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var mainWebView: WKWebView!
    @IBOutlet var mainView: UIView!
   
    var isTherePush = false;
    var pushURL=URL(string: "https://orderherodl.cafe24.com");
    
    override func loadView() {
        super.loadView()
    
        //mainWebView = WKWebView(frame: self.view.frame)
        mainWebView.uiDelegate = self
        mainWebView.navigationDelegate = self
        //self.view = self.mainWebView
        self.mainWebView?.allowsBackForwardNavigationGestures = true  //뒤로가기 제스쳐 허용
        if #available(iOS 14.0, *) {
            self.mainWebView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            } else {
                // Fallback on earlier versions
                self.mainWebView.configuration.preferences.javaScriptEnabled = true
            }
        /* 원시그널 */
        let osNotificationOpenedBlock: OSNotificationOpenedBlock = { result in
          let notification: OSNotification = result.notification
          print("launchURL: ", notification.launchURL ?? "no launch url")
            if let pushurl = notification.launchURL {
                //url 저장
                self.pushURL = URL(string: pushurl)
                //isTherePush를 True로
                self.isTherePush = true
                //현재 웹뷰가 띄우고 있는 url 체크
                self.mainWebView.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
                    if error != nil {
                                    // the main web view has turned blank
                                    // do something like reload the page
                        print("웹뷰생성 후 푸시열기")
                        let url = URL(string: "https://orderherodl.cafe24.com")
                        let request = URLRequest(url: url!)
                        self.mainWebView.load(request)
                    }
                    else {
                        print("웹뷰 새로고침 후 푸시열기")
                        self.mainWebView.reload()
                    }
                }
            }
     
        }
        OneSignal.setNotificationOpenedHandler(osNotificationOpenedBlock)
        /* ./원시그널 */

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        /*lottie start */
        let animationView = AnimationView(name:"data")
        view.addSubview(animationView)
        animationView.frame = view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        
        animationView.play{ (finish) in print("animation finished")
            animationView.removeFromSuperview()
        }
        
        let url = URL(string: "https://orderherodl.cafe24.com")
        let request = URLRequest(url: url!)
        mainWebView.load(request)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.mainWebView.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
            if error != nil {
                            // the main web view has turned blank
                            // do something like reload the page
                print("웹 다시로드")
                let url = URL(string: "https://orderherodl.cafe24.com")
                let request = URLRequest(url: url!)
                self.mainWebView.load(request)
            }
 
        }
    }

    
    //모달창 닫힐 때 앱 종료현상 방지.
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    

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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        //온 푸시가 있을 때
        if(isTherePush == true) {
            let request = URLRequest(url: self.pushURL!)
            mainWebView.load(request)
            isTherePush = false
        }
        
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

