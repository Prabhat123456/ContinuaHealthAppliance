# ContinuaHealthAppliance
The Continua Design Guidelines (CDG) defines a framework of underlying standards and criteria that are required to ensure the interoperability of components1 used for applications monitoring personal health and wellness. 
They also contain design guidelines that further clarify the underlying standards or specifications by reducing options or by adding missing features to improve interoperability. 
These guidelines focus on the following interfaces: - Personal Health Devices (PHD) Interface - Interface between a PHD and a Personal Health Gateway (PHG). - Services Interface – Interface between PHG and a Health &amp; Fitness Service (HFS). - Healthcare Information System (HIS) Interface – Interface between a HFS and a HIS. 
So I developed a framework which you can plugin in your mobile Apps and Start Communicating with Any Oximeter and Thermometer which adhere to the basic principles of Continua Architecture.
Any company which is Philips , Honeywell or any other company which produces Oximeter and Thermometer and if they are continua complient you can plugin this framewok and start connecting with those devices as of Now this framework is listening to below service identifier :

/**
 * BLEServiceIdentifier has the Service ID of Thermometer and OxiMeter
 
 */
private enum BLEServiceIdentifier :String{
    case BLEThermometerServiceID = "1809"
    case  BLEOximeterServiceID =   "1822"
}

Below are the characterstics 

/**
 * BLEScratchIdentifier represent to Characterstic ID for the Service (BLEServiceIdentifier)
 
 */
private enum BLEScratchIdentifier :String{
    case BLEThermometerScratchID = "2A1C"
    case BLEOximeterScratchID = "2A5F"
}

