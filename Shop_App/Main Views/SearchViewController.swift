//
//  SearchViewController.swift
//  Shop_App
//
//  Created by devsenior on 13/04/2023.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift
class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchOptionsView: UIView!
    
    @IBOutlet weak var searchTF: UITextField!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        searchTF.addTarget(self, action: #selector(self.textFieldidChange(_:)), for: UIControl.Event.editingChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.width / 2 - 30, width: 60, height: 60), type: .ballPulse, color: UIColor(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1), padding: nil)
    }
    
    //Mark: Vars
    var searchResults: [Item] = []
    var activityIndicator: NVActivityIndicatorView?
    
    @IBAction func showSearchBtnPressed(_ sender: Any) {
        dismissKeyBoard()
        showSeachField()
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        if searchTF.text != "" {
          //search
            searchInFireBase(forName: searchTF.text!)
          emptyTextField()
         animateSearchOptionsIn()
            dismissKeyBoard()
        }
    }
    
    //Mark: -Search databse
    private func searchInFireBase(forName: String) {
      showLoadingIndicator()
      
        searchAlgolia(searchString: forName) { (itemIds) in
            downloadItems(itemIds) { (allItems) in
                self.searchResults = allItems
                self.tableView.reloadData()
                self.hideLoadingIndicator()
            }
        }
    }
    
    //Mark: Helper
    private func emptyTextField(){
        searchTF.text = ""
    }
    
    private func dismissKeyBoard(){
        self.view.endEditing(false)
    }
    
    @objc func textFieldidChange (_ textField: UITextField){
      
        searchBtn.isEnabled = textField.text != ""
        
        if searchBtn.isEnabled {
            searchBtn.backgroundColor = .red
        }else {
           disableSearchBtn()
        }
    }
    
    private func disableSearchBtn(){
        searchBtn.isEnabled = false
        searchBtn.backgroundColor = .gray
    }
    
    private func showSeachField(){
       disableSearchBtn()
        emptyTextField()
        animateSearchOptionsIn()
    }
    
    private func animateSearchOptionsIn(){
        UIView.animate(withDuration: 0.5) {
            self.searchOptionsView.isHidden = !self.searchOptionsView.isHidden
        }
    }
    
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
    
    private func showItemView(withItem: Item){
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    

}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: searchResults[indexPath.row])
    }
    

}

extension SearchViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to display")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return UIImage(named: "search")
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return NSAttributedString(string: "Start searching...")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
       showSeachField()
    }

}
