//
//  TaskCreatorViewController.swift
//  TaskTrackr
//
//  Created by Eric Ho on 8/10/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import UIKit
import Former

class TaskEditorViewController: FormViewController {
    
    var currentTask: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config custom navigation bar items
        setCustomNavigationItem()
        
        // build editor form
        buildEditor()
    }
    
    // reset select state
    override func viewWillAppear(_ animated: Bool) {
        former.deselect(animated: animated)
    }
    
    @objc func onDonePressed() {
        // create a new task
        saveNewTask()
    }
    
    func setCustomNavigationItem() {
        // set right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(onDonePressed))
        // set back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    // build user input entry
    func buildEditor() {
        
        // Section Header creator
        let createHeader : ((String) -> ViewFormer ) = { text in
            return LabelViewFormer<FormLabelHeaderView>().configure {
                $0.text = text
                $0.viewHeight = 44
            }
        }
        
        // Menu creator
        let createMenu : ((String, String, (() -> Void)?) -> RowFormer) = { (text, subText, onSelected) in
            return LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.textColor = .formerColor()
                $0.titleLabel.font = .boldSystemFont(ofSize: 16)
                $0.accessoryType = .disclosureIndicator
                }.configure {
                    $0.text = text
                    $0.subText = subText
                }.onSelected({ _ in
                    onSelected?()
                })
        }
        
        // necessary elements: 1.title, 2.desc, 3.service, 4.designated workers, 5.due date, 6.location, 7.ref images
        // MARK: Enter Title
        let titleField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Task Title"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "e.g. "
                $0.text = ""
            }.onTextChanged { (text) in

        }
        // MARK: Enter Desc
        let descField = TextViewRowFormer<FormTextViewCell>() {
            $0.titleLabel.text = "Description"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Add Task Introduction"
                $0.text = ""
            }.onTextChanged { (text) in
                // save Task desc
        }
        
        // MARK: Select Service: Single Selection
        let serviceSelector = createMenu("Select Service", Static.none_selected) { [weak self] in
            // perform segue here:
            self?.performSegue(withIdentifier: Static.segue_openServicePicker, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        
        // MARK: Pickup Designated Workers: Multi Selection
        let workerSelector = createMenu("Designate Workers", Static.none_selected) { [weak self] in
            // perform segue here:
            self?.performSegue(withIdentifier: Static.segue_openWorkerPicker, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        // MARK: Select Due Date of Task
        let dueDatePicker = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Due Date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .boldSystemFont(ofSize: 14)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .dateAndTime
            }.configure {
                $0.displayEditingColor = .formerHighlightedSubColor()
            }.displayTextFromDate(String.mediumDateShortTime)
        // MARK: Search&Pickup Location
        let locationSelector = createMenu("Location", Static.address_required) {[weak self] in
            // perform segue here:
            self?.performSegue(withIdentifier: Static.segue_openLocationSelector, sender: self)
        }
        // MARK: Upload Images
        
        let sectionBasic = SectionFormer(rowFormer: titleField, descField).set(headerViewFormer: createHeader("Basic Task Info"))
        let sectionSelectors = SectionFormer(rowFormer: serviceSelector!, workerSelector!, locationSelector)
        let sectionDatePicker = SectionFormer(rowFormer: dueDatePicker)
        former.append(sectionFormer: sectionBasic, sectionSelectors, sectionDatePicker)
    }

    func saveNewTask() {
        if currentTask == nil {
            currentTask = Task()
            // set task properties...
            //
            //
            DatabaseService.shared.addNewTask(task: currentTask!)
        }
    }
}

extension TaskEditorViewController {
    // prepare info for different segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Static.segue_openWorkerPicker:
            print("worker")
            break
        case Static.segue_openServicePicker:
            print("service")
            break
        case Static.segue_openLocationSelector:
            break
        case Static.segue_openPicturePicker:
            print("picture")
            break
        default:
            break
        }
    }
}