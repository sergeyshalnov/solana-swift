//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func sendTokens(from fromPublicKey: String, to toPublicKey: String, amount: Int64) -> Single<String> {
        getRecentBlockhash()
            .flatMap { recentBlockhash in
                guard let account = self.accountStorage.account else {
                    throw Error.publicKeyNotFound
                }
                let fromPublicKey = try PublicKey(string: fromPublicKey)
                let toPublicKey = try PublicKey(string: toPublicKey)
                let signer = account
                
                var transaction = Transaction()
                transaction.message.add(instruction: SystemProgram.transfer(from: fromPublicKey, to: toPublicKey, lamports: UInt64(amount)))
                transaction.message.recentBlockhash = recentBlockhash
                try transaction.sign(signers: [signer])
                guard let serializedTransaction = try transaction.serialize().toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return self.sendTransaction(serializedTransaction: serializedTransaction)
            }
    }
    
    public func getCreatingTokenAccountFee() -> Single<UInt64> {
        getMinimumBalanceForRentExemption(dataLength: AccountLayout.span)
    }

    public func createTokenAccount(mintAddress: String, in network: String) -> Single<String> {
        guard let payer = self.accountStorage.account else {
            return .error(Error.publicKeyNotFound)
        }

        return Single.zip(getRecentBlockhash(), getCreatingTokenAccountFee())
            .flatMap { (recentBlockhash, minBalance) in
                
                let mintAddress = try PublicKey(string: mintAddress)
                
                // create new account for token
                let newAccount = try Account(network: network)
                
                // instructions
                let createAccount = SystemProgram.createAccount(from: payer.publicKey, toNewPubkey: newAccount.publicKey, lamports: minBalance)
                
                let initializeAccount = SystemProgram.initializeAccount(account: newAccount.publicKey, mint: mintAddress, owner: payer.publicKey)
                
                // forming transaction
                var transaction = Transaction()
                transaction.message.add(instruction: createAccount)
                transaction.message.add(instruction: initializeAccount)
                transaction.message.recentBlockhash = recentBlockhash
                try transaction.sign(signers: [payer, newAccount])
                
                guard let serializedTransaction = try transaction.serialize().toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return self.sendTransaction(serializedTransaction: serializedTransaction)
            }
    }
}
