//
//  AddItemViewController.swift
//  Shop_App
//
//  Created by devsenior on 31/03/2023.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddItemViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var percentSale: UITextField!
    
    @IBOutlet weak var pickerSize: UIPickerView!
    //Mark: Vars
    var category: Category!
    var gallery: GalleryController!
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    var itemImages: [UIImage?] = []
    
    let sizes = ["37", "38", "39", "40"]
    var selectedSize: Int?
    
    //Mark:View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerSize.delegate = self
        pickerSize.dataSource = self
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.width / 2 - 30, width: 60, height: 60), type: .ballPulse, color: UIColor(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1), padding: nil)
    }
    
    @IBAction func doneBarButtonItem(_ sender: Any) {
        dismissKeayboard()
        
        if fieldsAreCompleted() {
            saveToFireBase()
            
        } else {
            self.hud.textLabel.text = "All fields are required!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        itemImages = []
        showImageGallery()
        
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeayboard()
    }
    
    //Mark: Helper functions
    private func fieldsAreCompleted()-> Bool {
        if pickerSize.selectedRow(inComponent: 0) == 0 {
                // Khi pickerSize không được chọn
                let alertController = UIAlertController(title: "Lỗi", message: "Vui lòng lựa chọn kích cỡ", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Đóng", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
                return false
            }
        return (titleTextField.text != "" && priceTextField.text != "" && descriptionTextView.text != "" && percentSale.text != "")
    }
    
    
    private func dismissKeayboard() {
        self.view.endEditing(false)
    }
    
    private func popTheView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark: Save Item
    private func saveToFireBase() {
        showLoadingIndicator()
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text!
        item.categoryId = category.id
        item.description = descriptionTextView.text
        item.price = Double(priceTextField.text!)
        item.percentSale = percentSale.text
        if let selectedSize = selectedSize {
             item.availableSizes = [sizes[selectedSize]]
         }
        
        if itemImages.count > 0 {
            uploadImages(images: itemImages, itemId: item.id) { (imageLikArray) in
                item.imageLinks = imageLikArray
                saveItemToFirestore(item)
                saveItemToAlolia(item: item)
                self.hideLoadingIndicator()
                self.popTheView()
            }
        } else {
            saveItemToFirestore(item)
            saveItemToAlolia(item: item)
            popTheView()
        }
    }
    //Mark: Activity Indicator
    private func showLoadingIndicator(){
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator(){
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
    //Mark: show Gallery
    private func showImageGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self

        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 6
        self.present(self.gallery, animated: true, completion: nil)
    }
}

extension AddItemViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages = resolvedImages
            }

        }
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }


}

extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // We only have one column for the size picker
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizes.count // The number of rows is equal to the number of sizes in the array
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sizes[row] // Set the title of each row to the corresponding size in the array
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSize = row // Update the selectedSize variable with the index of the selected row
    }
}

