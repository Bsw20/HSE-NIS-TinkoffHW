//
//  File.swift
//  Stocks
//
//  Created by Ярослав Карпунькин on 14.12.2020.
//

import UIKit
import SDWebImage

class MainController: UIViewController {
    //СОРИ ЗА КОДСТАЙЛ
    //variables
    private var companies: [String: String] = ["Apple" : "AAPL",
                                               "Microsoft" : "MSFT",
                                               "Google" : "GOOG",
                                               "Amazon" : "AMZN",
                                               "Facebook" : "FB"]
    
    let token = "" //TODO: вставьте сюда свой токен
    //Controls
    var label1: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.text = "Company name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var label2: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.text = "Symbol"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var label3: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.text = "Price"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var label4: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.text = "Price change"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var companyNameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var symbolLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var priceLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var priceChangeLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
       var indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var pickerView: UIPickerView = {
       var picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    var imageView: UIImageView = {
       var imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        pickerView.dataSource = self
        pickerView.delegate = self
        self.requestQuoteUpdate()
    }
    
    private func displayAlert() {
        let alertVC = UIAlertController(title: "Ошибка!", message: "Проблемы с интернет соединением", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }

    }
    
    private func requestQuote(for symbol: String, token: String) {

        let url = URL(string: "https://cloud.iexapis.com/v1/stock/\(symbol)/quote?token=\(token)")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let data = data else {
                print("Network ERROR")
                self.displayAlert()
                return
            }
            self.parseQuote(data: data)
            
        }.resume()
        
        let imageUrl = URL(string: "https://cloud.iexapis.com/v1/stock/\(symbol)/logo?token=\(token)")!
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.parseImage(data: data!)
            
            
        }.resume()

    }
    
    private func parseImage(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let json = jsonObject as? [String : Any],
                  let stringUrl = json["url"] as? String
                  else {
                print("Invalid json format")
                return
            }
            print(stringUrl)
            let url = URL(string: stringUrl)!
            DispatchQueue.main.async {
                self.imageView.backgroundColor = .clear
                self.imageView.sd_setImage(with: url)
            }
            
        } catch {
            print("JSON parsing error. " + error.localizedDescription)
        }
    }
    
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let json = jsonObject as? [String : Any],
                  let companyName = json["companyName"] as? String,
                  let companySymbol = json["symbol"] as? String,
                  let price = json["latestPrice"] as? Double,
                  let priceChange = json["change"] as? Double
                  else {
                print("Invalid json format")
                return
            }
            
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange)
            }
            
            print("Company name is: \(companyName)")
        } catch {
            print("JSON parsing error. " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double) {
        self.activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        symbolLabel.text = symbol
        priceLabel.text = "\(price)"
        if(priceChange < 0) {
            priceChangeLabel.textColor = .red
        } else if (priceChange > 0) {
            priceChangeLabel.textColor = .green
        } else {
            priceChangeLabel.textColor = .black
        }
        priceChangeLabel.text = "\(priceChange)"
    }
    
    private func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.symbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        self.imageView.image = nil
        self.imageView.backgroundColor = .lightGray
        
        let selectedRow = self.pickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol, token: token)
    }


}

//MARK: - UI
extension MainController {
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)

        let leadingOffset = 40
        let betweenOffset = 60
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(leadingOffset)),
            label1.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50)
        ])

        NSLayoutConstraint.activate([
            label2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(leadingOffset)),
            label2.topAnchor.constraint(equalTo: label1.topAnchor, constant: CGFloat(betweenOffset))
        ])

        NSLayoutConstraint.activate([
            label3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(leadingOffset)),
            label3.topAnchor.constraint(equalTo: label2.topAnchor, constant: CGFloat(betweenOffset))
        ])

        NSLayoutConstraint.activate([
            label4.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(leadingOffset)),
            label4.topAnchor.constraint(equalTo: label3.topAnchor, constant: CGFloat(betweenOffset))
        ])

        view.addSubview(companyNameLabel)
        view.addSubview(symbolLabel)
        view.addSubview(priceLabel)
        view.addSubview(priceChangeLabel)

        let trailingInset = -40;

        NSLayoutConstraint.activate([
            companyNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: CGFloat(trailingInset)),
            companyNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50)
        ])

        NSLayoutConstraint.activate([
            symbolLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: CGFloat(trailingInset)),
            symbolLabel.topAnchor.constraint(equalTo: companyNameLabel.topAnchor, constant: CGFloat(betweenOffset))
        ])

        NSLayoutConstraint.activate([
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: CGFloat(trailingInset)),
            priceLabel.topAnchor.constraint(equalTo: symbolLabel.topAnchor, constant: CGFloat(betweenOffset))
        ])

        NSLayoutConstraint.activate([
            priceChangeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: CGFloat(trailingInset)),
            priceChangeLabel.topAnchor.constraint(equalTo: priceLabel.topAnchor, constant: CGFloat(betweenOffset))
        ])

        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
         
        
        
    }
}

extension MainController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
    
    
    
}

//MARK: - SwiftUI
import SwiftUI

struct VCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let vc = MainController()
        
        func makeUIViewController(context: Context) ->  some MainController {
            return vc
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
