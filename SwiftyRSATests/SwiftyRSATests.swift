//
//  SwiftyRSATests.swift
//  SwiftyRSATests
//
//  Created by Loïs Di Qual on 7/2/15.
//  Copyright (c) 2015 Scoop. All rights reserved.
//

import UIKit
import XCTest
import SwiftyRSA

class SwiftyRSATests: XCTestCase {
    
    func testClassPEM() {
        let str = "ClearText"
        
        let pubString = TestUtils.pemKeyString(name: "swiftyrsa-public")
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private")
        
        let encrypted = try! SwiftyRSA.encryptString(str, publicKeyPEM: pubString)
        let decrypted = try! SwiftyRSA.decryptString(encrypted, privateKeyPEM: privString)
        
        XCTAssertEqual(str, decrypted)
    }
    
    func testClassDER() {
        let str = "ClearText"
        
        let pubData = TestUtils.derKeyData(name: "swiftyrsa-public")
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private")
        
        let encrypted = try! SwiftyRSA.encryptString(str, publicKeyDER: pubData)
        let decrypted = try! SwiftyRSA.decryptString(encrypted, privateKeyPEM: privString)
        
        XCTAssert(str == decrypted)
    }
    
    func testPEM() {
        let str = "ClearText"
        
        let rsa = SwiftyRSA()
        
        let pubString = TestUtils.pemKeyString(name: "swiftyrsa-public")
        let pubKey    = try! rsa.publicKeyFromPEMString(pubString)
        
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private")
        let privKey    = try! rsa.privateKeyFromPEMString(privString)
        
        let encrypted = try! rsa.encryptString(str, publicKey: pubKey)
        let decrypted = try! rsa.decryptString(encrypted, privateKey: privKey)
        
        XCTAssertEqual(str, decrypted)
    }
    
    func testDER() {
        let str = "ClearText"
        
        let rsa = SwiftyRSA()
        
        let pubData = TestUtils.derKeyData(name: "swiftyrsa-public")
        let pubKey  = try! rsa.publicKeyFromDERData(pubData)
        
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private")
        let privKey    = try! rsa.privateKeyFromPEMString(privString)
        
        let encrypted = try! rsa.encryptString(str, publicKey: pubKey)
        let decrypted = try! rsa.decryptString(encrypted, privateKey: privKey)
        
        XCTAssertEqual(str, decrypted)
    }
    
    func testPEMHeaderless() {
        let str = "ClearText"
        
        let pubString = TestUtils.pemKeyString(name: "swiftyrsa-public-headerless")
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private-headerless")
        
        let encrypted = try! SwiftyRSA.encryptString(str, publicKeyPEM: pubString)
        let decrypted = try! SwiftyRSA.decryptString(encrypted, privateKeyPEM: privString)
        
        XCTAssertEqual(str, decrypted)
    }
    
    func testLongString() {
        let str = [String](count: 9999, repeatedValue: "a").joinWithSeparator("")
        
        let pubString = TestUtils.pemKeyString(name: "swiftyrsa-public")
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private")
        
        let encrypted = try! SwiftyRSA.encryptString(str, publicKeyPEM: pubString)
        let decrypted = try! SwiftyRSA.decryptString(encrypted, privateKeyPEM: privString)
        
        XCTAssertEqual(str, decrypted)
    }
    
    func testDataEncryptDecrypt() {
        let bytes = [UInt32](count: 2048, repeatedValue: 0).map { _ in arc4random() }
        let data = NSData(bytes: bytes, length: bytes.count * sizeof(UInt32))
        
        let pubString = TestUtils.pemKeyString(name: "swiftyrsa-public")
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private")
        
        let encrypted = try! SwiftyRSA.encryptData(data, publicKeyPEM: pubString)
        let decrypted = try! SwiftyRSA.decryptData(encrypted, privateKeyPEM: privString)
        
        XCTAssertEqual(data, decrypted)
    }
    
