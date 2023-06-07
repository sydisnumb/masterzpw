import User "../masterzpw_backend/model/users";
import Debug "mo:base/Debug";

actor {
    public shared query (msg) func test_buyer() : async Principal {
        var principal = msg.caller;
        
        let op : User.Company = User.Company(principal, "test", "test", "test");
        let stableCompany = op.serialize();
        Debug.print(stableCompany.2);

        stableCompany.0;

    };
};