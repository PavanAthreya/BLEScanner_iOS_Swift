//
//  PeripheralsTVC.swift
//  Bluetooth Scanner
//
//  Created by Pavan Athreya on 01/03/2019.
//  Copyright (c) 2019 Pavan Athreya. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

//Class for listing the peripherals
class PeripheralsTVC: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {

    // CoreBluetooth Central Manager
    static var centralManager:CBCentralManager!
    
    // CoreLocation Location Manager
    var locationManager:CLLocationManager!
    
    // All peripherals in Central Manager
    var peripherals = [CBPeripheral]()
    
    // Peripheral chosen by user
    var connectedPeripheral:CBPeripheral!
    
    // MARK: - View Life Cycle
    
    //View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // This will trigger centralManagerDidUpdateState
        PeripheralsTVC.centralManager = CBCentralManager(delegate: self, queue: nil)
        //centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    //View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Re-start scan after coming back from background
        peripherals.removeAll()
        if PeripheralsTVC.centralManager.state == .poweredOn {
            PeripheralsTVC.centralManager.scanForPeripherals(withServices:nil, options: ["CBCentralManagerScanOptionAllowDuplicatesKey" : false])
        }
    }
    
    //View Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop scan to save battery when entering background
        PeripheralsTVC.centralManager.stopScan()
        // Remove all peripherals from the table and array (they will be re-discovered upon viewDidAppear)
        peripherals.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
    }
    
    // MARK : - CLLocationManager Delegates
    
    //Location manager did change authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Did update Status: \(status)")
    }
    
    // MARK: - CBCentralManagerDelegate
    
    //Central manager did update bluetooth state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager did update state")
        
        if (central.state == .poweredOn) {
            print("Bluetooth is powered on")
            // Scan for any peripherals
            peripherals.removeAll()
            PeripheralsTVC.centralManager.scanForPeripherals(withServices: nil, options: ["CBCentralManagerScanOptionAllowDuplicatesKey" : false])
        }
        else {
            var message = String()
            switch central.state {
            case .unsupported:
                message = "Bluetooth is unsupported"
            case .unknown:
                message = "Bluetooth state is unkown"
            case .unauthorized:
                message = "Bluetooth is unauthorized"
            case .poweredOff:
                message = "Bluetooth is powered off"
            default:
                break
            }
            print(message)
        }
    }
    
    //Central manager did discover peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral discovered: \(peripheral)")
        print("Advertisement Data: \(advertisementData)")
        
        peripherals.append(peripheral)
        self.tableView.reloadData()
    }
    
    //Central manager did connect to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral connected: \(String(describing: peripheral))")
        
        PeripheralsTVC.centralManager.stopScan()
        
        // Keep reference to be used in prepareForSegue
        self.connectedPeripheral = peripheral
        performSegue(withIdentifier: "Services", sender: self)
    }
    
    //Central Manager Failed to connect to peripheral
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Peripheral failed to connect: \(peripheral)")
    }

    // MARK: - Table view data source
    
    //Number of sections in Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //Number of rows in given section of the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    //Table View Cell for row at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Peripheral", for: indexPath) as UITableViewCell
        let p = peripherals[indexPath.row]
        cell.textLabel?.text = p.name ?? "[Unkown name]"
        cell.detailTextLabel?.text = "UUID: \(p.identifier.uuidString)"
        return cell
    }
    
    // MARK: - Table view delegates
    
    //Table View did select row at index path
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.connectedPeripheral = peripherals[indexPath.row]
        print("Tring to connnect to peripheral: \(String(describing: self.connectedPeripheral))")
        PeripheralsTVC.centralManager.connect(self.connectedPeripheral, options: nil)
    }

    // MARK: - Segue
    
    //View Controller Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let servicesTVC = segue.destination as! ServicesTVC
        servicesTVC.peripheral = self.connectedPeripheral
    }

}
