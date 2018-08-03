//
//  CategoryPickerViewController.swift
//  ToDoList
//
//  Created by Shawn Wu on 8/1/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//

import UIKit
import  RxSwift
protocol CategoryPickerDelegate: class {
    func didSelect(category: EventCategory)
}
class CategoryPickerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private let vm = CategoryPickerTableViewModel()
    weak var delegate: CategoryPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vm.setup(tableView: tableView)
        vm.selected.asObservable().subscribe { (category) in
            self.delegate?.didSelect(category: category.element ?? .other)
        }.disposed(by: disposeBag)
    }
}

class CategoryPickerTableViewModel {
    private let disposeBag = DisposeBag()
    private(set) var selected: Variable<EventCategory> = Variable<EventCategory>(EventCategory.other)
    private let dataSource: Variable<[EventCategory]> = Variable<[EventCategory]>([.lifeStyle, .money, .workout, .other, .study, .grocery])
    
    func setup(tableView: UITableView) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        dataSource.asObservable().bind(to: tableView.rx.items(cellIdentifier: "category", cellType: UITableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = item.stringValue
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe { indexPath in
            if let indexPath = indexPath.element {
                let row = indexPath.row
                self.selected.value = self.dataSource.value[row]
            }
        }.disposed(by: disposeBag)
    }
}
