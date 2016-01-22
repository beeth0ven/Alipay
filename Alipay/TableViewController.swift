//
//  TableViewController.swift
//  Alipay
//
//  Created by luojie on 16/1/21.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import Heimdall

class TableViewController: UITableViewController {
    
    var products = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    func getData() {
        products = (1...10).map { Product(subject: $0.description, body: "我是测试数据\($0)") }
    }

    // MARK: - Table view data source


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath)
        let product = products[indexPath.row]
        
        cell.textLabel?.text = product.body
        cell.detailTextLabel?.text = "一口价 \(product.price)"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        payProduct(products[indexPath.row])
    }
    
    func payProduct(product: Product) {
        let order = Order()
        order.tradeNO = NSUUID().UUIDString
        order.productName = product.subject
        order.productDescription = product.body
        order.amount = NSString(format: "%.2f", product.price) as String
        
        order.notifyURL = "http://www.xxx.com"; //回调URL
        
        order.service = "mobile.securitypay.pay";
        order.paymentType = "1";
        order.inputCharset = "utf-8";
        order.itBPay = "30m";
        order.showUrl = "m.alipay.com";
        print(order)
        
        AlipaySDK.payOrder(order,
            didPay: {
                print("Successfully to pay product: \(product.body)")
            },
            didFail: {
                payError in
                print("Failed to pay product: \(product.body)")
            }
        )
        
        print("\(__FUNCTION__) \(product.body) ¥\(order.amount!)")
        
    }

}

extension AlipaySDK {
    struct Constants {
        static let Partner      = ""
        static let Seller       = ""
        static let PrivateKey   = ""
        static let NotifyURL    = "http://www.xxx.com"
        static let AppScheme    = "alisdkdemo"

    }
    
    enum PayError {
        case Timeout
        case NoMoney
    }
    
    static func payOrder(order: Order, didPay: () -> Void, didFail: ((PayError) -> Void)? = nil) {
        let signer = Heimdall(tagPrefix: AlipaySDK.Constants.PrivateKey)!
        let signedString = signer.encrypt(order.description)!
        print(signedString)
        
        let orderString = NSString(format: "%@&sign=\"%@\"&sign_type=\"%@\"", order.description, signedString, "RSA") as String
        print(orderString)
        
        defaultService().payOrder(orderString, fromScheme: Constants.AppScheme, callback: {
            resDic in
            let success = true
            if success {
                didPay()
            } else {
                didFail?(.Timeout)
            }
        })
    }
}

struct Product {
    var price: Float
    var subject: String
    var body: String
    var orderId: String?
    
    init(subject: String, body: String) {
        self.subject = subject
        self.body = body
        self.price = 0.01
    }
}