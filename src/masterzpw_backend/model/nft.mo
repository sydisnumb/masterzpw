import Types "types";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";

module Nft {
    public type Nft = {
        tokenId : TokenIdentifier.TokenIdentifier;
        mintedAt : Nat64;
        mintedBy : Principal;
        properties : Types.Vec;
        owner : Principal;
        metadat : TokenMetadata;
    };


      // Token Metadat (to complete)
    public type TokenMetadata = {
        transferred_at: Nat64;
        transferred_by: Principal;
        owner: Principal;
        operator: Principal;
        properties: Types.Vec;
        is_burned: Bool;
        token_identifier: Nat;
        burned_at: Nat64;
        burned_by: Principal;
        approved_at: Nat64;
        approved_by: Principal;
        minted_at: Nat64;
        minted_by: Principal;
    };

};


module TokenIdentifier {
  public type TokenIdentifier = Nat64;

  public func hash(tokenId : TokenIdentifier) : Nat32 {
    let text = Nat64.toText(tokenId);
    Text.hash(text);
  };

  public func equal(tokenId1 : TokenIdentifier, tokenId2 : TokenIdentifier) : Bool {
    tokenId1 == tokenId2;
  };

  
};
