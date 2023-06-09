import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";

import Types "../types";

module Nft {
    public type Nft = {
        tokenId : TokenIdentifier.TokenIdentifier;
        owner : Principal;
        metadata : TokenMetadata;
    };


      // Token Metadat (to complete)
    public type TokenMetadata = {
        transferredAt: ?Int;
        transferredBy: ?Principal;
        owner: Principal;
        operator: ?Principal;
        properties: Types.Vec;
        isBurned: Bool;
        tokenIdentifier: TokenIdentifier.TokenIdentifier;
        burnedAt: ?Nat64;
        burnedBy: ?Principal;
        approvedAt: ?Nat64;
        approvedBy: ?Principal;
        mintedAt: Int;
        mintedBy: Principal;
    };

  
    // public func deserializeNftsToMap(nfts : [Nft]) : HashMap.HashMap<TokenIdentifier.TokenIdentifier, Nft> {
    //     let nftsTmp : [(TokenIdentifier.TokenIdentifier, Nft)] = Array.tabulate<(TokenIdentifier.TokenIdentifier, Nft)>(nfts.size(), func (i) { (nfts[i].tokenId, nfts[i]); });
    //     let nfts = HashMap.fromIter<TokenIdentifier.TokenIdentifier, Nft>(nftsTmp.vals(), nftsTmp.size(), TokenIdentifier.equal, TokenIdentifier.hash);
    // };

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
