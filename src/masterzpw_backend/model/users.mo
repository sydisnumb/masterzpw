import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";
import Prim "mo:⛔";
import HashMap "mo:base/HashMap";
import List "mo:base/List";


import Types "./types";
import Nft "nft";

// module {

//     public class Company(pr: Principal, user: Text, picUri: Text, bankAddr: Text) {
        
//         private let principal : Principal = pr;
//         private let username : Text = user;
//         private let profilePictureUri : Text = picUri;
//         private let bankAddress : Text = bankAddr;
//         private let ownerType : Text = "company";

//         private let ownNfts = HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Art.Nft>(0, Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);
//         private let soldNfts = HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Art.Nft>(0, Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);


//         public func getPrincipal() : Principal {
//             principal;
//         };

//         public func getUsername() : Text {
//             username;
//         };

//         public func getProfilePictureUri() : Text {
//             profilePictureUri;
//         };

//         public func getBankAddress() : Text {
//             bankAddress;
//         };

//         public func getOwnerType() : Text {
//             ownerType;
//         };

//         public func getOwnNfts() : HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Art.Nft> {
//             ownNfts;
//         };

//         public func getSoldNfts() : HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Art.Nft> {
//             soldNfts;
//         };

//         public func getOwnNftById(tokenId : Types.TokenIdentifier.TokenIdentifier) : ?Art.Nft {
//             ownNfts.get(tokenId);
//         };

//         public func getSoldNftById(tokenId : Types.TokenIdentifier.TokenIdentifier) : ?Art.Nft {
//             soldNfts.get(tokenId);
//         };

//         public func addNftsToOwns(tokens: [Art.Nft]) : () {
//             List.iterate<Art.Nft>(List.fromArray<Art.Nft>(tokens), func tok {ownNfts.put(tok.getTokenId(), tok);});
//         };

//         public func addNftsToSold(tokens: [Art.Nft]) : () {
//             List.iterate<Art.Nft>(List.fromArray<Art.Nft>(tokens), func tok {soldNfts.put(tok.getTokenId(), tok);});

//         };

//         public func removeNftFromOwnById(tokenId: Types.TokenIdentifier.TokenIdentifier) : ?Art.Nft {
//             ownNfts.remove(tokenId)
//         };

//     };

    
// }

// module Users {
//     type Company = {
//         principal : Principal;
//         username : Text;
//         profilePictureUri : Text;
//         bankAddress : Text;
//         ownerType : Text;
//         ownNfts : HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Art.Nft>(0, Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);
//         soldNfts :
//     }
// }

module  {

                                // (principal, username, pic, bank, type, owns, sold)
    public type StableCompany = (Principal, Text, Text, Text, Text, HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>, HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>);
    public class Company(pr: Principal, user: Text, picUri: Text, bankAddr: Text) {
        
        private let principal : Principal = pr;
        private let username : Text = user;
        private let profilePictureUri : Text = picUri;
        private let bankAddress : Text = bankAddr;
        private let ownerType : Text = "company";

        private let ownNfts = HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(0, Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
        private let soldNfts = HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(0, Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);


        public func getPrincipal() : Principal = principal;

        public func getUsername() : Text = username;

        public func getProfilePictureUri() : Text = profilePictureUri;

        public func getBankAddress() : Text = bankAddress;

        public func getOwnerType() : Text = ownerType;

        public func getOwnNfts() : HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft> = ownNfts;

        public func getSoldNfts() : HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft> = soldNfts;

        public func getOwnNftById(tokenId : Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.get(tokenId);
        };

        public func getSoldNftById(tokenId : Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            soldNfts.get(tokenId);
        };

        public func addNftsToOwns(tokens: [Nft.Nft.Nft]) : () {
            List.iterate<Nft.Nft.Nft>(List.fromArray<Nft.Nft.Nft>(tokens), func tok {ownNfts.put(tok.tokenId, tok);});
        };

        public func addNftsToSold(tokens: [Nft.Nft.Nft]) : () {
            List.iterate<Nft.Nft.Nft>(List.fromArray<Nft.Nft.Nft>(tokens), func tok {soldNfts.put(tok.tokenId, tok);});
        };

        public func removeNftFromOwnById(tokenId: Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.remove(tokenId)
        };

        public func serialize() : StableCompany {
            (principal, username, profilePictureUri, bankAddress, ownerType, ownNfts, soldNfts);
        };

    };


    public type StableBuyer = (Principal, Text, Text, Text, HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>);
    public class Buyer(pr: Principal, user: Text, picUri: Text) {
        
        private let principal : Principal = pr;
        private let username : Text = user;
        private let profilePictureUri : Text = picUri;
        private let ownerType : Text = "buyer";

        private let ownNfts = HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(0, Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);

        public func getPrincipal() : Principal = principal;

        public func getUsername() : Text = username;

        public func getProfilePictureUri() : Text = profilePictureUri;

        public func getOwnerType() : Text = ownerType;

        public func getOwnNfts() : HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft> = ownNfts;

        public func getOwnNftById(tokenId : Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.get(tokenId);
        };

        public func addNftsToOwns(tokens: [Nft.Nft.Nft]) : () {
            List.iterate<Nft.Nft.Nft>(List.fromArray<Nft.Nft.Nft>(tokens), func tok {ownNfts.put(tok.tokenId, tok);});
        };

        public func removeNftFromOwnById(tokenId: Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.remove(tokenId)
        };

        public func serialize() : StableBuyer {
            (principal, username, profilePictureUri, ownerType, ownNfts);
        };
    };
};