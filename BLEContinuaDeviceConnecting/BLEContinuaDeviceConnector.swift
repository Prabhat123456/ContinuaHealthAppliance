//
//  BLEMeasurementFetcher.swift
//  BluetoothTest
//
//  Created by Prabhat on 9/25/17.
//  Copyright © 2017 Prabhat. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
 * BLEServiceIdentifier has the Service ID of Thermometer and OxiMeter
 
 */
private enum BLEServiceIdentifier :String{
    case BLEThermometerServiceID = "1809"
    case  BLEOximeterServiceID =   "1822"
}

/**
 * BLEScratchIdentifier represent to Characterstic ID for the Service (BLEServiceIdentifier)
 
 */
private enum BLEScratchIdentifier :String{
    case BLEThermometerScratchID = "2A1C"
    case BLEOximeterScratchID = "2A5F"
}

/**
 * Maps the name of the Device to be scanned and Data to be fetched
 
 */
public enum BLEDeviceName : String{
    case BLEThermometer = "Philips Thermometer"
    case  BLEOximeter  = "Nonin3230_502238039"
    
}

/**
 * Structure of different type of error thrown because of bluetooth unavailablity
 
 */

struct errorWithBluetooth {
    static let KBluetoothoff = "Bluetooth is off. Please make sure your bluetooth is On to connect with desired device"
    static let KBluetoothReseting = "The connection with the system service was momentarily lost.Please reset your bluetooth connection and try connecting again with the device"
    static let KBluetoothUnsupported =  "The platform doesn't support the Bluetooth Low Energy Central/Client role. Please try updating your OS to connect with device"
    static let KBluetoothUnauthorized  = "The application is not authorized to use the Bluetooth Low Energy role."
    static let KBluetoothUnknown =   "Bluetooth state is unknow. Please reset your bluetooth connection and try connecting again with the device"
    static let KBluetoothError =  "Bluetooth Error"
}


private class FetcherDelegateWrapper : NSObject,CBPeripheralDelegate,CBCentralManagerDelegate
{
    private weak var parent: BLEContinuaDeviceConnector?
    private var listOfConnectingPeripheral =  [CBPeripheral]() // The connecting peripheral storage object
    private var listOfDeviceToConnect = [String]()
    private var manager: CBCentralManager? // Manager to manage all the Bluetooth related actions
    private var characteristics = [UInt8]() // Array to store the characteristics of the discovered device
    private  var deviceToScan : String?
    private var successCallBackDictonary = [String: (([String:Any]?)->())?]()
    private var errorCallBackDictonary =  [String: ((Error?) -> Void)?]()
    private var TemperatureValue: String = ""
    private var SpO2text: String = ""
    private var BPMText: String = ""
    
    /**
     * measurenmentTemperature variable for Temperature of Thermometer
     
     */
    
    @objc dynamic private var measurenmentTemperature: Dictionary<String, Any> = [:]{
        willSet{
            if let handler = successCallBackDictonary[BLEDeviceName.BLEThermometer.rawValue]{
                if handler != nil{
                    handler!(newValue)
                }
                
            }
        }
    }
    
    /**
     * errorInMeasurenment for measurenment of Temperature of Thermometer
     
     */
    
    @objc dynamic private var errorInMeasurenment : NSError?{
        willSet{
            if let errorhandler = errorCallBackDictonary[BLEDeviceName.BLEThermometer.rawValue]{
                if errorhandler != nil {
                    errorhandler!(newValue)
                }
                
            }
        }
    }
    
    /**
     * measurenmentOxiMeterValue holds the value of Oximeter Values
     
     */
    
    @objc dynamic private var measurenmentOxiMeterValue: Dictionary<String, Any> = [:]{
        willSet{
            if let handler = successCallBackDictonary[BLEDeviceName.BLEOximeter.rawValue]{
                if handler != nil{
                    handler!(newValue)
                }
                
            }
        }
    }
    
