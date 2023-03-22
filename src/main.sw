contract;

use std::{
    call_frames::{
        contract_id,
        msg_asset_id,
    },
    auth::msg_sender,
    context::msg_amount,
    token::{
        mint_to_address,
        transfer_to_address,
    },
    address::Address,
};

enum InvalidError {
    NotEnoughTokens: u64,
    IncorrectAssetId: ContractId,
}
//simple checkout is a web based payments system that allows merchants
//to accept payments in any currency, from any country, with minimal fees
//and no chargebacks. It is a decentralized payment system based on Fuel's
//unique ability to move differnt tokens natively, something you cannot do 
//on Ethereum 

//1. Merchant enters the total amount in the local currency
//2. User selects the token to pay with
//3. Make an API call to convert from local currency to token
//4. Pay function is executed

abi SimpleCheckout {
    #[storage(read, write), payable]
    fn checkout(recipient: Address, amount: u64, token: ContractId) -> bool;

    #[storage(read)]
    fn get_counter() -> u64;
}

storage {
        counter: u64 = 0,
}

impl SimpleCheckout for Contract { 

    #[storage(read, write), payable]
    fn checkout(recipient: Address, amount: u64, token: ContractId) -> bool {
        //check that the amount is the same as the amount sent
        let asset_id = msg_asset_id();
        //check that the token is the same as the token sent & is enough
        require(asset_id == token, InvalidError::IncorrectAssetId(asset_id));
        let message_amount = msg_amount();
        require(message_amount >= amount, InvalidError::NotEnoughTokens(message_amount));
        //transfer the tokens to the recipient
       transfer_to_address(amount, token, recipient);
       storage.counter = storage.counter + 1;
       return true;
    }

    #[storage(read)]
    fn get_counter() -> u64 {
        return storage.counter;
    }
}
