//
//  AddItemFormController.swift
//  TaskTrackr
//
//  Created by Eric Ho on 7/09/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import UIKit
import Former
import TagListView

class ItemFormController: FormViewController {
    
    // client page identifer
    var clientPage: String = ""
    // current item
    var currentAction: Action?
    var currentWorker: Worker?
    var currentProduct: Product?
    var currentTool: Tool?
    var currentSite: Site?
    
    // for product
    var tagListView: TagListView?
    var productName: String = ""
    var productDesc: String = ""
    
    // for worker
    var firstName: String = ""
    var lastName: String = ""
    
    // for tool
    var toolName: String = ""
    var toolDesc: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        // build form
        switch clientPage {
        case Static.action_page:
            buildActionForm()
        case Static.worker_page:
            buildWorkerForm()
        case Static.product_page:
            buildProductForm()
        case Static.tool_page:
            buildToolForm()
        case Static.site_page:
            buildSiteForm()
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        former.deselect(animated: animated)
    }
    
    @objc func donePressed() {
        var isSaved: Bool = false
        
        switch clientPage {
        case Static.action_page:
            isSaved = saveActionForm()
        case Static.worker_page:
            isSaved = saveWorkerForm()
        case Static.product_page:
            isSaved = saveProductForm()
        case Static.tool_page:
            isSaved = saveToolForm()
        case Static.site_page:
            isSaved = saveSiteForm()
        default:
            break
        }
        
        // if chose present modally call "dismiss", otherwise, call this:
        if isSaved {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // Section Header
    let createHeader : ((String) -> ViewFormer ) = { text in
        return LabelViewFormer<FormLabelHeaderView>().configure {
            $0.text = text
            $0.viewHeight = 44
        }
    }
    
    // Menu
    let createMenu : ((String, (() -> Void)?) -> RowFormer) = { (text, onSelected) in
        return LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.accessoryType = .disclosureIndicator
            }.configure {
                $0.text = text
            }.onSelected({ _ in
                onSelected?()
            })
    }
    
    // selector
    let createSelectorRow = { (
        text: String,
        subText: String,
        onSelected: ((RowFormer) -> Void)?
        ) -> RowFormer in
        return LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.subTextLabel.textColor = .formerSubColor()
            $0.subTextLabel.font = .boldSystemFont(ofSize: 14)
            $0.accessoryType = .disclosureIndicator
            }.configure { form in
                _ = onSelected.map { form.onSelected($0) }
                form.text = text
                form.subText = subText
        }
    }
    
    private func sheetSelectorRowSelected(options: [String]) -> (RowFormer) -> Void {
        return { [weak self] rowFormer in
            if let rowFormer = rowFormer as? LabelRowFormer<FormLabelCell> {
                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                options.forEach { title in
                    sheet.addAction(UIAlertAction(title: title, style: .default, handler: { [weak rowFormer] _ in
                        rowFormer?.subText = title
                        rowFormer?.update()
                    })
                    )
                }
                sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self?.present(sheet, animated: true, completion: nil)
                self?.former.deselect(animated: true)
            }
        }
    }
    
    // build Action form
    func buildActionForm(){}
    // save Action form
    func saveActionForm() -> Bool {
        return true
    }
    // build Workder form
    func buildWorkerForm() {
        // worker first name
        let firstNameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "First Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "First Name"
                $0.text = currentWorker != nil ? currentWorker?.firstName : ""
                firstName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.firstName = text
        }
        
