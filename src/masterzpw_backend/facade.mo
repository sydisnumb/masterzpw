import Ledger "canister:ledger";
import Float "mo:base/Float";
import Principal "mo:base/Principal";

import Nft "./model/art/nft";
import Company "./model/users/company";
import Buyer "./model/users/buyer";
import Types "./model/types";
import Nat64 "mo:base/Nat64";

import Errors "errors"

actor {

    public shared ({caller}) func hello(tokenId: Nft.TokenIdentifier.TokenIdentifier) : async Types.Result<Principal, Types.NftError> {
        await Ledger.ownerOf(tokenId);
    };

    public shared ({caller}) func createCompany(username : Text, profilePictureUri : Text, bankAddress: Text) : async Types.Result<Principal, Types.NftError> {
        await Ledger.createCompany(caller, username, profilePictureUri, bankAddress);
    };

    public shared ({caller}) func createBuyer(username : Text, profilePictureUri : Text) : async Types.Result<Principal, Types.NftError> {
        await Ledger.createBuyer(caller, username, profilePictureUri);
    };

    public shared ({caller}) func createNewOpera(operaName : Text, operaDescription: Text, operaPicUri : Text, operaPrice: Float) : async Types.Result<Nat64, Types.NftError> {
        await Ledger.createNewOpera(caller, operaName, operaDescription, operaPicUri, operaPrice, 1);
    };

    // public shared ({caller}) func getOpera(operaId : Text) : async Types.Result<Nat64, Types.NftError> {
    //     await Ledger.getOpera(operaId);
    // };

    public shared ({caller}) func getBuyer(owner : Principal) : async Types.Result<Buyer.StableBuyer, Types.NftError> {
        await Ledger.getBuyer(owner);
    };

    // public shared ({caller}) func getBuyers(page : Nat) : async Types.Result<Nat64, Types.NftError> {
    //     await Ledger.createNewOpera(caller, page);
    // };


    public shared ({caller}) func getCompany() : async Types.Result<Company.StableCompany, Errors.GenericError> {
        let res = await Ledger.getCompany(caller);

        switch res {
            case (#Ok(stableComp)) { return #Ok(stableComp); };
            case (#Err(_)) { return #Err(#SomethingWentWrong); };
        }
    };


    public shared ({caller}) func getCompanies(page : Nat) : async Types.Result<[Company.StableCompany], Errors.GenericError> {
        let res = await Ledger.getCompanies(caller, page);

        switch res {
            case (#Ok(stableComps)) { return #Ok(stableComps); };
            case (#Err(_)) { return #Err(#SomethingWentWrong); };
        }
    };

    

}