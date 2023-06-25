import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";

import Types "./model/types";
import Company "./model/users/company";
import Buyer "./model/users/buyer";
import Opera "./model/art/opera";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";

actor {
    private let null_address: Principal = Principal.fromText("aaaaa-aa");

    // '''
    // Variabili d'istanza mutable e non-stable per lavorare in maniera efficiente
    // '''
    private var tokenId: Types.TokenIdentifier.TokenIdentifier = 0;
    private var transactionId: Types.GenericTypes.TxIdentifier = 0;
    private var txs = HashMap.HashMap<Types.GenericTypes.TxIdentifier, Types.GenericTypes.TxEvent>(1, Types.GenericTypes.equal, Types.GenericTypes.hash);
    private var companies = HashMap.HashMap<Principal, Company.Company>(1, Principal.equal, Principal.hash);
    private var buyers = HashMap.HashMap<Principal, Buyer.Buyer>(1, Principal.equal, Principal.hash);
    private var nfts = HashMap.HashMap<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft>(1, Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);
    private var operas = HashMap.HashMap<Nat64, Opera.Opera>(1, Types.GenericTypes.equal, Types.GenericTypes.hash);


    private var logov : Text = "logo_masterzpw";
    private var namev : Text = "ledger_masterzpw";
    private var created_atv : Int = 1686222436;
    private var upgraded_atv = Time.now();
    private var custodiansv : [Principal] = [Principal.fromText("wtkgv-bbgya-abxqz-xv6sa-dfrsl-dxf2m-p3x7s-jl4mo-ixznr-gud6o-5ae")];
    private var symbolv : Text = "symbol_masterzpw";



    // '''
    // Variabili d'istanze mutable e stable per salvataggio/ripristino stato prima/dopo upgrade.
    // '''
    private stable var metadatav : Types.GenericTypes.Metadata = {
            logo = logov;
            name = namev;
            created_at = created_atv;
            upgraded_at = upgraded_atv;
            custodians : [Principal] = custodiansv;
            symbol : Text = symbolv;
        };

    private stable var stableTxs : [(Types.GenericTypes.TxIdentifier, Types.GenericTypes.TxEvent)] = [];
    private stable var stableCompanies : [Types.UsersTypes.StableCompany] = [];
    private stable var stableBuyers : [Types.UsersTypes.StableBuyer] = [];
    private stable var stableNfts : [(Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft)] = [];
    private stable var stableOperas : [Opera.StableOpera] = [];


    // '''
    // Metodi d'istanza get/set, add/remove
    // '''
    public shared query func logo() : async Text {
        logov;
    };

    public shared query func name() : async Text {
            namev;
    };

    public shared query func symbol() : async Text {
        symbolv;
    };

    public shared query func custodians() : async [Principal]{
        custodiansv;
    };

    public shared query func cycles() : async Nat {
        Cycles.balance();
    };

    public shared query func totalUniqueHolders() : async Nat {
        computeTotalUniqueHolders();
    };

    public shared query func totalSupply() : async Nat {
        nfts.size();
    };

    public shared query func metadata() : async Types.GenericTypes.Metadata {
        let metadata : Types.GenericTypes.Metadata = {
            logo = logov;
            name = namev;
            created_at = created_atv;
            upgraded_at = upgraded_atv;
            custodians = custodiansv;
            symbol = symbolv;
        };
    };

    public shared query func stats() : async Types.GenericTypes.Stats {
        let stats : Types.GenericTypes.Stats = {
            cycles = Cycles.balance();
            total_transactions = txs.size();
            total_unique_holders = computeTotalUniqueHolders();
            total_supply = nfts.size();
        };
    };


    public shared func setLogo(newLogo: Text) : async () {
        logov := newLogo;
    };


    public shared func setName(newName: Text) : async () {
        namev := newName;
    };


    public shared func setSymbol(newSymbol: Text) : async () {
        symbolv := newSymbol;
    };

    public shared func setCustodians(newCustodians: [Principal]) : async () {
        custodiansv := newCustodians;
    };



    // '''
    // Metodi di interfaccia standard DIP-721
    // '''
    public shared query func tokenMetadata(tokenIdentifier: Types.TokenIdentifier.TokenIdentifier) : async Types.GenericTypes.Result<Types.Nft.TokenMetadata, Types.GenericTypes.Error> {
        let token = nfts.get(tokenIdentifier);

        let res =
            switch(token) {
                case (?token) { #Ok(token.metadata); };
                case null { #Err(#TokenNotFound(true)); };
            };
    };

    public shared query func balanceOf(owner: Principal) : async Types.GenericTypes.Result<Nat, Types.GenericTypes.Error>  {
        var ownerO = companies.get(owner);

        let res =
            switch(ownerO) {
                case (?ownerO) { #Ok(ownerO.getOwnNftsSize()); };
                case null {
                    let ownerO1 = buyers.get(owner);
                    switch(ownerO1) {
                        case (?ownerO1) { #Ok(ownerO1.getOwnNftsSize()); };
                        case null { #Err(#OwnerNotFound(true)); };
                    };
                };
            };
    };

    public shared query func ownerOf(tokenId: Types.TokenIdentifier.TokenIdentifier) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error>  {
        return _ownerOf(tokenId);
    };


    public shared query func ownerTokenIdentifiers(owner : Principal) : async Types.GenericTypes.Result<[Types.TokenIdentifier.TokenIdentifier], Types.GenericTypes.Error> {
        var ownerO = companies.get(owner);

        let res =
            switch(ownerO) {
                case (?ownerO) { #Ok(ownerO.getOwnNftsIds()); };
                case null {
                    let ownerO1 = buyers.get(owner);
                    switch(ownerO1) {
                        case (?ownerO1) { #Ok(ownerO1.getOwnNftsIds()); };
                        case null { #Err(#OwnerNotFound(true)); };
                    };
                };
            };
    };

    public shared query func ownerTokenMetadata(owner : Principal) : async Types.GenericTypes.Result<[Types.Nft.TokenMetadata], Types.GenericTypes.Error>  {
        var ownerO = companies.get(owner);

        let res =
            switch(ownerO) {
                case (?ownerO) { #Ok(ownerO.getOwnNftsMetadata()); };
                case null {
                    let ownerO1 = buyers.get(owner);
                    switch(ownerO1) {
                        case (?ownerO1) { #Ok(ownerO1.getOwnNftsMetadata()); };
                        case null { #Err(#OwnerNotFound(true)); };
                    };
                };
            };
    };

    public shared query func supportedInterfaces() : async [Types.GenericTypes.SupportedInterface] {
        let interfaces = [#Mint, #TransactionHistory, #Transfer];
    };

    public shared func transferFrom(from: Principal, to : Principal, tokenId : Types.TokenIdentifier.TokenIdentifier) : async Types.GenericTypes.Result<Types.GenericTypes.TxIdentifier, Types.GenericTypes.Error> {
        let res = _ownerOf(tokenId);

        let ownerPri =
            switch res {
                case (#Ok(ownerRet)) ownerRet;
                case (#Err(#OwnerNotFound(true))) { return #Err(#OwnerNotFound(true)); };
                case (#Err(_)) { return #Err(#Other("Something went wrong"))};
            };

        if (ownerPri != from) {
            return #Err(#UnauthorizedOwner(true));
        };

        if (ownerPri == to) {
            return #Err(#SelfTransfer(true));
        };

        let token = nfts.get(tokenId);
        let newToken : Types.Nft.Nft =
            switch (token) {
                case null { return #Err(#TokenNotFound(true))};
                case (?token) { {
                    tokenId = tokenId;
                    owner = to;
                    metadata = {
                        transferredAt = ?Time.now();
                        transferredBy = null;
                        owner = to;
                        operator = null;
                        properties = token.metadata.properties;
                        isBurned = false;
                        tokenIdentifier = tokenId;
                        burnedAt = token.metadata.burnedAt;
                        burnedBy = token.metadata.burnedBy;
                        approvedAt = token.metadata.approvedAt;
                        approvedBy = token.metadata.burnedBy;
                        mintedAt = token.metadata.mintedAt;
                        mintedBy = token.metadata.mintedBy;
                    };
                }
                };
            };

        ignore nfts.replace(tokenId, newToken);
        let company = companies.get(from);
        switch (company) {
            case null { return #Err(#TokenNotFound(true)); };
            case (?company) {
                company.deletNftFromOwnById(tokenId);
                company.addNftToOwn(newToken);
            };
        };


        let buyer = buyers.get(to);
        switch (buyer) {
            case null { return #Err(#OwnerNotFound(true))};
            case (?buyer) { buyer.addNftToOwn(newToken); };
        };


        transactionId += 1;
        return #Ok(transactionId)

    };

    public shared func mint(owner : Principal, properties: Types.GenericTypes.Vec) : async Types.GenericTypes.Result<Types.GenericTypes.TxIdentifier, Types.GenericTypes.Error> {
        let res = _mint(owner, properties);

        let ret =
            switch res {
                case (#Ok(tokenId)) {
                    #Ok(transactionId); };
                case (#Err(_)) { #Err(#ExistedNFT(true)) };
            };
    };

    public shared query func transaction(txId : Types.GenericTypes.TxIdentifier) : async Types.GenericTypes.Result<Types.GenericTypes.TxEvent, Types.GenericTypes.Error> {
        let tx = txs.get(txId);

        let res =
            switch (tx) {
                case (?tx) { #Ok(tx); };
                case null { #Err(#TxNotFound(true)); };
            }
    };


    public shared query func totalTransaction() : async Nat {
        txs.size();
    };



    public shared func createNewOpera(owner : Principal, operaName : Text, opDescription: Text, picUri : Text, opPrice:  Float, quantity : Int) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
        Debug.print("createNewOpera START");

        let company = companies.get(owner);
        Debug.print("createNewOpera " # debug_show(companies.size()));

        switch (company) {
            case (?company) {
                Debug.print("createNewOpera COMPANY EXISTS");

                let opera_id = Nat64.fromNat(operas.size() + 1);
                let opera = Opera.Opera(opera_id, operaName, opDescription, picUri, opPrice, []);
                let properties : Types.GenericTypes.Vec = [
                    {
                        key = "operaId";
                        value = #Nat64Content(opera.getId());
                    }, {
                        key = "operaName";
                        value = #TextContent(opera.getName());
                    }, {
                        key = "operaDescription";
                        value = #TextContent(opera.getDescription());
                    }, {
                        key = "operaUri";
                        value = #TextContent(opera.getPictureUri());
                    }, {
                        key = "operaPrice";
                        value = #FloatContent(opera.getPrice());
                    }];

                let buf = Buffer.Buffer<Types.TokenIdentifier.TokenIdentifier>(0);

                Debug.print("createCompany MINTING");
                for (i in Iter.range(1, quantity)) {
                    let result = _mint(owner, properties);
                    switch result {
                        case (#Ok(tokenId)) {
                            buf.add(tokenId);
                            Debug.print(Nat64.toText(tokenId)); };
                        case (#Err(_)) { assert(false) };
                    };
                };

                let newNfts = Buffer.toArray(buf);
                opera.setNftsIds(newNfts);

                operas.put(opera.getId(), opera);
                return #Ok(opera.getId());

                };
            case null { return #Err(#UnauthorizedOwner(true)); };
        };
    };

    public shared func createCompany(owner : Principal, username : Text, profilePictureUri : Text, bankAddress: Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        Debug.print("createCompany START");
        Debug.print("createCompany " # debug_show(owner));


        let company = companies.get(owner);
        let res =
            switch (company) {
                case null {
                    let comp = Company.Company(owner, username, profilePictureUri, bankAddress);
                    companies.put(owner, comp);                    
                    Debug.print("createCompany company added" # debug_show(companies.size()));
                    #Ok(owner);
                };
                case (?company) {  #Ok(owner); };
            };

        res;
    };

    public shared func createBuyer(owner : Principal, username : Text, profilePictureUri : Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        Debug.print("createBuyer START");
        Debug.print("createBuyer " # debug_show(owner));


        let buyer = buyers.get(owner);
        let res =
            switch (buyer) {
                case null {
                    let bu = Buyer.Buyer(owner, username, profilePictureUri);
                    buyers.put(owner, bu);                    
                    Debug.print("createCompany company added" # debug_show(buyers.size()));
                    #Ok(owner);
                };
                case (?buyer) { #Ok(owner); };
            };

        res;
    };

    public query func getCompany(owner : Principal) : async Types.GenericTypes.Result<Types.UsersTypes.StableCompany, Types.GenericTypes.Error> {
        Debug.print("getCompany START");

        let company = companies.get(owner);
        switch (company) {
            case (?company) {
                Debug.print("getCompany COMPANY FOUND");

                let stableCompany = company.serialize();
                return #Ok(stableCompany);
            };
            case null { return #Err(#Other("Company not found!")); };
        };

        // switch (buyer) {
        //     case (?buyer) {
        //         Debug.print("getCompany BUYER found");

        //         let company = companies.get(owner);
        //         switch (company) {
        //             case (?company) {
        //                 Debug.print("getCompany COMPANY FOUND");

        //                 let stableCompany = company.serialize();
        //                 return #Ok(stableCompany);
        //             };
        //             case null { return #Err(#Other("Company not found!")); };
        //         };
        //     };
        //     case null { return #Err(#UnauthorizedOwner); };
        // };
    };

    public query func getCompanies(owner : Principal, page : Nat) : async Types.GenericTypes.Result<[Types.UsersTypes.StableCompany], Types.GenericTypes.Error> {
        Debug.print("getCompany START");
        let buyer = buyers.get(owner);

        switch (buyer) {
            case (?buyer) {
                Debug.print("getCompany BUYER found");

                let buf = Buffer.Buffer<Company.Company>(0);
                var i = 0;

                for (key in companies.keys()) {
                    if (i >= page*20 and i <= page*20 + 20) {
                        let comp = companies.get(key);
                        switch comp {
                            case (?comp) { buf.add(comp) };
                            case null { Debug.print("getCompany No company"); };
                        }                         
                    };
                };

                let stableCompanies = Company.serializeCompanies(buf.vals());

                return #Ok(stableCompanies);
            };
            case null { return #Err(#UnauthorizedOwner(true)); };
        };
    };

     public query func getAllCompanies(page : Nat) : async Types.GenericTypes.Result<[Types.UsersTypes.StableCompany], Types.GenericTypes.Error> {

        let buf = Buffer.Buffer<Company.Company>(0);
        var i = 0;

        for (key in companies.keys()) {
            if (i >= page*20 and i <= page*20 + 20) {
                let comp = companies.get(key);
                switch comp {
                    case (?comp) { buf.add(comp) };
                    case null { Debug.print("getCompany No company"); };
                }                         
            };
        };

        let stableCompanies = Company.serializeCompanies(buf.vals());

        return #Ok(stableCompanies);
    };

    public query func getBuyer(owner : Principal) : async Types.GenericTypes.Result<Types.UsersTypes.StableBuyer, Types.GenericTypes.Error> {
        Debug.print("getBuyer START");
        let buyer = buyers.get(owner);

        switch (buyer) {
            case (?buyer) {
                Debug.print("getCompany BUYER FOUND");

                let stableBuyer = buyer.serialize();
                return #Ok(stableBuyer);
            };
            case null { return #Err(#Other("Company not found!")); };
        };

        // switch (buyer) {
        //     case (?buyer) {
        //         Debug.print("getCompany BUYER found");

        //         let company = companies.get(owner);
        //         switch (company) {
        //             case (?company) {
        //                 Debug.print("getCompany COMPANY FOUND");

        //                 let stableCompany = company.serialize();
        //                 return #Ok(stableCompany);
        //             };
        //             case null { return #Err(#Other("Company not found!")); };
        //         };
        //     };
        //     case null { return #Err(#UnauthorizedOwner(true)); };
        // };
    };

    public func login(owner : Principal): async Types.GenericTypes.Result<Types.GenericTypes.User<Types.UsersTypes.StableBuyer, Types.UsersTypes.StableCompany>, Types.GenericTypes.Error> {
        let buyer = buyers.get(owner);

        switch (buyer) {
            case (?buyer) {
                Debug.print("buyer log in");

                let stableBuyer = buyer.serialize();
                return #Ok(#Buyer(stableBuyer));
            };
            case null { 
                let company = companies.get(owner);
                switch (company) {
                    case (?company) {
                        Debug.print("company login");

                        let stableCompany = company.serialize();
                        return #Ok(#Company(stableCompany));
                    };
                    case null { 
                        return #Err(#FirstAccess(true)); 
                    };
                };
            };
        };

    };

    // public query func getBuyers(owner : Principal) : async Types.GenericTypes.Result<Buyer.StableBuyer, Types.GenericTypes.Error> {
    //     Debug.print("getBuyers START");
    //     let company = companies.get(owner);

    //     switch (company) {
    //         case (?company) {
    //             Debug.print("getCompany BUYER found");

    //             let company = companies.get(owner);
    //             switch (company) {
    //                 case (?company) {
    //                     Debug.print("getCompany COMPANY FOUND");

    //                     let stableCompany = company.serialize();
    //                     return #Ok(stableCompany);
    //                 };
    //                 case null { return #Err(#Other("Company not found!")); };
    //             };
    //         };
    //         case null { return #Err(#UnauthorizedOwner); };
    //     };
    // };


    private func _mint(owner : Principal, properties: Types.GenericTypes.Vec) : Types.GenericTypes.Result<Types.TokenIdentifier.TokenIdentifier, Types.GenericTypes.Error> {
        Debug.print("_mint START");
        let company = companies.get(owner);

        switch (company) {
            case (?company) {
                let nft = nfts.get(tokenId);
                Debug.print(debug_show(nft));

                switch (nft) {
                    case (?nft) { return #Err(#ExistedNFT(true)); };
                    case (null) {
                        var newNft : Types.Nft.Nft = {
                            tokenId = tokenId;
                            owner = owner;
                            metadata = {
                                transferredAt = null;
                                transferredBy = null;
                                owner = owner;
                                operator = null;
                                properties = properties;
                                isBurned = false;
                                tokenIdentifier = tokenId;
                                burnedAt = null;
                                burnedBy = null;
                                approvedAt = null;
                                approvedBy = null;
                                mintedAt = Time.now();
                                mintedBy = custodiansv[0];
                            };
                        };

                        nfts.put(tokenId, newNft);
                        Debug.print("_mint NFT added to nfts");

                        company.addNftToOwn(newNft);
                        Debug.print("_mint NFT added to company");


                        tokenId += 1;
                        transactionId += 1;
                        return #Ok(tokenId);
                    };
                };
            };
            case null { 
                Debug.print("_mint NFT no company");
                #Err(#UnauthorizedOwner(true));
            };
        };
    };

    // private func _transferTo(to: Principal, tokenId: Types.TokenIdentifier.TokenIdentifier) : Types.GenericTypes.Result<Types.GenericTypes.TxIdentifier, Types.GenericTypes.Error> {
    //     let res = _ownerOf(tokenId);

    //     let ownerPri =
    //         switch res {
    //             case (#Ok(ownerRet)) ownerRet;
    //             case (#Err(#OwnerNotFound)) { return #Err(#OwnerNotFound); };
    //             case (#Err(_)) { return #Err(#Other("Something went wrong"))};
    //         };


    //     if (ownerPri == null_address) {
    //         return #Err(#SelfTransfer);
    //     };

    //     let token = nfts.get(tokenId);
    //     let newToken : Types.Nft.Nft =
    //         switch (token) {
    //             case null { return #Err(#TokenNotFound)};
    //             case (?token) { {
    //                 tokenId = tokenId;
    //                 owner = to;
    //                 metadata = {
    //                     transferredAt = ?Time.now();
    //                     transferredBy = null;
    //                     owner = to;
    //                     operator = null;
    //                     properties = token.metadata.properties;
    //                     isBurned = false;
    //                     tokenIdentifier = tokenId;
    //                     burnedAt = token.metadata.burnedAt;
    //                     burnedBy = token.metadata.burnedBy;
    //                     approvedAt = token.metadata.approvedAt;
    //                     approvedBy = token.metadata.burnedBy;
    //                     mintedAt = token.metadata.mintedAt;
    //                     mintedBy = token.metadata.mintedBy;
    //                 };
    //             }
    //             };
    //         };

    //     ignore nfts.replace(tokenId, newToken);
    //     let company = companies.get(from);
    //     switch (company) {
    //         case null { return #Err(#TokenNotFound); };
    //         case (?company) {
    //             company.deletNftFromOwnById(tokenId);
    //             company.addNftToOwn(newToken);
    //         };
    //     };


    //     let buyer = buyers.get(to);
    //     switch (buyer) {
    //         case null { return #Err(#OwnerNotFound)};
    //         case (?buyer) { buyer.addNftToOwn(newToken); };
    //     };


    //     return #Ok()
    // };


    // '''
    // Metodi di utility
    // '''
    private func computeTotalUniqueHolders() : Nat {
        var u_holders = 0;

        for (company in companies.vals()) {
            if (company.getOwnNftsSize() != 0) { u_holders += 1; };
        };

        for (buyer in buyers.vals()) {
            if (buyer.getOwnNftsSize() == 0) { u_holders += 1; };
        };

        u_holders;
    };

    private func _ownerOf(tokenId: Types.TokenIdentifier.TokenIdentifier) : Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        let nft = nfts.get(tokenId);
        let res =
            switch(nft) {
                case (?nft) { #Ok(nft.owner); };
                case null { #Err(#TokenNotFound(true)); };
            };
    };


    // '''
    // Metodi si sistema utilizzati durante le procedure di upgrade del canister
    // pre_upgrade(): permette di manipolare/memorizzari dati a monte del processo
    //                 di upgrade del canister -> utile per passare dati
    //                 volatili alla memoria stabile del sistema.
    system func preupgrade() {
            metadatav := {
            logo = logov;
            name = namev;
            created_at = created_atv;
            upgraded_at = upgraded_atv;
            custodians : [Principal] = custodiansv;
            symbol : Text = symbolv;
        };

        stableTxs := Iter.toArray(txs.entries());
        stableCompanies := Company.serializeCompanies(companies.vals());
        stableBuyers := Buyer.serializeBuyers(buyers.vals());
        stableNfts := Iter.toArray(nfts.entries());
        stableOperas := Opera.serializeOperas(operas.vals())

    };


    // post_upgrade(): invocata ad upgrade completato -> utile per ripristinare i valori
    //                  volatili dalla memoria stabile.
    //
    // Altro approccio potrebbe essere: quando faccio upgrade vado semplicemente a resettare a mappe buote
    // tutte le collezioni cosi' mantengo meno duplicati. Poi pero' bisogna lavorare sempre sulle copie stable per tutto
    // (potrebbe essere meno efficiente).
    // '''
    system func postupgrade() {
        logov := metadatav.logo;
        namev := metadatav.name;
        created_atv := metadatav.created_at;
        upgraded_atv := Time.now();
        custodiansv := metadatav.custodians;

        txs := HashMap.fromIter<Types.GenericTypes.TxIdentifier, Types.GenericTypes.TxEvent>(stableTxs.vals(), stableTxs.size(), Types.GenericTypes.equal, Types.GenericTypes.hash);
        companies := Company.deserializeCompaniesToMap(stableCompanies);
        buyers := Buyer.deserializeBuyersToMap(stableBuyers);
        nfts := HashMap.fromIter<Types.TokenIdentifier.TokenIdentifier, Types.Nft.Nft>(stableNfts.vals(), stableNfts.size(), Types.TokenIdentifier.equal, Types.TokenIdentifier.hash);
        operas := Opera.deserializeOperasToMap(stableOperas);

        tokenId := Nat64.fromNat(stableNfts.size());
        transactionId := Nat64.fromNat(stableTxs.size());
    };
};
