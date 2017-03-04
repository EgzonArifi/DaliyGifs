import Foundation
import Vapor

final class DailyGifsModel: NodeRepresentable, JSONRepresentable {

    var data : [Data]!
    //var meta : Meta!
    //var pagination : Pagination!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    // NodeInitializable
       init(fromDictionary dictionary: [String:Any]){
        data = [Data]()
        if let dataArray = dictionary["data"] as? [[String:Any]]{
            for dic in dataArray{
               // let value = Data(fromDictionary: dic)
            //data.append(value)
            }
        }
        /*if let metaData = dictionary["meta"] as? [String:Any]{
            meta = Meta(fromDictionary: metaData)
        }
        if let paginationData = dictionary["pagination"] as? [String:Any]{
            pagination = Pagination(fromDictionary: paginationData)
        }*/
    }
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "data": ""
            ])
    }
    
}
