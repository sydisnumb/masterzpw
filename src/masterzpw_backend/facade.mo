import Ledger "canister:ledger";
import Float "mo:base/Float";
import Principal "mo:base/Principal";

import Nft "./model/art/nft";
import Types "./model/types";
import Nat64 "mo:base/Nat64";

actor {

    public shared ({caller}) func hello(tokenId: Nft.TokenIdentifier.TokenIdentifier) : async Types.Result<Principal, Types.NftError> {
        await Ledger.ownerOf(tokenId);
    };

    public shared ({caller}) func createCompany(username : Text, profilePictureUri : Text, bankAddress: Text) : async Types.Result<Principal, Types.NftError> {
        await Ledger.createCompany(caller, username, profilePictureUri, bankAddress);
    };

    public shared ({caller}) func createNewOpera(operaName : Text, operaDescription: Text, operaPicUri : Text, operaPrice: Float) : async Types.Result<Nat64, Types.NftError> {
        await Ledger.createNewOpera(caller, operaName, operaDescription, operaPicUri, operaPrice, 1);
    };
    

}