import Ledger "canister:ledger";
import Principal "mo:base/Principal";

actor {

    public query ({caller}) func hello() : async Principal{
        await Ledger.ownerOf();
        caller;
    };
    

}