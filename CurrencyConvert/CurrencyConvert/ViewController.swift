//
//  ViewController.swift
//  CurrencyConvert
//
//  Created by macbook on 22.06.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tryLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var cadLabel: UILabel!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var eurLabel: UILabel!
    @IBOutlet weak var fromTxt: UITextField!
    @IBOutlet weak var toTxt: UITextField!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var resultTxt: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        let url = URL(string: "http://data.fixer.io/api/latest?access_key=4a990ae1cc0ef5a920e4c7e9eeb1123c")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!) { data, response, error in
            if error != nil {
                let alert = UIAlertController(title: "error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                if data != nil{
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String , Any>
                        
                        DispatchQueue.main.async {
                            print(jsonResponse)
                            if let rates = jsonResponse["rates"] as? [String : Any]{
                                if let CURRENCY = rates["CAD"] as? Double {
                                    self.cadLabel.text = "CAD : \(CURRENCY)"
                                }
                                if let CURRENCY = rates["GBP"] as? Double {
                                    self.gbpLabel.text = "GBP : \(CURRENCY)"
                                }
                                if let CURRENCY = rates["EUR"] as? Double {
                                    self.eurLabel.text = "EUR : \(CURRENCY)"
                                }
                                if let CURRENCY = rates["USD"] as? Double {
                                    self.usdLabel.text = "USD : \(CURRENCY)"
                                }
                                if let CURRENCY = rates["TRY"] as? Double {
                                    self.tryLabel.text = "TRY : \(CURRENCY)"
                                }
                            }
                        }
                    }
                    catch{
                        print("error")
                    }
                }
            }
        }
        task.resume()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func getRatesClicked(_ sender: Any) {
        
        let semaphore = DispatchSemaphore (value: 0)
        
        guard let to = toTxt.text, let from = fromTxt.text, let amount = amountTxt.text  else {return}
        
        let url = "https://api.apilayer.com/fixer/convert?to=\(to)&from=\(from)&amount=\(amount)"
        
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        
        request.httpMethod = "GET"
        request.addValue("XvBXZafHOtMbiW7Q29rbli25XcMZZDM2", forHTTPHeaderField: "apikey")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            print(String(data: data, encoding: .utf8)!)
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String , Any>
                DispatchQueue.main.async {
                    if let result = jsonResponse["result"] as? Double {
                            self.resultTxt.text = "Converted : \(result)"
                    }
                }
            }
            catch {
                print(error)
            }
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
}