    func testSignVerify() {
        
        
        let bytes = [UInt32](count: 2048, repeatedValue: 0).map { _ in arc4random() }
        let data = NSData(bytes: bytes, length: bytes.count * sizeof(UInt32))
        
        let testString = "Lorum Ipsum Ipso Facto Ad Astra Ixnay Onay Ayway"
        
        let pubString = TestUtils.pemKeyString(name: "swiftyrsa-public")
        let privString = TestUtils.pemKeyString(name: "swiftyrsa-private")
        
        let pubData = TestUtils.derKeyData(name: "swiftyrsa-public")
        
        let rsa = SwiftyRSA()
        
        let pubKey = try! rsa.publicKeyFromPEMString(pubString)
        let privKey = try! rsa.privateKeyFromPEMString(privString)
        
        let hashingMethods: [SwiftyRSA.DigestType] = [.SHA1, .SHA224, .SHA256, .SHA384, .SHA512]
        
        for method in hashingMethods {
            let digestSignature = try! SwiftyRSA.signData(data, privateKeyPEM: privString, digestMethod: method)
            var result = try! SwiftyRSA.verifySignatureData(data, signature: digestSignature, publicKeyPEM: pubString, digestMethod: method)
            XCTAssert(result)
            
            let signatureString = try! SwiftyRSA.signString(testString, privateKeyPEM: privString, digestMethod: method)
            result = try! SwiftyRSA.verifySignatureString(testString, signature: signatureString, publicKeyPEM: pubString, digestMethod: method)
            XCTAssert(result)
            
            result = try! SwiftyRSA.verifySignatureString(testString, signature: signatureString, publicKeyDER: pubData, digestMethod: method)
            XCTAssert(result)
        }
        
        let signature = try! SwiftyRSA.signData(data, privateKeyPEM: privString)
        
        var result = try! SwiftyRSA.verifySignatureData(data, signature: signature, publicKeyPEM: pubString)
        XCTAssert(result)
        
        result = try! SwiftyRSA.verifySignatureData(data, signature:  signature, publicKeyDER:  pubData)
        XCTAssert(result)
        
        let badBytes = [UInt32](count: 16, repeatedValue: 0).map { _ in arc4random() }
        let badData = NSData(bytes: badBytes, length: badBytes.count * sizeof(UInt32))
        
        result = try! SwiftyRSA.verifySignatureData(badData, signature:  signature, publicKeyPEM: pubString)
        XCTAssert(!result)
        
        
        var digest=data.SwiftyRSASHA1()
        
        var digestSignature = try! rsa.signSHA1Digest(digest, privateKey: privKey)
        
        result = try! rsa.verifySHA1SignatureData(digest, signature: digestSignature, publicKey: pubKey)
        XCTAssert(result)
        
        digest = data.SwiftyRSASHA224()
        
        digestSignature = try! rsa.signDigest(digest, privateKey: privKey, digestMethod: .SHA224)
        
        result = try! rsa.verifySignatureData(digest, signature: digestSignature, publicKey: pubKey, digestMethod: .SHA224)
        XCTAssert(result)
        
        digest = data.SwiftyRSASHA256()
        
        digestSignature = try! rsa.signDigest(digest, privateKey: privKey, digestMethod: .SHA256)
        
        result = try! rsa.verifySignatureData(digest, signature: digestSignature, publicKey: pubKey, digestMethod: .SHA256)
        XCTAssert(result)
        
        digest = data.SwiftyRSASHA384()
        
        digestSignature = try! rsa.signDigest(digest, privateKey: privKey, digestMethod: .SHA384)
        
        result = try! rsa.verifySignatureData(digest, signature: digestSignature, publicKey: pubKey, digestMethod: .SHA384)
        XCTAssert(result)
        
        digest = data.SwiftyRSASHA512()
        
        digestSignature = try! rsa.signDigest(digest, privateKey: privKey, digestMethod: .SHA512)
        
        result = try! rsa.verifySignatureData(digest, signature: digestSignature, publicKey: pubKey, digestMethod: .SHA512)
        XCTAssert(result)
        
    }
    
}
