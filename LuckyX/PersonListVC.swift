//
//  PersonListVC.swift
//  LuckyX
//
//  Created by XuWeinan on 2018/11/16.
//  Copyright © 2018 XuWeinan. All rights reserved.
//

import UIKit
import RealmSwift

class PersonListVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var leftPersons:[Person]?
    var rightPersons:[Person]?
    
    @IBOutlet var leftTableView: UITableView!
    @IBOutlet var rightTableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTwoLists()
        leftTableView.delegate = self
        leftTableView.dataSource = self
        rightTableView.delegate = self
        rightTableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func initTwoLists(){
        let realm = try! Realm()
        leftPersons = Array(realm.objects(Person.self).filter("isAvailable = true"))
        leftPersons?.sort(by: { (person1, person2) -> Bool in
            return person1.number < person2.number
        })
        rightPersons = Array(realm.objects(Person.self).filter("isAvailable = false"))
        //对中奖人员排序
        rightPersons?.sort(by: { (person1, person2) -> Bool in
            if color2Number(color: person1.color) != color2Number(color: person2.color){
                return color2Number(color: person1.color) < color2Number(color: person2.color)
            }else{
                return person1.number < person2.number
            }
        })
        //初始化title
        self.navigationItem.title = "抽奖列表(\(leftPersons?.count.description ?? "NaN")/\(rightPersons?.count.description ?? "NaN"))"
        
        //测试用，统计各颜色是多少人
        var purple = 0
        var red = 0
        var green = 0
        var yellow = 0
        var blue = 0
        var pink = 0
        for person in rightPersons!{
            switch person.color{
            case "紫":
                purple += 1
            case "红":
                red += 1
            case "绿":
                green += 1
            case "黄":
                yellow += 1
            case "蓝":
                blue += 1
            case "粉":
                pink += 1
            default:
                break
            }
        }
        print("紫色:\(purple)\n红色:\(red)\n绿色:\(green)\n黄色:\(yellow)\n蓝色:\(blue)\n粉色:\(pink)\n")
    }
    /**将颜色转换成数值*/
    func color2Number(color:String) -> Int{
        switch color {
        case "紫":
            return 1
        case "红":
            return 2
        case "绿":
            return 3
        case "黄":
            return 4
        case "蓝":
            return 5
        case "粉":
            return 6
        default:
            return 0
        }
    }
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! LeftPersonCell
            cell.name.text = leftPersons![indexPath.row].name
            var numberStr = leftPersons![indexPath.row].number.description
            let numberStrFirst = numberStr.removeFirst()
            switch numberStrFirst.description {
            case "6":
                numberStr = "IN\(numberStr)"
            case "7":
                numberStr = "S\(numberStr)"
            default:
                numberStr = "8\(numberStr)"
            }
            cell.number.text = numberStr
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RightPersonCell
            cell.name.text = rightPersons![indexPath.row].name
            var numberStr = rightPersons![indexPath.row].number.description
            let numberStrFirst = numberStr.removeFirst()
            switch numberStrFirst.description {
            case "6":
                numberStr = "IN\(numberStr)"
            case "7":
                numberStr = "S\(numberStr)"
            case "1":
                numberStr = "1\(numberStr)"
            default:
                numberStr = "8\(numberStr)"
            }
            cell.number.text = numberStr
            switch rightPersons![indexPath.row].color {
            case "红":
                cell.color.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
            case "绿":
                cell.color.backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.8196078431, blue: 0.5058823529, alpha: 1)
            case "黄":
                cell.color.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.1058823529, alpha: 1)
            case "蓝":
                cell.color.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            case "紫":
                cell.color.backgroundColor = #colorLiteral(red: 0.4705882353, green: 0.1568627451, blue: 1, alpha: 1)
            case "粉":
                cell.color.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.4784313725, blue: 0.5098039216, alpha: 1)
            default:
                cell.color.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            let realm = try! Realm()
            let tempNumber = rightPersons![indexPath.row].number
            let tempPrize = realm.objects(Prize.self).filter("masterNumber = \(tempNumber)").first
            cell.prize.text = tempPrize?.name ?? "中奖记录缺失"
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
        //点击右侧列表将人物放回到未抽奖人员
        print("点击了\(rightPersons![indexPath.row].name)")
            let moveRightToLeftAlert = UIAlertController(title: "撤销中奖者", message: "撤销\(rightPersons![indexPath.row].name)的中奖纪录？\n\(rightPersons![indexPath.row].name)将会被挪到未中奖人员名单中", preferredStyle: .alert)
            let moveRightToLeftAlertCancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let moveRightToLeftAlertSure = UIAlertAction(title: "确定", style: .default) { (action) in
                print("移动人物\(action)")
                let realm = try! Realm()
                try! realm.write {
                    self.rightPersons![indexPath.row].isAvailable = true
                }
                //删除奖品数据库中的条目
                let tempPrizes = realm.objects(Prize.self).filter("masterNumber = %d", self.rightPersons![indexPath.row].number)
                try! realm.write {
                    realm.delete(tempPrizes)
                }
                self.initTwoLists()
                self.leftTableView.reloadData()
                self.rightTableView.reloadData()
            }
            moveRightToLeftAlert.addAction(moveRightToLeftAlertCancel)
            moveRightToLeftAlert.addAction(moveRightToLeftAlertSure)
            self.present(moveRightToLeftAlert, animated: true, completion: nil)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView.tag == 0{
            return (leftPersons?.count)!
        }else{
            return (rightPersons?.count)!
        }
    }
}
