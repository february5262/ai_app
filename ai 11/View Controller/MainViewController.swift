//
//  MainViewController.swift
//  ai 11
//
//  Created by 조윤경 on 3/31/24.
//

import UIKit

// 사용하고자 하는 프로토콜을 추가 해줌
class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let sampleData = SampleData()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dataSource, delegate을 self로 지정
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    //using large title when view appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    //no using large title when view disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sampleData.samples.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"mainFeatureCell", for: indexPath) as! MainFeatureCell
        
        let sample = self.sampleData.samples[indexPath.row]
        cell.titleLabel.text = sample.title
        cell.descriptionLabel.text = sample.description
        cell.featuredImageView.image = UIImage(named: sample.image)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //default selection 해제
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:self.performSegue(withIdentifier: "photoObjectDetection", sender: nil)
        case 1:self.performSegue(withIdentifier: "realTimeObjectDetection", sender: nil)
        case 2:self.performSegue(withIdentifier: "facialAnalysis", sender: nil)
        default:
            return
        }
    }
}
