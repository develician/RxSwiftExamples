//
//  InitViewController.swift
//  RxExample-own
//
//  Created by killi8n on 2018. 7. 14..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

class InitViewController: UIViewController {
    
    let cellId: String = "cellId"
    
    lazy var tv: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        view.addSubview(tv)
        tv.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tv.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tv.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }


}



extension InitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "이미지 받아오기"
        case 1:
            cell.textLabel?.text = "rgb Slider"
        case 2:
            cell.textLabel?.text = "그룹 리스트"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let dest = GetImageViewController()
            self.navigationController?.pushViewController(dest, animated: true)
        case 1:
            let dest = ColorViewController()
            self.navigationController?.pushViewController(dest, animated: true)
        case 2:
            let dest = GroupListViewController()
            self.navigationController?.pushViewController(dest, animated: true)
        default:
            break
        }
    }
    
    
}









