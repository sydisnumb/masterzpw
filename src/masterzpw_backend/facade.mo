import Float "mo:base/Float";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";


import Company "./model/users/company";
import Buyer "./model/users/buyer";
import Types "./model/types";

import Ledger "canister:ledger";


actor {

    public shared ({caller}) func login(): async Types.GenericTypes.Result<Types.GenericTypes.User<Types.UsersTypes.StableBuyer, Types.UsersTypes.StableCompany>, Types.GenericTypes.Error> {
        await Ledger.login(caller);
    };

    public shared ({caller}) func createCompany(username : Text, profilePictureUri : Text, bankAddress: Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        if (username != "" and bankAddress != "") {
            return await Ledger.createCompany(caller, username, profilePictureUri, bankAddress);
        };
        
        return #Err(#Other("Be sure to insert all required fields."))
    };

    public shared ({caller}) func createBuyer(username : Text, profilePictureUri : Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        await Ledger.createBuyer(caller, username, profilePictureUri);
    };

    public shared ({caller}) func createNewOpera(operaName : Text, operaDescription: Text, operaPicUri : Text, operaPrice: Float) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
        await Ledger.createNewOpera(caller, operaName, operaDescription, operaPicUri, operaPrice, 1);
    };

    public shared ({caller}) func getOpera(operaId : Nat64) : async Types.GenericTypes.Result<Types.Opera.StableOpera, Types.GenericTypes.Error> {
        await Ledger.getOpera(operaId);
    };

    public shared ({caller}) func getOperas(page : Nat) : async Types.GenericTypes.Result<[Types.Opera.StableOpera], Types.GenericTypes.Error> {
        await Ledger.getOperasByPage(page);
    };

    public shared ({caller}) func checkOperas(): async Bool {
        let res = await Ledger.getOperasSize();
        return res > 0;
    };


    public shared ({caller}) func getOwnOperas(ownerType: Text, page : Nat): async Types.GenericTypes.Result<[Types.Opera.StableOpera], Types.GenericTypes.Error>  {
        if(ownerType=="company") {
            await Ledger.getOwnOperasByCompany(caller, page);
        } else {
            await Ledger.getOwnOperasByBuyer(caller, page);
        }
    };

    public shared ({caller}) func getSoldOperas(ownerType: Text, page : Nat): async Types.GenericTypes.Result<[Types.Opera.StableOpera], Types.GenericTypes.Error>  {
        await Ledger.getSoldOperasByCompany(caller, page);
    };


    public shared ({caller}) func getBuyer() : async Types.GenericTypes.Result<Types.UsersTypes.StableBuyer, Types.GenericTypes.Error> {
        await Ledger.getBuyer(caller);
    };

    // public shared ({caller}) func getBuyers(page : Nat) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
    //     await Ledger.createNewOpera(caller, page);
    // };


    public shared ({caller}) func getCompany() : async Types.GenericTypes.Result<Types.UsersTypes.StableCompany, Types.GenericTypes.Error> {
        let res = await Ledger.getCompany(caller);

        switch res {
            case (#Ok(stableComp)) { return #Ok(stableComp); };
            case (#Err(_)) { return #Err(#SomethingWentWrong(true)); };
        }
    };

}