/**
* JBoss, Home of Professional Open Source
* Copyright Red Hat, Inc., and individual contributors
* by the @authors tag. See the copyright.txt in the distribution for a
* full listing of individual contributors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import AVFoundation
import AeroGear_OTP

class QRcodeCaptureViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // QRCode reader
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var otp: AGTotp?
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input as AVCaptureInput)
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input as AVCaptureInput)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            
        } catch let error as NSError {
            // Handle any errors
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func parametersFromQueryString(queryString: String) -> [String: String] {
        var parameters = [String: String]()
        
        let queryPart = queryString.characters.split{$0 == "?"}
        let query: String? = queryPart.count > 1 ? String(queryPart[1]) : nil
        
        if let query = query {
            let parameterScanner: NSScanner = NSScanner(string: query)
            var name: NSString? = nil
            var value: NSString? = nil
            
            while (parameterScanner.atEnd != true) {
                name = nil;
                parameterScanner.scanUpToString("=", intoString: &name)
                parameterScanner.scanString("=", intoString:nil)
                
                value = nil
                parameterScanner.scanUpToString("&", intoString:&value)
                parameterScanner.scanString("&", intoString:nil)
                print("name::\(name) and value::\(value)")
                if (name != nil && value != nil) {
                    parameters[name!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!] = value!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                }
            }
        }
        
        return parameters;
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.filter({ $0 == metadataObj.type }).count > 0 {
            
            if metadataObj.stringValue != nil {
                // Capture is over
                captureSession?.stopRunning()
                let secret = self.parametersFromQueryString(metadataObj.stringValue)["secret"]
                if let secret = secret {
                    print("Secret found: \(secret)")
                    otp = AGTotp(secret: AGBase32.base32Decode(secret))
                } else {
                     print("Secret not found.")
                }

                // go back to main screen
                self.performSegueWithIdentifier("displayOTP:", sender: self)
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let viewController = segue.destinationViewController as! ViewController
        viewController.otp = otp
    }
    

}
