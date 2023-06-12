import Ledger "canister:ledger";
import Principal "mo:base/Principal";

import Nft "./model/art/nft";
import Types "./model/types";

actor {

    public shared ({caller}) func hello(tokenId: Nft.TokenIdentifier.TokenIdentifier) : async Types.Result<Principal, Types.NftError> {
        await Ledger.ownerOf(tokenId);
    };
    

}