        // worker last name
        let lastNameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Last Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "Last Name"
                $0.text = currentWorker != nil ? currentWorker?.lastName : ""
                lastName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.lastName = text
        }
        
        let sectionBasic = SectionFormer(rowFormer: firstNameField, lastNameField).set(headerViewFormer: createHeader("Basic Worker Info"))
        
        // worker role
        let options = ["Worker", "Senior Worker", "Lead Worker", "Expert"]
        let roleRow = createSelectorRow("Role", options[0], sheetSelectorRowSelected(options: options))
        let sectionRole = SectionFormer(rowFormer: roleRow).set(headerViewFormer: createHeader("Role"))
        former.append(sectionFormer: sectionBasic, sectionRole)
    }
    
    func saveWorkerForm() -> Bool {
        return true
    }
    
    // build Product form
    func buildProductForm() {
        
        // product name
        let nameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Product Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "Product Name"
                $0.text = currentProduct != nil ? currentProduct?.productName : ""
                productName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.productName = text
        }
        // product desc
        let descField = TextViewRowFormer<FormTextViewCell>() {
            $0.titleLabel.text = "Description"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Add product introduction."
                $0.text = currentProduct != nil ? currentProduct?.productDesc : ""
                productDesc = $0.text!
            }.onTextChanged { (text) in
                // save product desc
                self.productDesc = text
        }
        
        let sectionBasic = SectionFormer(rowFormer: nameField, descField).set(headerViewFormer: createHeader("Basic Product Info"))
        
        // models
        let tagRow = CustomRowFormer<TagTableViewCell>(instantiateType: .Nib(nibName: "TagTableViewCell")) {
            let models: [String] = self.initialModelArray().map {
                return $0.modelName!
            }
            $0.modelTagList.addTags(models)
            // save member variable tagListView
            self.tagListView = $0.modelTagList
            }.configure {
                $0.rowHeight = UITableView.automaticDimension
        }
        let tagControl = CustomRowFormer<TagControlTableViewCell>(instantiateType: .Nib(nibName: "TagControlTableViewCell")) {
            $0.onAddPressed = { newTagName in
                // text from the textField in TagControlTableViewCell
                if !newTagName.isEmpty {
                    self.tagListView?.addTag(newTagName)
                    
                    // in order to update the custom cell height
                    self.tableView.reloadData()
                }
            }
        }
        
        let sectionModels = SectionFormer(rowFormer: tagRow, tagControl).set(headerViewFormer: createHeader("Product Models"))
        former.append(sectionFormer: sectionBasic, sectionModels)
    }
    
    // initial model array
    func initialModelArray() -> [Model] {
        if (currentProduct == nil) {
            return []
        } else {
            let models: [Model] = DatabaseService.shared.getModelArray(in: currentProduct!)
            return models
        }
    }
    
    // changed model array
    func changedModelArray() -> [Model] {
        let tagViews: [TagView] = (tagListView?.tagViews)!
        let models: [Model] = tagViews.map {
            let model = Model()
            model.modelName = $0.titleLabel?.text
            model.product = currentProduct
            return model
        }
        return models
    }

    // save Product form
    func saveProductForm() -> Bool {
        guard !productName.isEmpty else {
            Static.showToast(toastText: "Please provide a product name.")
            return false
        }
        
        if (currentProduct == nil) {
            // create a new item
            currentProduct = Product()
            currentProduct?.productName = productName
            currentProduct?.productDesc = productDesc
            let list = DatabaseService.shared.arrayToList(from: changedModelArray())
            currentProduct?.models = list
            // add to database
            DatabaseService.shared.addProduct(with: currentProduct!)
        } else {
            // edit an existing item
            DatabaseService.shared.updateProduct(for: currentProduct!, with: productName, with: productDesc, with: changedModelArray())
        }
        
        // save models
        DatabaseService.shared.saveModels(to: currentProduct!, with: changedModelArray())
        
        return true
    }
    
    // build Tool form
    func buildToolForm() {
        // Tool name
        let nameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Tool Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "Tool Name"
                $0.text = currentTool != nil ? currentTool?.toolName : ""
                toolName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.toolName = text
        }
        // Tool desc
        let descField = TextViewRowFormer<FormTextViewCell>() {
            $0.titleLabel.text = "Description"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Add tool introduction."
                $0.text = currentTool != nil ? currentTool?.toolDesc : ""
                toolDesc = $0.text!
            }.onTextChanged { (text) in
                // save product desc
                self.toolDesc = text
        }
        let sectionBasic = SectionFormer(rowFormer: nameField, descField).set(headerViewFormer: createHeader("Tool Info"))
        
        former.append(sectionFormer: sectionBasic)
    }
    // save Tool form
    func saveToolForm() -> Bool {
        guard !toolName.isEmpty else {
            Static.showToast(toastText: "Please enter a tool name.")
            return false
        }
        
        if currentTool == nil {
            // create a new tool
            currentTool = Tool()
            currentTool?.toolName = toolName
            currentTool?.toolDesc = toolDesc
            // save to database
            DatabaseService.shared.addObject(for: currentTool!)
        } else {
            // update existing tool
            DatabaseService.shared.updateTool(for: currentTool!, with: toolName, with: toolDesc)
        }
        return true
    }
    // build Site form
    func buildSiteForm() {}
    // save Site form
    func saveSiteForm() -> Bool {
        return true
    }
}
