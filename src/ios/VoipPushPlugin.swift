import Foundation
import AVFoundation
import PushKit

@objc(VoipPush)
class VoipPush : CDVPlugin, PKPushRegistryDelegate {
    var callbackId: String?
    var pushRegistry: PKPushRegistry?
    
    open func register(_ command:CDVInvokedUrlCommand) {
        self.commandDelegate.run(inBackground: {
            self.callbackId = command.callbackId
        
            self.pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
            self.pushRegistry?.delegate = self
            self.pushRegistry?.desiredPushTypes = [.voIP]
        })
    }

    open func testMe(_ command:CDVInvokedUrlCommand) {
        var message = command.argument(at: 0) as! String

        print("testMe called with message: /(message)")
    }
    
    override func onReset() {
        print("VoipPush#onReset() | doing nothing")
    }
    
    
    override func onAppTerminate() {
        print("VoipPush#onAppTerminate() | doing nothing")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        print("credentials: \(credentials.token.hexString())")
        /*
        self.emit(
            data: [
                "eventHandler": "voipPushRegister",
                "data": credentials.token.hexString()
            ]
        )
        */
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        
    self.commandDelegate.run(inBackground: {
        guard type == .voIP else { return }
        
        let uuid = UUID().uuidString
        
        print("UUID: \(uuid)")
        
        self.emit(
            data: [
                "eventHandler": "voipPushPayload",
                "data": uuid
            ]
        )
        /*
        if (payload.dictionaryPayload["aps"] != nil) {
            print("incoming.push: \(payload.dictionaryPayload)")
            
            let pushPayload = payload.dictionaryPayload["aps"] as? NSObject
            
            let uuid = UUID()
            
            print("UUID: \(uuid)")
            
            self.emit(
                data: [
                    "eventHandler": "voipPushPayload",
                    "data": [
                        "event": pushPayload?.value(forKeyPath: "data.event") as! String,
                        "uuid": uuid.uuidString,
                        "data": pushPayload?.value(forKey: "data") as! NSDictionary
                    ]
                ]
            )
        }
        */
      })
        
    }
    
    private func emit(data: NSDictionary) {
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data as [NSObject : AnyObject])
        
        result!.setKeepCallbackAs(true);
        
        //DispatchQueue.main.async {
            self.commandDelegate!.send(result, callbackId: self.callbackId)
        //}
    }
}

extension Data {
    func hexString() -> String {
        var bytesPointer: UnsafeBufferPointer<UInt8> = UnsafeBufferPointer(start: nil, count: 0)
        self.withUnsafeBytes { (bytes) in
            bytesPointer = UnsafeBufferPointer<UInt8>(start: UnsafePointer(bytes), count:self.count)
        }
        let hexBytes = bytesPointer.map { return String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

