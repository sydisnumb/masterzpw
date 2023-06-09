import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";

import Nft "../art/nft";

module {

    public type StableBuyer = {
        principal : Principal; 
        username : Text;
        profilePictureUri : Text;
        ownerType : Text;
        ownNfts : [(Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)];
    };
    
    public class Buyer(pr: Principal, user: Text, picUri: Text) {

        private let principal : Principal = pr;
        private let username : Text = user;
        private let profilePictureUri : Text = picUri;
        private let ownerType : Text = "buyer";

        private var ownNfts = HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(0, Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
        
        public func getPrincipal() : Principal = principal;

        public func getUsername() : Text = username;

        public func getProfilePictureUri() : Text = profilePictureUri;

        public func getOwnerType() : Text = ownerType;

        public func getOwnNfts() : HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft> = ownNfts;

        public func getOwnNftsIds() : [Nft.TokenIdentifier.TokenIdentifier] {
            let keys = ownNfts.keys();
            let ids = Iter.toArray(keys);
        };

        public func getOwnNftsMetadata() : [Nft.Nft.TokenMetadata] {
            let nfts = ownNfts.vals();
            let buf = Buffer.Buffer<Nft.Nft.TokenMetadata>(0);

            for (nft in nfts) {
                buf.add(nft.metadata);
            };

            Buffer.toArray(buf);
        };

        public func getOwnNftsSize() : Nat = ownNfts.size();

        public func getOwnNftById(tokenId : Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.get(tokenId);
        };

        public func addNftToOwn(token: Nft.Nft.Nft) : () {
            ownNfts.put(token.tokenId, token);
        };

        public func setNftsToOwn(tokens: [(Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)]) : () {
            ownNfts := HashMap.fromIter<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(tokens.vals(), tokens.size(), Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
        };


        public func removeNftFromOwnById(tokenId: Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.remove(tokenId)
        };

        public func serialize() : StableBuyer {
            let buyer : StableBuyer = {
                principal = principal; 
                username = username;
                profilePictureUri = profilePictureUri;
                ownerType = ownerType;
                ownNfts = Iter.toArray(ownNfts.entries())
            };

        };
    };

    public func serializeBuyers(buyers : Iter.Iter<Buyer>) : [StableBuyer] {
        let buf = Buffer.Buffer<StableBuyer>(0);

        for (buyer in buyers) {
            buf.add(buyer.serialize());
        };

        Buffer.toArray(buf);
    };

    public func deserialize(stableBuyer : StableBuyer) : Buyer {
        let buyer = Buyer(stableBuyer.principal, stableBuyer.username, stableBuyer.profilePictureUri);
        buyer.setNftsToOwn(stableBuyer.ownNfts);
        buyer;
    };

    public func deserializeBuyers(stableBuyers : [StableBuyer]) : [Buyer] {
        let buyersTmp : [Buyer] = Array.tabulate<Buyer>(stableBuyers.size(), func (i) { deserialize(stableBuyers[i]); });
    };


    public func deserializeBuyersToMap(stableBuyers : [StableBuyer]) : HashMap.HashMap<Principal, Buyer> {
        let buyersTmp : [(Principal, Buyer)] = Array.tabulate<(Principal, Buyer)>(stableBuyers.size(), func (i) { (stableBuyers[i].principal, deserialize(stableBuyers[i])); });
        let buyers = HashMap.fromIter<Principal, Buyer>(buyersTmp.vals(), buyersTmp.size(), Principal.equal, Principal.hash);
    };

   

}