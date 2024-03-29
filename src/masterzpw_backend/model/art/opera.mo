import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Debug "mo:base/Debug";

import Types "../types";
import Nat "mo:base/Nat";
import Int "mo:base/Int";


module Opera {
   

    public class Opera(identifier : Nat64, operaName : Text, opDescription: Text, picUri : Text, opPrice: Int, mintedNfts : [Types.TokenIdentifier.TokenIdentifier]) {
        private var id = identifier;
        private var name = operaName;
        private var description = opDescription;
        private var pictureUri = picUri;
        private var price = opPrice;
        private var nfts = mintedNfts;

        public func getId() : Nat64 = id;
        public func getName() : Text = name;
        public func getDescription() : Text = description;
        public func getPictureUri() : Text = pictureUri;
        public func getPrice() : Int = price;
        public func getNftsIds() : [Types.TokenIdentifier.TokenIdentifier] {  nfts; };

        public func setId(newId : Nat64) : () {
            id := newId;
        };
        
        public func setName(newName : Text) : () {
            name := newName;
        };

        public func setDescription(newDescription : Text) : () {
            description := newDescription;
        };

        public func setPictureUri(newPictureUri : Text) : () {
            pictureUri := newPictureUri;
        };
        
        public func setPrice(newPrice : Int) : () {
            price := newPrice;
        };

        public func setNftsIds(newNfts : [Types.TokenIdentifier.TokenIdentifier]) : () {
            nfts := newNfts;
        };

        public func checkNftById(tokenId : Types.TokenIdentifier.TokenIdentifier) : Bool {
            for (id in nfts.vals()) {
                if (id == tokenId) {
                    return true;
                };
            };

            return false;
        };
        
        public func serialize() : Types.Opera.StableOpera {
            let op : Types.Opera.StableOpera = {
                id = id;
                name = name;
                description = description;
                pictureUri = pictureUri;
                price = price;
                nfts = nfts;
            };
        };
    };

    public func serializeOperas(operas : Iter.Iter<Opera>) : [Types.Opera.StableOpera] {
        let buf = Buffer.Buffer<Types.Opera.StableOpera>(0);

        for (opera in operas) {
            buf.add(opera.serialize());
        };

        Buffer.toArray(buf);
    };

    public func deserialize(stableOpera: Types.Opera.StableOpera) : Opera {
        Opera(stableOpera.id, stableOpera.name, stableOpera.description, stableOpera.pictureUri, stableOpera.price, stableOpera.nfts);
    };

    public func deserializeOperas(stableOperas: Iter.Iter<Types.Opera.StableOpera>) : [Opera] {
        let buf = Buffer.Buffer<Opera>(0);

        for (opera in stableOperas) {
            buf.add(deserialize(opera));
        };

        Buffer.toArray(buf);
    };

    public func deserializeOperasToMap(stableOperas: [Types.Opera.StableOpera]) : HashMap.HashMap<Nat64, Opera> {
        let operaTmp : [(Nat64, Opera)] = Array.tabulate<(Nat64, Opera)>(stableOperas.size(), func (i) { (stableOperas[i].id, deserialize(stableOperas[i])); });
        let operas = HashMap.fromIter<Nat64, Opera>(operaTmp.vals(), operaTmp.size(), Types.GenericTypes.equal, Types.GenericTypes.hash);
    };

};

