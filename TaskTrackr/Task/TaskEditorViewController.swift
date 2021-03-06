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
    
    // for private data:
    var currentTask: Task?
    var taskTitle: String = ""
    var desc: String = ""
    var service: Service?
    var productConsumptions: [ProductConsumption]?
    var selectedWorkers: [Worker] = []
    var locationTuple: LocationTuple?
    var dueDate: Date?
    var images: [UIImage] = []
    var taskState: TaskLog.TaskState = TaskLog.TaskState.created
    enum Selector {
        case service
        case workers
        case location
        case pictures
    }
    
    // for UI:
    var titleField: TextFieldRowFormer<FormTextFieldCell>?
    var descField: TextViewRowFormer<FormTextViewCell>?
    var locationSelector: LabelRowFormer<FormLabelCell>?
    var pictureSelector: LabelRowFormer<FormLabelCell>?
    var workerSelector: LabelRowFormer<FormLabelCell>?
    var serviceSelector: LabelRowFormer<FormLabelCell>?
    var dueDatePicker: InlineDatePickerRowFormer<FormInlineDatePickerCell>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config custom navigation bar items
        setCustomNavigationItem()
        // extract properties
        extractCurrentTask()
        // build editor form
        buildEditor()
        // update menu subTitle for selectors
        if let task = currentTask {
            updateSelectorSubText(on: .service, task.service!.serviceTitle)
            updateSelectorSubText(on: .workers, task.workers.count)
            updateSelectorSubText(on: .pictures, task.images.count)
            updateSelectorSubText(on: .location, task.address)
        }
    }
    
    // reset select state
    override func viewWillAppear(_ animated: Bool) {
        former.deselect(animated: animated)
    }
    
    // MARK: -- onDonePressed
    @objc func onDonePressed() {
        // verify input
        guard verifyInput() else {return}
        // save edited task
        let spinner = AutoActivityIndicator(self.view, style: .gray)
        spinner.start()
        saveTask()
        spinner.stop()
        // pop current view controller
        navigationController?.popViewController(animated: true)
    }
    
    func verifyInput() -> Bool {
        // title: optional
        if taskTitle.isEmpty {
            print("taskTitle.isEmpty")
//            return false
        }
        // desc: optional
        if desc.isEmpty {
            print("")
//            return false
        }
        // service
        if service == nil {
            print("service is nil")
            return false
        }
        // workers
        if selectedWorkers.isEmpty {
            print("no workers selected")
            return false
        }
        // address
        if locationTuple == nil {
            print("no address")
            return false
        }
        // images (optional)
        // due date
        if dueDate == nil {
            print("no date")
            return false
        }
        
        return true
    }
    
    func setCustomNavigationItem() {
        // set right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(onDonePressed))
        // set back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        // set view title
        self.title = currentTask == nil ? "New Task" : "Edit Task"
    }
    
    // extract properties from currentTask object
    func extractCurrentTask() {
        if let task = currentTask {
            taskTitle = task.taskTitle
            desc = task.taskDesc
            service = task.service
            locationTuple = LocationTuple(task.address, task.latitude, task.longitude)
            dueDate = task.dueDate
            selectedWorkers = DatabaseService.shared.workerListToArray(from: task.workers)
            for data in task.images {
                images.append(UIImage(data: data)!)
            }
            // product consumption
            var consumes: [ProductConsumption] = []
            consumes.append(contentsOf: task.productConsumptions)
            self.productConsumptions = consumes
        }
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
        titleField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Task Title"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "(Optional)"
                $0.text = taskTitle
            }.onTextChanged { (text) in
                self.taskTitle = text
        }
        // MARK: Enter Desc
        descField = TextViewRowFormer<FormTextViewCell>() {
            $0.titleLabel.text = "Description"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "(Optional)"
                $0.text = desc
            }.onTextChanged { (text) in
                // save Task desc
                self.desc = text
        }
        
        // MARK: Select Service: Single Selection
        serviceSelector = createMenu("💁 Select Service", Static.none_selected) { [weak self] in
            // perform segue here:
            self?.performSegue(withIdentifier: Static.segue_openServicePicker, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        
        // MARK: Pickup Designated Workers: Multi Selection
        workerSelector = createMenu("👷 Designate Workers", Static.none_selected) { [weak self] in
            // perform segue here:
            self?.performSegue(withIdentifier: Static.segue_openWorkerPicker, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        // MARK: Select Due Date of Task
        dueDatePicker = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "📆 Select Deadline"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .boldSystemFont(ofSize: 14)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .date
            }.configure {
                $0.displayEditingColor = .formerHighlightedSubColor()
                if let date = self.dueDate {
                    $0.date = date
                }
            }.onDateChanged({
                self.dueDate = $0
            }).displayTextFromDate(String.mediumDateNoTime)
        // MARK: Search Location
        locationSelector = createMenu("📍 Address", Static.not_set) {[weak self] in
            // perform segue here:
            self?.performSegue(withIdentifier: Static.segue_openLocationSelector, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        // MARK: Upload Images
        pictureSelector = createMenu("🖼️ Upload Pictures", Static.not_set) {[weak self] in
            // perform segue here:
            self?.performSegue(withIdentifier: Static.segue_openPicturePicker, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        let sectionBasic = SectionFormer(rowFormer: titleField!, descField!).set(headerViewFormer: createHeader("Basic Task Info"))
        let sectionSelectors = SectionFormer(rowFormer: serviceSelector!, workerSelector!)
        let sectionLocationSelector = SectionFormer(rowFormer: locationSelector!)
        let sectionUploadPicture = SectionFormer(rowFormer: pictureSelector!)
        let sectionDatePicker = SectionFormer(rowFormer: dueDatePicker!)
        former.append(sectionFormer: sectionBasic, sectionSelectors, sectionLocationSelector, sectionUploadPicture, sectionDatePicker)
    }
    
    func saveTask() {
        if currentTask == nil {
            currentTask = Task()
            DatabaseService.shared.addTask(add: self.currentTask!, self.taskTitle, self.desc, service: self.service!, workers: self.selectedWorkers, deadline: self.dueDate!, locationTuple: self.locationTuple!, productConsumptions: self.productConsumptions, images: self.images, taskState: self.taskState, update: false)
        } else {
            DatabaseService.shared.addTask(add: self.currentTask!, self.taskTitle, self.desc, service: self.service!, workers: self.selectedWorkers, deadline: self.dueDate!, locationTuple: self.locationTuple!, productConsumptions: self.productConsumptions, images: self.images, taskState: self.taskState, update: true)
        }
    }
}

// MARK: - prepare info for segues, ui update
extension TaskEditorViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Static.segue_openWorkerPicker:
            let workerPicker = segue.destination as! WorkerPickerViewController
            workerPicker.selectedWorkers = self.selectedWorkers
            workerPicker.workerPickerDelegate = self
        case Static.segue_openServicePicker:
            let servicePicker = segue.destination as! ServicePickerViewController
            servicePicker.title = "Select Service"
            servicePicker.service = self.service
            servicePicker.servicePickerDelegate = self
            break
        case Static.segue_openLocationSelector:
            let locationSelector = segue.destination as! LocationSelectViewController
            locationSelector.locationTuple = locationTuple
            // set delegate
            locationSelector.delegate = self
        case Static.segue_openPicturePicker:
            let picPicker = segue.destination as! PicPickerViewController
            // assign images
            picPicker.images = self.images
            // set delegate
            picPicker.delegate = self
        default:
            break
        }
    }
    
    // update selector subtext
    private func updateSelectorSubText(on selector: Selector, _ selection: Any?) {
        switch selector {
        case .service:
            if let subText = selection as? String {
                serviceSelector?.subText = subText
                serviceSelector?.update()
            }
            
        case .workers:
            if let count = selection as? Int {
                let subText = String(format: count > 1 ? "%d workers" : "%d worker", count)
                workerSelector?.subText = subText
                workerSelector?.update()
            }
        case .location:
            let address = selection as? String
            // trim the string
            let subText = Static.trimString(for: address, to: 25, true)
            locationSelector?.subText = subText
            locationSelector?.update()
        case .pictures:
            if let count = selection as? Int {
                let subText = String(format: count > 1 ? "%d Pictures": "%d Picture", count)
                pictureSelector?.subText = subText
                pictureSelector?.update()
            }
        }
    }
}

// MARK: - LocationSelectorDelegate, PicturePickerDelegate
extension TaskEditorViewController: LocationSelectorDelegate, PicturePickerDelegate,
WorkerPickerDelegate, ServicePickerDelegate {
    
    // LocationSelectorDelegate
    func onLocationReady(location: LocationTuple) {
        // update local property: locationTuple
        locationTuple = location
        // update location selector menu
        updateSelectorSubText(on: .location, location.address)
    }
    
    // PicturePickerDelegate
    func onPictureSelectionFinished(images: [UIImage]) {
        // collect images to inner property.
        self.images = images
        // update subtitle for selector menu
        let count = images.count
        
        updateSelectorSubText(on: .pictures, count)
    }
    
    // WorkerPickerDelegate
    func selectionDidFinish(selectedWorkers: [Worker]) {
        // receive selected result
        self.selectedWorkers = selectedWorkers
        // update ui
        updateSelectorSubText(on: .workers, selectedWorkers.count)
    }
    
    // ServicePickerDelegate
    func selectionDidFinish(service: Service) {
        self.service = service
        updateSelectorSubText(on: .service, service.serviceTitle)
        // set the title same as service title
        titleField?.text = service.serviceTitle!
        titleField?.update()
        taskTitle = (titleField?.text)!
        // set the desc displying the product list and tool list
        if let nav = navigationController {
            let numberControl = NumberControlListController()
            var dataList = [ItemData]()
            for model in service.models {
                var itemData = ItemData()
                itemData.itemName = model.modelName!
                itemData.numberOfItem = 0
                dataList.append(itemData)
            }
            // convert model list to required data structure
            let tuples = DatabaseService.shared.convertProductsInServiceToTuplesByGroup(service: self.service)
            let dataTuples = tuples.map({(product: Product, models: [ProductModel]) -> DataTuple in
                return (category: product.productName!, items: models.map({ (model) -> ItemData in
                    var number = 0
                    if let _ = self.productConsumptions?.contains(where: { (consumption) -> Bool in
                        if consumption.productModel == model {
                            number = consumption.consumedNumber
                            return true
                        }
                        return false
                    }) {}
                    return ItemData(model.modelName, number)
                }))
            })
            // deliver datatuples
            numberControl.dataTuples = dataTuples
            // set handler when value in datatuples get ready
            numberControl.dataTuplesGetReady = {(tuples) in
                // extract the tuples received as product consumption list
                var items: [ItemData] = []
                for tuple in tuples {
                    for item in tuple.items {
                        items.append(item)
                    }
                }
                var consumptions: [ProductConsumption] = []
                let numberOfItems = items.count
                for i in 0..<numberOfItems {
                    if service.models[i].modelName == items[i].itemName {
                        let consume = ProductConsumption()
                        consume.productModel = service.models[i]
                        consume.consumedNumber = items[i].numberOfItem
                        consume.alreadyConsumed = false
                        consume.timestamp = Date()
                        consumptions.append(consume)
                    } else {
                        print("Incorrect product model")
                    }
                }
                self.productConsumptions = consumptions
            }
            // show
            nav.pushViewController(numberControl, animated: false)
        }
    }
}
