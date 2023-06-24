import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

import Types "../types";


module  {
   

    public class Company(pr: Principal, user: Text, picUri: Text, bankAddr: Text) = Self {
        
        private let principal : Principal = pr;
        private let username : Text = user;
        private let profilePictureUri : Text = picUri;
        private let bankAddress : Text = bankAddr;
        private let ownerType : Text = "company";

        private var ownNfts = HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft>(1, Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);
        private var soldNfts = HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft>(1, Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);


        public func getPrincipal() : Principal = principal;

        public func getUsername() : Text = username;

        public func getProfilePictureUri() : Text = profilePictureUri;

        public func getBankAddress() : Text = bankAddress;

        public func getOwnerType() : Text = ownerType;

        public func getOwnNfts() : HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft> = ownNfts;

        public func getOwnNftsIds() : [Types.TokenIdentifier.TokenIdentifier] {
            let keys = ownNfts.keys();
            let ids = Iter.toArray(keys);
        };

        public func getOwnNftsMetadata() : [Types.Nft.TokenMetadata] {
            let nfts = ownNfts.vals();
            let buf = Buffer.Buffer<Types.Nft.TokenMetadata>(0);

            for (nft in nfts) {
                buf.add(nft.metadata);
            };

            Buffer.toArray(buf);
        };

        public func getSoldNfts() : HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft> = soldNfts;

        public func getOwnNftsSize() : Nat = ownNfts.size();

        public func getSoldNftsSize() : Nat = soldNfts.size();


        public func getOwnNftById(tokenId : Types.TokenIdentifier.TokenIdentifier) : ?Types.Nft.Nft {
            ownNfts.get(tokenId);
        };

        public func getSoldNftById(tokenId : Types.TokenIdentifier.TokenIdentifier) : ?Types.Nft.Nft {
            soldNfts.get(tokenId);
        };

        public func setNftsToOwn(tokens: [(Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft)]) : () {
            ownNfts := HashMap.fromIter<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft>(tokens.vals(), tokens.size(), Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);
        };

        public func setNftsToSold(tokens: [(Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft)]) : () {
            soldNfts := HashMap.fromIter<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft>(tokens.vals(), tokens.size(), Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);
        };

        public func addNftToOwn(token: Types.Nft.Nft) : () {
            ownNfts.put(token.tokenId, token);
        };

        public func addNftsToSold(token: (Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft)) : () {
            soldNfts.put(token.0, token.1);
        };

        public func removeNftFromOwnById(tokenId: Types.TokenIdentifier.TokenIdentifier) : ?Types.Nft.Nft {
            ownNfts.remove(tokenId);
        };

        public func deletNftFromOwnById(tokenId: Types.TokenIdentifier.TokenIdentifier) : () {
            ownNfts.delete(tokenId);
        };

        public func serialize() : Types.UsersTypes.StableCompany {
            let buyer : Types.UsersTypes.StableCompany = {
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


    public func serializeCompanies(companies : Iter.Iter<Company>) : [Types.UsersTypes.StableCompany] {
        let buf = Buffer.Buffer<Types.UsersTypes.StableCompany>(0);

        for (company in companies) {
            buf.add(company.serialize());
        };

        Buffer.toArray(buf);
    };


    public func deserialize(stableCompany : Types.UsersTypes.StableCompany) : Company {
        let company = Company(stableCompany.principal, stableCompany.username, stableCompany.profilePictureUri, stableCompany.bankAddress);
        company.setNftsToOwn(stableCompany.ownNfts);
        company.setNftsToSold(stableCompany.soldNfts);
        company;
    };

    public func deserializeCompanies(stableCompanies : Iter.Iter<Types.UsersTypes.StableCompany>) : [Company] {
        let buf = Buffer.Buffer<Company>(0);

        for (company in stableCompanies) {
            buf.add(deserialize(company));
        };

        Buffer.toArray(buf);
    };

    public func deserializeCompaniesToMap(stableCompanies : [Types.UsersTypes.StableCompany]) : HashMap.HashMap<Principal, Company> {
        let companiesTmp : [(Principal, Company)] = Array.tabulate<(Principal, Company)>(stableCompanies.size(), func (i) { (stableCompanies[i].principal, deserialize(stableCompanies[i])); });
        let companies = HashMap.fromIter<Principal, Company>(companiesTmp.vals(), companiesTmp.size(), Principal.equal, Principal.hash);
    };
};