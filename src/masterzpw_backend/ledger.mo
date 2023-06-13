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
import Nft "./model/art/nft";
import Opera "./model/art/opera";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";

shared actor class Ledger() = Self {
    private let null_address: Principal = Principal.fromText("aaaaa-aa");

    // '''
    // Variabili d'istanza mutable e non-stable per lavorare in maniera efficiente
    // '''
    private var tokenId: Nft.TokenIdentifier.TokenIdentifier = 0;
    private var transactionId: Types.TxIdentifier = 0;
    private var txs = HashMap.HashMap<Types.TxIdentifier, Types.TxEvent>(0, Types.equal, Types.hash);
    private var companies = HashMap.HashMap<Principal, Company.Company>(0, Principal.equal, Principal.hash);
    private var buyers = HashMap.HashMap<Principal, Buyer.Buyer>(0, Principal.equal, Principal.hash);
    private var nfts = HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(0, Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
    private var operas = HashMap.HashMap<Nat64, Opera.Opera>(0, Types.equal, Types.hash);


    private var logov : Text = "logo_masterzpw";
    private var namev : Text = "ledger_masterzpw";
    private var created_atv : Int = 1686222436;
    private var upgraded_atv = Time.now();
    private var custodiansv : [Principal] = [Principal.fromText("wtkgv-bbgya-abxqz-xv6sa-dfrsl-dxf2m-p3x7s-jl4mo-ixznr-gud6o-5ae")];
    private var symbolv : Text = "symbol_masterzpw";



    // '''
    // Variabili d'istanze mutable e stable per salvataggio/ripristino stato prima/dopo upgrade.
    // '''
    private stable var metadatav : Types.Metadata = {
            logo = logov;
            name = namev;
            created_at = created_atv;
            upgraded_at = upgraded_atv;
            custodians : [Principal] = custodiansv;
            symbol : Text = symbolv;
        };

    private stable var stableTxs : [(Types.TxIdentifier, Types.TxEvent)] = [];
    private stable var stableCompanies : [Company.StableCompany] = [];
    private stable var stableBuyers : [Buyer.StableBuyer] = [];
    private stable var stableNfts : [(Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft)] = [];
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

    public shared query func metadata() : async Types.Metadata {
        let metadata : Types.Metadata = {
            logo = logov;
            name = namev;
            created_at = created_atv;
            upgraded_at = upgraded_atv;
            custodians = custodiansv;
            symbol = symbolv;
        };
    };

    public shared query func stats() : async Types.Stats {
        let stats : Types.Stats = {
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
    public shared query func tokenMetadata(tokenIdentifier: Nft.TokenIdentifier.TokenIdentifier) : async Types.Result<Nft.Nft.TokenMetadata, Types.NftError> {
        let token = nfts.get(tokenIdentifier);

        let res =
            switch(token) {
                case (?token) { #Ok(token.metadata); };
                case null { #Err(#TokenNotFound); };
            };
    };

    public shared query func balanceOf(owner: Principal) : async Types.Result<Nat, Types.NftError>  {
        var ownerO = companies.get(owner);

        let res = 
            switch(ownerO) {
                case (?ownerO) { #Ok(ownerO.getOwnNftsSize()); };
                case null { 
                    let ownerO1 = buyers.get(owner);
                    switch(ownerO1) {
                        case (?ownerO1) { #Ok(ownerO1.getOwnNftsSize()); };
                        case null { #Err(#OwnerNotFound); };
                    };
                };
            };     
    };

    public shared query func ownerOf(tokenId: Nft.TokenIdentifier.TokenIdentifier) : async Types.Result<Principal, Types.NftError>  {
        return _ownerOf(tokenId);
    };


    public shared query func ownerTokenIdentifiers(owner : Principal) : async Types.Result<[Nft.TokenIdentifier.TokenIdentifier], Types.NftError> { 
        var ownerO = companies.get(owner);

        let res = 
            switch(ownerO) {
                case (?ownerO) { #Ok(ownerO.getOwnNftsIds()); };
                case null { 
                    let ownerO1 = buyers.get(owner);
                    switch(ownerO1) {
                        case (?ownerO1) { #Ok(ownerO1.getOwnNftsIds()); };
                        case null { #Err(#OwnerNotFound); };
                    };
                };
            };            
    };

    public shared query func ownerTokenMetadata(owner : Principal) : async Types.Result<[Nft.Nft.TokenMetadata], Types.NftError>  {
        var ownerO = companies.get(owner);

        let res = 
            switch(ownerO) {
                case (?ownerO) { #Ok(ownerO.getOwnNftsMetadata()); };
                case null { 
                    let ownerO1 = buyers.get(owner);
                    switch(ownerO1) {
                        case (?ownerO1) { #Ok(ownerO1.getOwnNftsMetadata()); };
                        case null { #Err(#OwnerNotFound); };
                    };
                };
            };      
    };

    public shared query func supportedInterfaces() : async [Types.SupportedInterface] {
        let interfaces = [#Mint, #TransactionHistory, #Transfer];
    };

    public shared func transferFrom(from: Principal, to : Principal, tokenId : Nft.TokenIdentifier.TokenIdentifier) : async Types.Result<Types.TxIdentifier, Types.NftError> {
        let res = _ownerOf(tokenId);

        let ownerPri =
            switch res {
                case (#Ok(ownerRet)) ownerRet;
                case (#Err(#OwnerNotFound)) { return #Err(#OwnerNotFound); };
                case (#Err(_)) { return #Err(#Other("Something went wrong"))};
            };

        if (ownerPri != from) {
            return #Err(#UnauthorizedOwner);
        };

        if (ownerPri == to) {
            return #Err(#SelfTransfer);
        };

        let token = nfts.get(tokenId);
        let newToken : Nft.Nft.Nft = 
            switch (token) { 
                case null { return #Err(#TokenNotFound)};
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
            case null { return #Err(#TokenNotFound); };
            case (?company) { 
                company.deletNftFromOwnById(tokenId);
                company.addNftToOwn(newToken);
            };
        };
        

        let buyer = buyers.get(to);
        switch (buyer) { 
            case null { return #Err(#OwnerNotFound)};
            case (?buyer) { buyer.addNftToOwn(newToken); };
        };
        

        transactionId += 1;
        return #Ok(transactionId)

    };

    public shared func mint(owner : Principal, properties: Types.Vec) : async Types.Result<Types.TxIdentifier, Types.NftError> {
        let res = _mint(owner, properties);
        
        let ret =
            switch res {
                case (#Ok(tokenId)) {
                    #Ok(transactionId); };
                case (#Err(_)) { #Err(#ExistedNFT) };
            };
    };

    public shared query func transaction(txId : Types.TxIdentifier) : async Types.Result<Types.TxEvent, Types.NftError> {
        let tx = txs.get(txId);

        let res = 
            switch (tx) {
                case (?tx) { #Ok(tx); };
                case null { #Err(#TxNotFound); };
            }
    };


    public shared query func totalTransaction() : async Nat {
        txs.size();
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

        txs := HashMap.fromIter<Types.TxIdentifier, Types.TxEvent>(stableTxs.vals(), stableTxs.size(), Types.equal, Types.hash);
        companies := Company.deserializeCompaniesToMap(stableCompanies);
        buyers := Buyer.deserializeBuyersToMap(stableBuyers);
        nfts := HashMap.fromIter<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>(stableNfts.vals(), stableNfts.size(), Nft.TokenIdentifier.equal, Nft.TokenIdentifier.hash);
        operas := Opera.deserializeOperasToMap(stableOperas);

        tokenId := Nat64.fromNat(stableNfts.size());
        transactionId := Nat64.fromNat(stableTxs.size());
    };


    // '''
    // Metodi di utility
    // '''

    public shared query func createNewOpera(owner : Principal, operaName : Text, opDescription: Text, picUri : Text, opPrice:  Float, quantity : Int) : async Types.Result<Nat64, Types.NftError> {
        Debug.print("createNewOpera START");
        
        let company = companies.get(owner);
        let res = 
            switch (company) {
                case (?company) { 
                    Debug.print("createNewOpera COMPANY EXISTS");

                    let opera_id = Nat64.fromNat(operas.size() + 1);
                    let opera = Opera.Opera(opera_id, operaName, opDescription, picUri, opPrice, []);
                    let properties : Types.Vec = [
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

                    let buf = Buffer.Buffer<Nft.TokenIdentifier.TokenIdentifier>(0);

                    Debug.print("createCompany MINTING");
                    for (i in Iter.range(1, quantity)) {
                        let result = _mint(custodiansv[0], properties);
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
                    #Ok(opera.getId());

                 };
                case null { #Err(#UnauthorizedOwner); };
            };

        res;        
    };

    public shared query func createCompany(owner : Principal, username : Text, profilePictureUri : Text, bankAddress: Text) : async Types.Result<Principal, Types.NftError> {
        Debug.print("createCompany START");
        
        let company = companies.get(owner);
        let res = 
            switch (company) {
                case (?company) { 
                    let comp = Company.Company(owner, username, profilePictureUri, bankAddress);
                    companies.put(owner, comp);
                    Debug.print("createCompany company added");
                    #Ok(owner);                  
                };
                case null { #Err(#UnauthorizedOwner); };
            };

        res;        
    };

    private func _mint(owner : Principal, properties: Types.Vec) : Types.Result<Nft.TokenIdentifier.TokenIdentifier, Types.NftError> {
        Debug.print("_mint START");
        
        let company = companies.get(owner);

        let res = 
            switch (company) {
                case (?company) { 
                    let nft = nfts.get(tokenId);
        
                    switch (nft) {
                        case (?nft) { return #Err(#ExistedNFT); };
                        case (null) { 
                            var newNft : Nft.Nft.Nft = {
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
                case null { #Err(#UnauthorizedOwner); };
            };
    };

    // private func _transferTo(to: Principal, tokenId: Nft.TokenIdentifier.TokenIdentifier) : Types.Result<Types.TxIdentifier, Types.NftError> {
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
    //     let newToken : Nft.Nft.Nft = 
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

    private func _ownerOf(tokenId: Nft.TokenIdentifier.TokenIdentifier) : Types.Result<Principal, Types.NftError> {
        let nft = nfts.get(tokenId);
        let res = 
            switch(nft) {
                case (?nft) { #Ok(nft.owner); };
                case null { #Err(#TokenNotFound); };
            };
    }
};
