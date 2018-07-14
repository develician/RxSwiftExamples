//
//  GetImageViewController.swift
//  RxExample-own
//
//  Created by killi8n on 2018. 7. 14..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire

class GetImageViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.activityIndicatorViewStyle = .gray
        return indicator
    }()
    
    let tf: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    let goButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Go", for: UIControlState.normal)
        return btn
    }()
    
    let iv: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.lightGray
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        viewInit()
        bind()
    }
    
    
}

extension Reactive where Base: UIViewController {
    func showAlert(title: String?, message: String?) -> Observable<Void> {
        return Observable<Void>.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "예", style: UIAlertActionStyle.default, handler: { _ in
                observer.onNext(())
                observer.onCompleted()
            }))
            
            alert.addAction(UIAlertAction(title: "아니오", style: UIAlertActionStyle.cancel, handler: { _ in
                observer.onCompleted()
            }))
            
            self.base.present(alert, animated: true) {
                
            }
            
            return Disposables.create {
                
            }
        })
        

    }
}

extension GetImageViewController {
    
    func viewInit() {
        view.addSubview(tf)
        view.addSubview(goButton)
        view.addSubview(iv)
        view.addSubview(indicator)

        tf.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        tf.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        tf.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        goButton.topAnchor.constraint(equalTo: tf.bottomAnchor, constant: 10).isActive = true
        goButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        goButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        iv.topAnchor.constraint(equalTo: goButton.bottomAnchor, constant: 20).isActive = true
        iv.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        iv.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        iv.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true

        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 20).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
    
    func bind(){
        goButton.rx.tap.asObservable()
            .flatMap {
                [weak self] _ -> Observable<Void> in
                return self?.rx.showAlert(title: "다운로드 하시겠습니까?", message: "다운로드") ?? Observable.empty()
            }
            .observeOn(MainScheduler.instance)
            .withLatestFrom(tf.rx.text.orEmpty)
            .flatMap { [weak self]
                text -> Observable<URL> in
                self?.indicator.startAnimating()
                guard let url = try? text.asURL() else {
                    return Observable.empty()
                }
                return Observable.just(url)
            }.filter {
                url -> Bool in
                let imageExtensions = ["jpg", "jpeg", "gif", "png"]
                return imageExtensions.contains(url.pathExtension)
            }.flatMap {
                (url: URL) -> Observable<String> in
                return Observable<String>.create({ (observer) -> Disposable in
                    
                    let destination = DownloadRequest.suggestedDownloadDestination()
                    
                    let download = Alamofire.download(url, to: destination).response(completionHandler: { (response: DefaultDownloadResponse) in
                        if let data = response.destinationURL {
                            observer.onNext(data.path)
                            observer.onCompleted()
                        } else {
                            observer.onError(RxError.unknown)
                        }
                    })
                    
                    return Disposables.create {
                        download.cancel()
                    }
                })
            }.map { [weak self]
                (data: String) -> UIImage in
                guard let image = UIImage(contentsOfFile: data) else {
                    throw RxError.noElements
                }
                self?.indicator.stopAnimating()
                return image
        }.observeOn(MainScheduler.instance)
            .bind(to: iv.rx.image).disposed(by: disposeBag)
    }
}


