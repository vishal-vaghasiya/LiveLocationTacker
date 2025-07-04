//
//  ScantoJoinVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 24/12/24.
//

import UIKit
import SwiftQRCodeScanner
class ScantoJoinVC: UIViewController {
    
    @IBOutlet weak var img_barcode: UIImageView!
    @IBOutlet weak var qr_view: UIView!
    let firebaseManager = FirebaseManager.shared
    var groupCode = String()
    var groupFcmtoken = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img_barcode.image = generateHDQRCode(from: groupCode + "@" + groupFcmtoken + "@" + String(NSDate().timeIntervalSince1970))
    }
   
    @IBAction func backClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnScanAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            let scanner = QRCodeScannerController()
            scanner.delegate = self
            self.present(scanner, animated: true)
        }
    }
    
    @IBAction func btnShareBarcodeAction(_ sender: UIButton) {
        guard let imgeBarcode = img_barcode.image  else { return }
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(activityItems: [imgeBarcode,Constants.APP_URL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - create qrcode -
extension ScantoJoinVC : QRScannerCodeDelegate {
    
    func qrScanner(_ controller: UIViewController, didScanQRCodeWithResult result: String) {
        controller.dismiss(animated: true)
        showLoader(text: "Joing...")
        
        var friendEnterCode = result.replacingOccurrences(of: " ", with: "")
        let parse = friendEnterCode.split(separator: "@")
        friendEnterCode = String(parse[0])
        var friendfcmtoken = String(parse[1])
        
        print("friendEnterCode ==> \(friendEnterCode)")
        print("fcmtoken ==> \(String(parse[1]))")
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        
        firebaseManager.joinCircle(withCode: friendEnterCode,
                                circleId: groupCode,
                                batteryLevel: batteryLevel) { success in
            self.hideLoader()
            
            if success {
                print("Friend successfully joined the circle!")
                let myname = DefaultManager.User.NAME + " " + NSLocalizedString("FriendQRPushMSG", comment: "")
                self.firebaseManager.sendPushNotification(fcmToken: friendfcmtoken, body: myname)
                self.navigateToHome()
            }
            else {
                self.showAlert(title: "Scan barcode incorrect !", message: "Please scan valid barcode")
            }
        }
    }
    
    func qrScanner(_ controller: UIViewController, didFailWithError error: SwiftQRCodeScanner.QRCodeError) {
        print("Qrcode failed with error \(error.localizedDescription)")
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        controller.dismiss(animated: true)
    }
    
    func generateHDQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        
        // Generate the QR code
        guard let ciImage = filter.outputImage else {
            return nil
        }
        
        // Scale up the QR code image
        let scaleX = UIScreen.main.bounds.width / ciImage.extent.width // Scale based on screen width
        let scaleY = UIScreen.main.bounds.width / ciImage.extent.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Render the CIImage into a high-definition CGImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        // Convert CGImage to UIImage
        return UIImage(cgImage: cgImage)
    }
}
