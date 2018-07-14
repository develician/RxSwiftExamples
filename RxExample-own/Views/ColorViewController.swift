//
//  ColorViewController.swift
//  RxExample-own
//
//  Created by killi8n on 2018. 7. 14..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ColorViewController: UIViewController {

    var disposeBag: DisposeBag = DisposeBag()
    
    let rSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let gSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let bSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let colorTf: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    let rLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let gLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let applyBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("적용하기", for: UIControlState.normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        viewInit()
        
        bind()

    }

}

extension Reactive where Base: UIView {
    var backgroundColor: Binder<UIColor> {
        return Binder(self.base) {
            view, color in
            view.backgroundColor = color
        }
    }
}

extension ColorViewController {
    func viewInit() {
        view.addSubview(rSlider)
        view.addSubview(gSlider)
        view.addSubview(bSlider)
        view.addSubview(colorView)
        view.addSubview(colorTf)
        view.addSubview(rLabel)
        view.addSubview(gLabel)
        view.addSubview(bLabel)
        view.addSubview(applyBtn)

        colorView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20).isActive = true
        colorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        colorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        colorTf.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 10).isActive = true
        colorTf.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        colorTf.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true

        rSlider.topAnchor.constraint(equalTo: colorTf.bottomAnchor, constant: 40).isActive = true
        rSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        rSlider.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.7).isActive = true
        rLabel.topAnchor.constraint(equalTo: rSlider.topAnchor, constant: 0).isActive = true
        rLabel.leftAnchor.constraint(equalTo: rSlider.rightAnchor, constant: 15).isActive = true
        
        gSlider.topAnchor.constraint(equalTo: rSlider.bottomAnchor, constant: 10).isActive = true
        gSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        gSlider.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.7).isActive = true
        gLabel.topAnchor.constraint(equalTo: gSlider.topAnchor, constant: 0).isActive = true
        gLabel.leftAnchor.constraint(equalTo: gSlider.rightAnchor, constant: 15).isActive = true

//
        bSlider.topAnchor.constraint(equalTo: gSlider.bottomAnchor, constant: 10).isActive = true
        bSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        bSlider.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.7).isActive = true
        bLabel.topAnchor.constraint(equalTo: bSlider.topAnchor, constant: 0).isActive = true
        bLabel.leftAnchor.constraint(equalTo: bSlider.rightAnchor, constant: 15).isActive = true
        
        applyBtn.topAnchor.constraint(equalTo: bSlider.bottomAnchor, constant: 20).isActive = true
        applyBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        applyBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
    }
    
    func bind() {
        let rObservable = rSlider.rx.value.asObservable().map {CGFloat($0)}
        let gObservable = gSlider.rx.value.asObservable().map {CGFloat($0)}
        let bObservable = bSlider.rx.value.asObservable().map {CGFloat($0)}
        
        rObservable.map { "\(Int($0 * 255))" }.bind(to: rLabel.rx.text).disposed(by: disposeBag)
        gObservable.map { "\(Int($0 * 255))" }.bind(to: gLabel.rx.text).disposed(by: disposeBag)
        bObservable.map { "\(Int($0 * 255))" }.bind(to: bLabel.rx.text).disposed(by: disposeBag)

        let color = Observable<UIColor>.combineLatest(rObservable, gObservable, bObservable) { (rValue, gValue, bValue) -> UIColor in
            return UIColor(red: rValue, green: gValue, blue: bValue, alpha: 1.0)
        }
        
        color.bind(to: colorView.rx.backgroundColor).disposed(by: disposeBag)
        
        color.map { $0.hexString }.bind(to: colorTf.rx.text).disposed(by: disposeBag)
        
        applyBtn.rx.tap.withLatestFrom(colorTf.rx.text.orEmpty).map {
            (hexText: String) -> (Int, Int, Int)? in
            hexText.rgb
            }.flatMap { (rgb) -> Observable<(Int, Int, Int)> in
                
                guard let rgb = rgb else {
                    return Observable.empty()
                }
                
                return Observable.just(rgb)
            }.subscribe(onNext: { [weak self] (red, green, blue) in
                guard let `self` = self else { return }
                self.rSlider.rx.value.onNext(Float(red) / 255.0)
                self.rSlider.sendActions(for: UIControlEvents.valueChanged)
                
                self.gSlider.rx.value.onNext(Float(green) / 255.0)
                self.gSlider.sendActions(for: UIControlEvents.valueChanged)
                
                self.bSlider.rx.value.onNext(Float(blue) / 255.0)
                self.bSlider.sendActions(for: UIControlEvents.valueChanged)
            }).disposed(by: disposeBag)
        
    }
}


extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%.2X%.2X%.2X", Int(255 * red), Int(255 * green), Int(255 * blue))
    }
}

extension String {
    var rgb: (Int, Int, Int)? {
        guard let number: Int = Int(self, radix: 16) else { return nil }
        let blue = number & 0x0000ff
        let green = (number & 0x00ff00) >> 8
        let red = (number & 0xff0000) >> 16
        return (red, green, blue)
    }
}
