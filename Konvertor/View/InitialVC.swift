//
//  InitialVC.swift
//  Konvertor
//
//  Created by Yevhenii Orenchuk on 1/22/19.
//  Copyright © 2019 Perchiki. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
    
    // MARK: Properties
    
    let controller = CurrencyListController()
    var exchangeRate: CurrentExchangeRate?
    var currentButtonPressed: UIButton?
    private let cameraController = CameraCaptureController()
    
    // MARK: IBOutlets
    
    @IBOutlet weak var currencyInputButton: UIButton!
    @IBOutlet weak var currencyOutputButton: UIButton!
    @IBOutlet weak var amountInput: UITextField!
    @IBOutlet weak var amountOutput: UILabel!
    @IBOutlet weak var photoDetectButton: UIButton!
    @IBOutlet weak var currencyListTableView: UITableView!
    
    // MARK: IBActions
    
    @IBAction func changeCurrency(_ sender: UIButton) {
        amountInput.resignFirstResponder()
        if currentButtonPressed == nil{
            currentButtonPressed = sender
        }
        if currentButtonPressed == sender || currencyListTableView.isHidden == true{
            currencyListTableView.isHidden = !currencyListTableView.isHidden
        }
        currentButtonPressed = sender
    }    
    
    @IBAction func keyboardTrigger(_ sender: UITextField) {
    }
    
    @IBAction func photoDetectAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraStoryboard")
        
        cameraController.checkPermission { [unowned self] granted in
            
            if let granted = granted {
                if granted {
                    DispatchQueue.main.async {
                        self.present(cameraVC, animated: true, completion: nil)
                    }
                } else {
                    print("InitialVC: no permission to camera")
                    self.cameraController.changePermission(viewController: self)
                }
            } else {
                print("Camera access denied")
            }
        }
    }
    
 
    @IBAction func inputChanged(_ sender: UITextField) {
        if let input = Double(amountInput.text!){
        amountOutput.text = Converter.convert(inputCurrency: currencyInputButton.currentTitle!,
                                    amount: input,
                                    outputCurrency: currencyOutputButton.currentTitle!,
                                    currency: exchangeRate!)
        } else {
            amountOutput.text = " "
        }
            
       
    }
    
    //add ApiKey
    lazy var currencyManager = APICurrencyManager(apiKey: "e08a5295b1f345d4b4aeb1d8d1dd0055")
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gradient background layer
        
        let gradientLayer = CAGradientLayer()
        let rightColor = UIColor(red: 255.0/255.0, green: 175.0/255.0, blue: 189.0/255.0, alpha: 1.0).cgColor
        let leftColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 160.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [leftColor, rightColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.1, y: 0.5)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        //Add padding to input UITextField
        let View = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 15.0, height: 0.0))
        amountInput.leftView = View
        amountInput.rightView = View
        amountInput.leftViewMode = .always
        //Adding cells to currency pop-up
        currencyListTableView.delegate = self
        currencyListTableView.dataSource = self
        currencyListTableView.register([CurrencyCell.reuseIdentifier])
        currencyListTableView.layer.cornerRadius = 10
        //pulling reuest to API
        currencyManager.fetchCurrentCurrencyExchangeRateWith() { (result) in
            switch result {
            case .Success(let currentExchangeRate):
                print("ok")
                
                // For Sasha API library:
//                print(currentExchangeRate)
                self.exchangeRate = currentExchangeRate
                print("Base currency:", currentExchangeRate.base)
                print("UAH rate:",  currentExchangeRate.rates["UAH"] ?? "N/A")
                //
            case .Failure(let error as NSError):
                print("fail")
                print(error)
                let alertController = UIAlertController(title: "Unable to get data ", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)

                self.present(alertController, animated: true, completion: nil)
            default: break
            }
        }
    }
    
    
}

extension InitialVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
}

extension InitialVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCurrency = controller.currencyList[indexPath.row]
        let cell = currencyListTableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        cell.currencyAbbriviation.text = currentCurrency.abbriviation
        cell.currencyName.text = currentCurrency.currencyName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(controller.currencyList[indexPath.row].abbriviation)
        currentButtonPressed!.setTitle(controller.currencyList[indexPath.row].abbriviation, for: .normal)
        inputChanged(amountInput)
        currencyListTableView.isHidden = true
        
    }

}