    /**
     * errorInMeasurenmentOfOxiMeterValue in getting the value of Oximeter Values
     
     */
    
    @objc dynamic private var errorInMeasurenmentOfOxiMeterValue : NSError?{
        willSet{
            if let errorhandler = errorCallBackDictonary[BLEDeviceName.BLEOximeter.rawValue]{
                if errorhandler != nil {
                    errorhandler!(newValue)
                }
                
            }
        }
    }
    
    /**
     *   @method init method
      -  @param parent: BLEMeasurementFetcher class which is visible to outside world
     */
    
    init(parent: BLEContinuaDeviceConnector)
    {
        super.init()
        self.parent = parent
        self.manager = CBCentralManager(delegate: self, queue: nil) // Initialze the manager
    }
    
    /*!
     *  @method startScanning(forDevice device :BLEDeviceName)
     *
     *  @param device   : Parameter as Input from the User to identify which device to be scanned
     
     */
    
    fileprivate func startScanning(forDevice device :BLEDeviceName){
        
        listOfDeviceToConnect.append(device.rawValue)
        manager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /*!
     *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
     *
     *  @param central              The central manager providing this update.
     *  @param peripheral           A <code>CBPeripheral</code> object.
     *  @param advertisementData    A dictionary containing any advertisement and scan response data.
     *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
     *                                was not available.
     *
     *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
     *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
     *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
     *
     *  @seealso                    CBAdvertisementData.h
     *
     */
    
    
    fileprivate func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let serviceUUID = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]{
            _ =  serviceUUID.contains(where: { (uuid) -> Bool in
                if case uuid.uuidString = BLEServiceIdentifier.BLEThermometerServiceID.rawValue {
                    listOfConnectingPeripheral.append(peripheral)
                    manager?.connect(peripheral, options: nil)
                    return true
                }
                if case uuid.uuidString = BLEServiceIdentifier.BLEOximeterServiceID.rawValue {
                    listOfConnectingPeripheral.append(peripheral)
                    manager?.connect(peripheral, options: nil)
                    return true
                }
                manager?.cancelPeripheralConnection(peripheral)
                return false
            })
        }
        
        
        
    }
    
    /*!
     *  @method centralManager:didConnectPeripheral:
     *
     *  @param central      The central manager providing this information.
     *  @param peripheral   The <code>CBPeripheral</code> that has connected.
     *
     *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
     *
     */
    
    fileprivate func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    /*!
     *  @method peripheral:didDiscoverServices:
     *
     *  @param peripheral    The peripheral providing this information.
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
     *                        <i>peripheral</i>'s @link services @/link property.
     *
     */
    
    fileprivate func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        _ = peripheral.services?.contains(where: { (service) -> Bool in
            if case CBUUID(string:BLEServiceIdentifier.BLEThermometerServiceID.rawValue)  = service.value(forKey: "UUID") as! CBUUID {
                peripheral.discoverCharacteristics([CBUUID(string:BLEScratchIdentifier.BLEThermometerScratchID.rawValue)], for: service)
                return true
            }
            if case CBUUID(string:BLEServiceIdentifier.BLEOximeterServiceID.rawValue)  = service.value(forKey: "UUID") as! CBUUID {
                peripheral.discoverCharacteristics([CBUUID(string:BLEScratchIdentifier.BLEOximeterScratchID.rawValue)], for: service)
                return true
            }
            return false
        })
    }
    
    /*!
     *  @method peripheral:didDiscoverCharacteristicsForService:error:
     *
     *  @param peripheral    The peripheral providing this information.
     *  @param service        The <code>CBService</code> object containing the characteristic(s).
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
     *                        they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
     */

    fileprivate func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let charactersticks = service.characteristics?.first{
            peripheral.setNotifyValue(true, for:charactersticks)
        }
        
    }
    
    /*!
     *  @method peripheral:didUpdateValueForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    A <code>CBCharacteristic</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
     */
    
    fileprivate func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString {
        case BLEScratchIdentifier.BLEThermometerScratchID.rawValue:
            getDataFromThermometer(withCharacterStics: characteristic)
            break
        case  BLEScratchIdentifier.BLEOximeterScratchID.rawValue:
            getDataFromOxiMeter(withCharacterStics: characteristic)
            break
        default :
            break
        }
        
    }
    
    /*!
     *  @method getDataFromThermometer(withCharacterStics characteristic:CBCharacteristic)
     *
     *  @param characteristic   : get the Value for the characteristic
     
     */
    
    private func getDataFromThermometer(withCharacterStics characteristic:CBCharacteristic){
        if !characteristic.value!.isEmpty {
            if characteristic.value!.count > 3 {
                let firstValue = Int(characteristic.value![2])
                let lastValue = Int(characteristic.value![1])
                var temperatureValue = Float(Int(firstValue * 256 + lastValue))
                temperatureValue /= 10
                if(temperatureValue != 0.0){
                    TemperatureValue = String(temperatureValue)
                    measurenmentTemperature["Temperature"] = TemperatureValue
                }
            }
            
        }
        
    }
    
    /*!
     *  @method getDataFromOxiMeter(withCharacterStics characteristic:CBCharacteristic)
     *
     *  @param characteristic   : get the Value for the characteristic
     
     */
    
    private func getDataFromOxiMeter(withCharacterStics characteristic:CBCharacteristic){
        var SpO2Value: Int = 0
        var BPMValue: Int = 0
        if !characteristic.value!.isEmpty {
            if characteristic.value![8] != 7 {
                characteristics.insert(characteristic.value![8] - 240, at: 0)
                characteristics.insert(characteristic.value![9], at: 1)
                SpO2Value = (Int(characteristics[0]) * 256 + Int(characteristics[1])) / 10
            }
            if characteristic.value![10] != 7 {
                characteristics.insert(characteristic.value![10] - 240, at: 0)
                characteristics.insert(characteristic.value![11], at: 1)
                BPMValue = (Int(characteristics[0]) * 256 + Int(characteristics[1])) / 10
            }
            if SpO2Value != 102 && SpO2Value != 0 {
                SpO2text = String(SpO2Value)
                BPMText = String(BPMValue)
                if(SpO2text.characters.count != 0 && BPMText.characters.count != 0){
                    measurenmentOxiMeterValue["SpO2Value"] = SpO2text
                    measurenmentOxiMeterValue["BPMValue"] = BPMText
                }
            }
        }
        
    }
    
    /*!
     *  @method getMeasurement(fordevice device:BLEDeviceName,success:@escaping ([String:Any]?)->(),completionHandler: ((Error?) -> Void)? = nil)
     *
     *   @param device   : Parameter as Input from the User to identify which device to be scanned
     *    @param success   : Success Callback to be thrown on receiving data
     *   @param completionHandler   : completionHandler Callback to be thrown on receiving error
     */
    
    fileprivate func getMeasurement(fordevice device:BLEDeviceName,success:@escaping ([String:Any]?)->(),completionHandler: ((Error?) -> Void)? = nil) {
        successCallBackDictonary[device.rawValue] = success
        errorCallBackDictonary[device.rawValue] = completionHandler
        
    }
    
    /*!
     *  @method stopScanning(fordevice device:BLEDeviceName)
     *
     *   @param device   : Parameter as Input from the User to identify which device to be scan should be stopped
     */
    
    fileprivate func stopScanning(fordevice device:BLEDeviceName){
        for peripheral in listOfConnectingPeripheral{
            switch device.rawValue {
            case BLEDeviceName.BLEThermometer.rawValue :
                if let services = peripheral.services{
                    for service in services{
                        if (service.value(forKey: "UUID") as? CBUUID == CBUUID(string:BLEServiceIdentifier.BLEThermometerServiceID.rawValue)){
                            manager?.cancelPeripheralConnection(peripheral)
                        }
                    }
                }
                
                break
            case BLEDeviceName.BLEOximeter.rawValue :
                if let services = peripheral.services{
                    for service in services{
                        if (service.value(forKey: "UUID") as? CBUUID == CBUUID(string:BLEServiceIdentifier.BLEOximeterServiceID.rawValue) ){
                            manager?.cancelPeripheralConnection(peripheral)
                        }
                    }
                }
                break
            default:
                break
                
            }
        }
    }
    
    /*!
     *  @method centralManagerDidUpdateState(_ central: CBCentralManager)
     *
     *   @param central   : Central Manager
     */
    
    fileprivate func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central == self.manager else{
            return
        }
        var error : NSError?
        switch (central.state) {
        case .poweredOff:
            error = NSError(domain: errorWithBluetooth.KBluetoothError, code: 0, userInfo:[NSLocalizedDescriptionKey: errorWithBluetooth.KBluetoothoff])
            break
        case .resetting:
            error = NSError(domain: errorWithBluetooth.KBluetoothError, code: 0, userInfo:[NSLocalizedDescriptionKey: errorWithBluetooth.KBluetoothReseting])
            
            break
        case .unsupported:
            error = NSError(domain: errorWithBluetooth.KBluetoothError, code: 0, userInfo:[NSLocalizedDescriptionKey: errorWithBluetooth.KBluetoothUnsupported])
            
            break
        case .unauthorized:
            error = NSError(domain: errorWithBluetooth.KBluetoothError, code: 0, userInfo:[NSLocalizedDescriptionKey: errorWithBluetooth.KBluetoothUnauthorized])
            
            break
        case .unknown:
            error = NSError(domain: errorWithBluetooth.KBluetoothError, code: 0, userInfo:[NSLocalizedDescriptionKey: errorWithBluetooth.KBluetoothUnknown])
            break
        case .poweredOn:
            error = nil
            self.manager = central
            break
        }
        if (error != nil){
            errorInMeasurenment = error
            errorInMeasurenmentOfOxiMeterValue = error
        }
        
    }
    
    // Implement delegate methods here by accessing the members
    // of the parent through the 'parent' variable
}


