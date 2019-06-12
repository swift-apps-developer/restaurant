//
//  OrderConfirmationViewController.swift
//  restaurant
//
//  Created by love on 6/8/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class OrderConfirmationViewController: UIViewController {
    var seconds: Int!
    var preparationTime: Int! {
        didSet {
            self.seconds = self.preparationTime * 60
            self.runTimer()
        }
    }
    
    var formattedPreparationTime: String {
        get {
            let hour = Int(self.seconds) / 3600
            let min = Int(self.seconds) / 60 % 60
            let sec = Int(self.seconds) % 60
            return String(format: "%02i:%02i:%02i", hour, min, sec)
        }
    }
    
    var timer: Timer?
    var isTimerRunning = false
    
    @IBOutlet weak var preparationTimeLabel: UILabel!
    @IBOutlet weak var prepareImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareImageView.layer.cornerRadius = 50
        self.prepareImageView.clipsToBounds = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateOrderTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateOrderTime() {
        self.seconds -= 1
        
        preparationTimeLabel.text = self.formattedPreparationTime
        
        if self.seconds == 0 {
            self.timer?.invalidate()
            let alert = UIAlertController(title: "Your Order Is Ready", message: "your order is ready to ship", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
}
