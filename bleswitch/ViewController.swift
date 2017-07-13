//
//  ViewController.swift
//  bleswitch
//
//  Created by Javid Poornasir on 7/12/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var uiSwitch: UISwitch!
    @IBOutlet weak var onLabel: UILabel!
    @IBOutlet weak var offLabel: UILabel!
    
    let BLUE_HOME_SERVICE = "DFB0"
    let WRITE_CHARACTERISTIC = "DFB1"
    
    var writeCharacteristic: CBCharacteristic!
    var ai: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // reference for service manager
    var centralManager: CBCentralManager!
    
    // var for a connected device
    var connectedPeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // connecting to and define central manager for the bluetooth & adhere to centralmanagerdelegate protocol
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: "hasConnected", userInfo: nil, repeats: false)
//        ai.startAnimating()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close BLE connection
    }
    
    func hasConnected() {
        ai.center = self.view.center
        ai.hidesWhenStopped = true
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(ai)
        
        ai.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopAI() {
        ai.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func scanForBLEDevice() {
        centralManager.scanForPeripherals(withServices: [CBUUID(string:BLUE_HOME_SERVICE)], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // this is called for each device we find
        // we qualified for what devices we're looking for by calling the BLUE_HOME_SERVICE
        
        if peripheral.name != nil {
             print("PRINTING - Found peripheral name from didDiscover -  \(peripheral.name!)")
        } else {
             print("PRINTING - Found peripheral with unknown name from didDiscover")
        }
        
        connectedPeripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(connectedPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //when we connect to it we assign the delegate
        connectedPeripheral.delegate = self
        
        // now we find out more about BLE devices
        connectedPeripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("PRINTING Service count from didDiscoverServices - \(peripheral.services!.count)")
        
        for service in peripheral.services! {
            print("PRINTING Service - \(service)") // // By now we have found the available services

            // now let's find the characteristics
            
            // take the service that's returned and cast it as a CBService
            let aService = service as CBService
            
            // check to see if it's out BLUE_HOME_SERVICE
            if service.uuid == CBUUID(string: BLUE_HOME_SERVICE) {
                // call didDiscoverCharacteristics for everything in the aService
                peripheral.discoverCharacteristics(nil, for: aService)

                // then we need to determine if our characteristic is the right one to write to the device and if it is we want to save that
            }
        }
    }
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // for every characteristic it has found for our service, this method is called
        
        for characteristic in service.characteristics! {
            
            let aCharacteristic = characteristic as CBCharacteristic
            
            if aCharacteristic.uuid == CBUUID(string: WRITE_CHARACTERISTIC) {
                print("PRINTING - We found or write characteristic")
                writeCharacteristic = aCharacteristic
            }
        }
    }
    
    @IBAction func switchPressed(_ sender: Any) {
        
        if ((sender as AnyObject).isOn) {
            print("Switch is on")
            writeBLEData(string: "<RELAY0>1;")
        } else {
            print("Switch is off")
            writeBLEData(string: "<RELAY0>0;")
        }
    }
    
    
    func writeBLEData(string: String) {
        // create a data object from the string using dataUsingEncoding
        
        let data = string.data(using: String.Encoding.utf8)
        
        // now we have a bag of bits and we take the connected peripheral and write some values using the data
        connectedPeripheral.writeValue(data!, for: writeCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        // now we should be able to run it and see data being written
    }
    
    // Central Manager Delegates
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // called when state info changes
        
        print("CentralManagerDidUpdateState: Started")
        
        switch central.state {
        case .poweredOff:
            print("Power if OFF")
        case .resetting:
            print("Resetting")
        case .poweredOn:
            print("Power is ON")
        case .unauthorized:
            print("Unauthorized")
        case .unsupported:
            print("Unsupported")
        
        default:
            print("Unknown")
        }
    }
    

}

