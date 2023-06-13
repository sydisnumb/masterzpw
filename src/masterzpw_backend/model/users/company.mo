import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

import Nft "../art/nft";


module  {

                                // (principal, username, pic, bank, type, owns, sold)
    public type StableCompany = {
        principal : Principal; 
        username : Text;
        profilePictureUri : Text;
        bankAddress : Text;
        ownerType : Text;
        ownNfts : [(Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)];
        soldNfts : [(Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)];
    };

    public class Company(pr: Principal, user: Text, picUri: Text, bankAddr: Text) = Self {
        
        private let principal : Principal = pr;
        private let username : Text = user;
        private let profilePictureUri : Text = picUri;
        private let bankAddress : Text = bankAddr;
        private let ownerType : Text = "company";

        private var ownNfts = HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(1, Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
        private var soldNfts = HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(1, Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);


        public func getPrincipal() : Principal = principal;

        public func getUsername() : Text = username;

        public func getProfilePictureUri() : Text = profilePictureUri;

        public func getBankAddress() : Text = bankAddress;

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

        public func getSoldNfts() : HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft> = soldNfts;

        public func getOwnNftsSize() : Nat = ownNfts.size();

        public func getSoldNftsSize() : Nat = soldNfts.size();


        public func getOwnNftById(tokenId : Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.get(tokenId);
        };

        public func getSoldNftById(tokenId : Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            soldNfts.get(tokenId);
        };

        public func setNftsToOwn(tokens: [(Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)]) : () {
            ownNfts := HashMap.fromIter<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(tokens.vals(), tokens.size(), Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
        };

        public func setNftsToSold(tokens: [(Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)]) : () {
            soldNfts := HashMap.fromIter<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(tokens.vals(), tokens.size(), Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
        };

        public func addNftToOwn(token: Nft.Nft.Nft) : () {
            ownNfts.put(token.tokenId, token);
        };

        public func addNftsToSold(token: (Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)) : () {
            soldNfts.put(token.0, token.1);
        };

        public func removeNftFromOwnById(tokenId: Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft {
            ownNfts.remove(tokenId);
        };

        public func deletNftFromOwnById(tokenId: Nft.TokenIdentifier.TokenIdentifier) : () {
            ownNfts.delete(tokenId);
        };

        public func serialize() : StableCompany {
            let buyer : StableCompany = {
                principal = principal; 
                username = username;
                profilePictureUri = profilePictureUri;
                bankAddress = bankAddress;
                ownerType = ownerType;
                ownNfts = Iter.toArray(ownNfts.entries());
                soldNfts = Iter.toArray(soldNfts.entries());
            };
        };

    };


    public func serializeCompanies(companies : Iter.Iter<Company>) : [StableCompany] {
        let buf = Buffer.Buffer<StableCompany>(0);

        for (company in companies) {
            buf.add(company.serialize());
        };

        Buffer.toArray(buf);
    };


    public func deserialize(stableCompany : StableCompany) : Company {
        let company = Company(stableCompany.principal, stableCompany.username, stableCompany.profilePictureUri, stableCompany.bankAddress);
        company.setNftsToOwn(stableCompany.ownNfts);
        company.setNftsToSold(stableCompany.soldNfts);
        company;
    };

    public func deserializeCompanies(stableCompanies : Iter.Iter<StableCompany>) : [Company] {
        let buf = Buffer.Buffer<Company>(0);

        for (company in stableCompanies) {
            buf.add(deserialize(company));
        };

        Buffer.toArray(buf);
    };

    public func deserializeCompaniesToMap(stableCompanies : [StableCompany]) : HashMap.HashMap<Principal, Company> {
        let companiesTmp : [(Principal, Company)] = Array.tabulate<(Principal, Company)>(stableCompanies.size(), func (i) { (stableCompanies[i].principal, deserialize(stableCompanies[i])); });
        let companies = HashMap.fromIter<Principal, Company>(companiesTmp.vals(), companiesTmp.size(), Principal.equal, Principal.hash);
    };
};