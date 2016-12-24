//
//  ViewController.swift
//  YHRefreshTableViewSwift
//
//  Created by YHIOS002 on 16/12/21.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var numberOfRows:Int = 3
    var tableView:UITableView = UITableView()
    var refreshHeader:YHRefreshHeaderView? = nil
    var refreshFooter:YHRefreshFooterView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tbv = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-64), style: .plain)
        tbv.delegate = self
        tbv.dataSource = self
        tbv.rowHeight = 44
        self.view.addSubview(tbv)
        tableView = tbv
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        setupHeader()
        setupFooter()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell.textLabel?.text = "第\(indexPath.row)行"
        return cell
    }
    
    private func setupHeader() {
        
        let refreshHeader = YHRefreshHeaderView.refreshViewWithStyle(style: .classical)
        
        refreshHeader.addToScrollView(scrollView: tableView)
        self.refreshHeader = refreshHeader as? YHRefreshHeaderView
        
        self.refreshHeader?.beginRefreshingOperation = {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                self.numberOfRows += 3
                self.refreshHeader?.endRefreshing()
                self.tableView.reloadData()
            }
        }

        
    }
    
    private func setupFooter() {
        let refreshFooter = YHRefreshFooterView.refreshViewWithStyle(style: .classical)
        refreshFooter.addToScrollView(scrollView: tableView)
        refreshFooter.addTarget(target: self, refreshAction: #selector(footerRefresh))
        self.refreshFooter = refreshFooter as? YHRefreshFooterView
        self.refreshFooter?.beginRefreshingOperation = {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                self.numberOfRows += 3
                self.refreshFooter?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func footerRefresh(){
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

