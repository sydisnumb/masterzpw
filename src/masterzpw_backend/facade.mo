import Float "mo:base/Float";
import Principal "mo:base/Principal";

import Company "./model/users/company";
import Buyer "./model/users/buyer";
import Types "./model/types";
import Nat64 "mo:base/Nat64";
import Ledger "canister:ledger";

actor {

    public shared ({caller}) func login(): async Types.GenericTypes.Result<Types.GenericTypes.User<Types.UsersTypes.StableBuyer, Types.UsersTypes.StableCompany>, Types.GenericTypes.Error> {
        await Ledger.login(caller);
    };

    public shared ({caller}) func createCompany(username : Text, profilePictureUri : Text, bankAddress: Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        await Ledger.createCompany(caller, username, profilePictureUri, bankAddress);
    };

    public shared ({caller}) func createBuyer(username : Text, profilePictureUri : Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        await Ledger.createBuyer(caller, username, profilePictureUri);
    };

    public shared ({caller}) func createNewOpera(operaName : Text, operaDescription: Text, operaPicUri : Text, operaPrice: Float) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
        await Ledger.createNewOpera(caller, operaName, operaDescription, operaPicUri, operaPrice, 1);
    };

    // public shared ({caller}) func getOpera(operaId : Text) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
    //     await Ledger.getOpera(operaId);
    // };

    public shared ({caller}) func getBuyer(owner : Principal) : async Types.GenericTypes.Result<Types.UsersTypes.StableBuyer, Types.GenericTypes.Error> {
        await Ledger.getBuyer(owner);
    };

    // public shared ({caller}) func getBuyers(page : Nat) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
    //     await Ledger.createNewOpera(caller, page);
    // };


    public shared ({caller}) func getCompany() : async Types.GenericTypes.Result<Types.UsersTypes.StableCompany, Types.GenericTypes.Error> {
        let res = await Ledger.getCompany(caller);

        switch res {
            case (#Ok(stableComp)) { return #Ok(stableComp); };
            case (#Err(_)) { return #Err(#SomethingWentWrong); };
        }
    };


    public shared ({caller}) func getCompanies(page : Nat) : async Types.GenericTypes.Result<[Types.UsersTypes.StableCompany], Types.GenericTypes.Error> {
        let res = await Ledger.getCompanies(caller, page);

        switch res {
            case (#Ok(stableComps)) { return #Ok(stableComps); };
            case (#Err(_)) { return #Err(#SomethingWentWrong); };
        }
    };

    

}