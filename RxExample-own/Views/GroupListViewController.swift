//
//  GroupListViewController.swift
//  RxExample-own
//
//  Created by killi8n on 2018. 7. 14..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class GroupListViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let cellId: String = "cellId"
    
    lazy var tv: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        viewInit()
        bind()
        
    }

    

}

typealias GroupSection = SectionModel<String, Group>

extension GroupListViewController {
    
    func viewInit() {
        view.addSubview(tv)
        tv.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func createDatasource() -> RxTableViewSectionedReloadDataSource<GroupSection> {
        return RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (datasource, tv, indexPath, group) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: (self?.cellId)!, for: indexPath)
            cell.textLabel?.text = group.name
            return cell
        }, titleForHeaderInSection: { (datasource, index) -> String? in
            return datasource.sectionModels[index].model
        })
    }
    
    func bind() {
        let items: Observable<[GroupSection]> = Observable.zip(GroupListAPI.groupList(), GroupListAPI.categoryList()) { (groups: [Group], categories: [Category]) -> [GroupSection] in
            categories.map {
                category -> GroupSection in
                let categoryGroups = groups.filter {
                    group -> Bool in
                    group.categoryID == category.ID
                }
                return GroupSection(model: category.name, items: categoryGroups)
            }
        }
        
        items.bind(to: tv.rx.items(dataSource: createDatasource())).disposed(by: disposeBag)
    }
}

struct Group {
    let name: String
    let categoryID: Int
    let ID: Int
}

struct Category {
    let name: String
    let ID: Int
    let groups: [Int]
}


struct GroupListAPI {
    static func groupList() -> Observable<[Group]> {
        let groupList: [Group] = [
            Group(name: "첫번째 그룹", categoryID: 1, ID: 1),
            Group(name: "두번째 그룹", categoryID: 1, ID: 2),
            Group(name: "세번째 그룹", categoryID: 1, ID: 3),
            Group(name: "네번째 그룹", categoryID: 2, ID: 4),
            Group(name: "다섯번째 그룹", categoryID: 2, ID: 5),
            Group(name: "여섯번째 그룹", categoryID: 2, ID: 6),
            Group(name: "일곱번째 그룹", categoryID: 2, ID: 7),
            Group(name: "여덟번째 그룹", categoryID: 3, ID: 8),
            Group(name: "아홉번째 그룹", categoryID: 3, ID: 9),
            Group(name: "열번째 그룹", categoryID: 3, ID: 10),
            Group(name: "열한번째 그룹", categoryID: 3, ID: 11),
            Group(name: "열두번째 그룹", categoryID: 4, ID: 12),
            Group(name: "열세번째 그룹", categoryID: 4, ID: 13)
        ]
        
        return Observable.just(groupList).delay(0.5, scheduler: MainScheduler.instance)
    }
    
    static func categoryList() -> Observable<[Category]> {
        let categoryList: [Category] = [
            Category(name: "첫번째 카테고리", ID: 1, groups: [1, 2, 3]),
            Category(name: "두번째 카테고리", ID: 2, groups: [4, 5, 6, 7]),
            Category(name: "세번째 카테고리", ID: 3, groups: [8, 9, 10, 11]),
            Category(name: "네번째 카테고리", ID: 4, groups: [12, 13])
        ]
        
        return Observable.just(categoryList).delay(0.7, scheduler: MainScheduler.instance)
    }
}
