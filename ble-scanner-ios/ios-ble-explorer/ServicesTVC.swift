//
//  ServicesTVC.swift
//  Bluetooth Scanner
//
//  Created by Pavan Athreya on 01/03/2019.
//  Copyright (c) 2019 Pavan Athreya. All rights reserved.
//

import UIKit
import CoreBluetooth

//Class for listing the services of the peripheral
class ServicesTVC: UITableViewController, CBPeripheralDelegate {
    
    // Connected peripheral
    var peripheral: CBPeripheral!
    
    // All services in the connected peripheral
    var services = [CBService]()
    
    // Service chosen by user
    var service: CBService!
    
    //MARK: - View Life Cycle
    
    //View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Re-start scan after coming back from background
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    //View Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove all services from the table and array (they will be re-discovered upon viewDidAppear)
        services.removeAll(keepingCapacity: false)
        tableView.reloadData()
    }
    
    // MARK: - CBPeripheralDelegate
    
    //Peripheral Did Discover Services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let e = error {
            print("Failed to discover services: \(e.localizedDescription)")
            return
        }
        
        for service in peripheral.services as! [CBService] {
            services.append(service)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    //Number of sections in Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //Number of rows in given section of the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    //Table View Cell for row at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Service", for: indexPath as IndexPath)
        
        let s = services[indexPath.row]
        cell.textLabel?.text = "UUID: \(s.uuid.uuidString)"
        cell.detailTextLabel?.text = s.isPrimary ? "This is the primary service" : ""
        
        return cell
    }
    
    // MARK: - Table view delegates
    
    //Table View Did Select Row at Index Path
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        service = services[indexPath.row]
        performSegue(withIdentifier: "Characteristics", sender: self)
    }

    // MARK: - Segue
    
    //View Controller Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let characteristicsTVC = segue.destination as! CharacteristicsTVC
        characteristicsTVC.peripheral = self.peripheral
        characteristicsTVC.service = self.service
    }
    
}