public class BLEContinuaDeviceConnector :NSObject{
    
    private var subdelegate :FetcherDelegateWrapper?
    
    /*
     *  @method init() create Instance of the BLEContinuaDeviceConnector class
     *
    
     */
    
    public override init() {
        super.init()
        subdelegate = FetcherDelegateWrapper(parent: self) // Initialze the manager
    }
    
    /*
     *  @method startScanning(forDevice device :BLEDeviceName)
     *
     *  @param device   : Parameter as Input from the User to identify which device to be scanned
     
     */
    
    public func startScanning(forDevice device :BLEDeviceName){
        subdelegate?.startScanning(forDevice: device)
        
    }
    /*
     *  @method stopScanning(fordevice device:BLEDeviceName)
     *
     *   @param device   : Parameter as Input from the User to identify which device to be scan should be stopped
     */
    
    public func stopScanning(fordevice device:BLEDeviceName){
        subdelegate?.stopScanning(fordevice: device)
    }
    
    /*!
     *  @method getMeasurement(fordevice device:BLEDeviceName,success:@escaping ([String:Any]?)->(),completionHandler: ((Error?) -> Void)? = nil)
     *
     *   @param device   : Parameter as Input from the User to identify which device to be scanned
     *    @param success   : Success Callback to be thrown on receiving data
     *   @param completionHandler   : completionHandler Callback to be thrown on receiving error
     */
    
    public func getMeasurement(fordevice device:BLEDeviceName,success:@escaping ([String:Any]?)->(),completionHandler: ((Error?) -> Void)? = nil) {
        subdelegate?.getMeasurement(fordevice: device, success: success, completionHandler:completionHandler)
    }
    
    
    
}
