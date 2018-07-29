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

class SetUpViewController: UIViewController {
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: SaveEventProtocol?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.titleText.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        contentText.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.contentText.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        saveButton.rx.tap.subscribe { onNext in
            let date = self.picker.date
            let title = self.titleText.text ?? ""
            let content = self.contentText.text ?? ""
            self.delegate?.didSaveEvent(Event(title: title, content: content, time: date))
            
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        cancelButton.rx.tap.subscribe { onNext in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
}
