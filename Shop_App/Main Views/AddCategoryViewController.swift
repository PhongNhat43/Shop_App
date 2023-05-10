//
//  AddCategoryViewController.swift
//  Shop_App
//
//  Created by devsenior on 14/04/2023.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddCategoryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!

    //Mark: Vars
    var category: Category!
    var gallery: GalleryController!
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    var categoryImages: [UIImage?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
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
        categoryImages = []
        showImageGallery()

    }

    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeayboard()
    }

    //Mark: Helper functions
    private func fieldsAreCompleted()-> Bool {
        return (titleTextField.text != "")
    }

    private func dismissKeayboard() {
        self.view.endEditing(false)
    }

    private func popTheView() {
        self.navigationController?.popViewController(animated: true)
    }

    //Mark: save cateogry
    private func saveToFireBase(){
        showLoadingIndicator()
        let category = Category()
        category.id = UUID().uuidString
        category.name = titleTextField.text!

           if categoryImages.count > 0 {
               uploadImages(images: categoryImages, itemId: category.id) { (imageLikArray) in
                   category.imageCategoryLinks = imageLikArray
                   saveCategoryToFirebase(category)
                   self.popTheView()
               }
           } else {
              saveCategoryToFirebase(category)
               self.hideLoadingIndicator()
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

extension AddCategoryViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
                self.categoryImages = resolvedImages
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
