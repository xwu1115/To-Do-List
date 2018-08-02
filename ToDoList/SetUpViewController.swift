//
//  SetUpViewController.swift
//  ToDoList
//
//  Created by Shawn Wu on 7/18/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
protocol SaveEventProtocol: class {
    func didSaveEvent(_ event: Event)
}

class SetUpViewController: UIViewController, CategoryPickerDelegate {
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    private var selectedCategory: EventCategory = .other
    weak var delegate: SaveEventProtocol?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleText.text = selectedCategory.stringValue
        titleText.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        titleText.addGestureRecognizer(tapGesture)
        
        contentText.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.contentText.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        saveButton.rx.tap.subscribe { onNext in
            let date = self.picker.date
            let content = self.contentText.text ?? ""
            self.delegate?.didSaveEvent(Event(content: content, time: date, category: self.selectedCategory))
            
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    func didSelect(category: EventCategory) {
        titleText.text = category.stringValue
        selectedCategory = category
    }
    
    @objc func buttonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "category") as? CategoryPickerViewController {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
