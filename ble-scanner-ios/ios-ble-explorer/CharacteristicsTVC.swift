//
//  CharacteristicsTVC.swift
//  Bluetooth Scanner
//
//  Created by Pavan Athreya on 01/03/2019.
//  Copyright (c) 2019 Pavan Athreya. All rights reserved.
//

import UIKit
import CoreBluetooth

//Class for listing the characteristics of the service selected
class CharacteristicsTVC: UITableViewController, CBPeripheralDelegate {
    
    //Connected Peripheral
    var peripheral: CBPeripheral!
    
    //Required Service
    var service: CBService!
    
    //List of Characteristics displayed on the table view
    var characteristics = Array<CBCharacteristic>()
    
    // MARK: - View Life Cycle
    
    //View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        peripheral.delegate = self
        peripheral.discoverCharacteristics(nil, for: service)
    }

    // MARK: - Table view data source
    
    //Number of sections in Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //Number of rows in given section of the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }
    
    //Table View Cell for row at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Characteristic", for: indexPath)
        let c = characteristics[indexPath.row]
        cell.textLabel?.text = "UUID: \(c.uuid.uuidString)"
        cell.detailTextLabel?.text = c.value?.hexDescription
        return cell
    }
    
    // MARK: - CBPeripheralDelegate
    
    //Peripheral did discover charactersistics for a service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let e = error {
            print("Failed to discover characteristics: \(e.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics as! [CBCharacteristic] {
            print("Characteristic discovered: \(characteristic)")
            characteristics.append(characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            peripheral.readValue(for: characteristic)
        }
        self.tableView.reloadData()
    }
    
    //Peripheral did update value for characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Failed to update value for characteristic: \(e.localizedDescription)")
            return
        }
        
        print("Value for characteristic \(characteristic.uuid.uuidString) is: \(String(describing: characteristic.value))")
        print(characteristic.value)
        self.tableView.reloadData()
    }

}
