import Foundation

@available(iOS 13, macOS 10.15, *)
public class DataGroup13 : DataGroup {
    
    private static let IDX_EID: UInt8 = 1
    public static let PREFIX_EID: [UInt8] = [48, 17, 2, 1, 1, 19, 12]

    public static let IDX_FULLNAME: UInt8 = 2
    public static let PREFIX_FULLNAME: [UInt8] = [48, 28, 2, 1, 2, 12, 23]

    public static let IDX_DOB: UInt8 = 3
    public static let PREFIX_DOB: [UInt8] = [48, 15, 2, 1, 3, 19, 10]

    public static let IDX_GENDER: UInt8 = 4
    public static let PREFIX_GENDER: [UInt8] = [48, 8, 2, 1, 4, 12, 3]

    public static let IDX_NATIONALITY: UInt8 = 5
    public static let PREFIX_NATIONALITY: [UInt8] = [48, 15, 2, 1, 5, 12, 10]

    public static let IDX_ETHNICITY: UInt8 = 6
    public static let PREFIX_ETHNICITY: [UInt8] = [48, 9, 2, 1, 6, 12, 4]

    public static let IDX_RELIGION: UInt8 = 7
    public static let PREFIX_RELIGION: [UInt8] = [48, 11, 2, 1, 7, 12, 6]

    public static let IDX_POG: UInt8 = 8
    public static let PREFIX_POG: [UInt8] = [48, 38, 2, 1, 8, 12, 33]

    public static let IDX_POR: UInt8 = 9
    public static let PREFIX_POR: [UInt8] = [48, 61, 2, 1, 9, 12, 56]

    public static let IDX_PERSONAL_IDENTIFICATION: UInt8 = 10
    public static let PREFIX_PERSONAL_IDENTIFICATION: [UInt8] = [48, 40, 2, 1, 10, 12, 35]

    public static let IDX_DATEOFISSUE: UInt8 = 11
    public static let PREFIX_DATEOFISSUE: [UInt8] = [48, 15, 2, 1, 11, 19, 10]

    public static let IDX_DATEOFEXPIRY: UInt8 = 12
    public static let PREFIX_DATEOFEXPIRY: [UInt8] = [48, 15, 2, 1, 12, 12, 10]

    public static let IDX_FAMILY: UInt8 = 13
    public static let PREFIX_FAMILY: [UInt8] = [48, 54, 2, 1, 13]
    public static let PREFIX_FATHERNAME: [UInt8] = [48, 25, 12, 23]
    public static let PREFIX_MOTHERNAME: [UInt8] = [48, 22, 12, 20]

    public static let IDX_SPOUSE: UInt8 = 14
    public static let PREFIX_SPOUSE: [UInt8] = [48, 3, 2, 1, 14]
    public static let PREFIX_SPOUSENAME: [UInt8] = [48, 25, 12, 23]
    
    public static let IDX_OLDEID: UInt8 = 15
    public static let PREFIX_OLDEID: [UInt8] = [48, 14, 2, 1, 15, 19, 9]
    
    public static let IDX_CARDUNK: UInt8 = 16
    public static let PREFIX_UNK: [UInt8] = [48, 21, 2, 1, 16, 19, 16]

    
    public var eidNumber: String?
    public var fullName: String?
    public var dateOfBirth: String?
    public var gender: String?
    public var nationality: String?
    public var ethnicity: String?
    public var religion: String?
    public var placeOfOrigin: String?
    public var placeOfResidence: String?
    public var personalIdentification: String?
    public var dateOfIssue: String?
    public var dateOfExpiry: String?
    public var fatherName: String?
    public var motherName: String?
    public var spouseName: String?
    public var oldEidNumber: String?
    public var unkIdNumber: String?
    public var unkInfo: [String] = []
    
    required init( _ data : [UInt8] ) throws {
        try super.init(data)
        datagroupType = .DG13
    }
    
    override func parse(_ buf: [UInt8]) throws {
        var separatorPositions: [Int] = []
        var segmentIdx = 1

        for i in 0..<(buf.count - 5) {
            let c5: [UInt8] = [buf[i], buf[i + 1], buf[i + 2], buf[i + 3], buf[i + 4]]
            
            if c5[0] == 48 && c5[2] == 2 && c5[3] == 1 && c5[4] == UInt8(segmentIdx) {
                segmentIdx += 1 // increment next segment
                
                separatorPositions.append(i)
            }
        }
        separatorPositions.append(buf.count)
        
        for i in 0..<(separatorPositions.count - 1) {
            let start = separatorPositions[i]
            let end = separatorPositions[i + 1]
            let subset = Array(buf[start..<end])
            
            // Potential empty group here
            if (subset.count < 5) {
                continue
            }
            
            switch subset[4] {
            case DataGroup13.IDX_EID:
                eidNumber = subset.count >= DataGroup13.PREFIX_EID.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_EID.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_FULLNAME:
                fullName = subset.count >= DataGroup13.PREFIX_FULLNAME.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_FULLNAME.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_DOB:
                dateOfBirth = subset.count >= DataGroup13.PREFIX_DOB.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_DOB.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_GENDER:
                gender = subset.count >= DataGroup13.PREFIX_GENDER.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_GENDER.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_NATIONALITY:
                nationality = subset.count >= DataGroup13.PREFIX_NATIONALITY.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_NATIONALITY.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_ETHNICITY:
                ethnicity = subset.count >= DataGroup13.PREFIX_ETHNICITY.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_ETHNICITY.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_RELIGION:
                religion = subset.count >= DataGroup13.PREFIX_RELIGION.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_RELIGION.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_POG:
                placeOfOrigin = subset.count >= DataGroup13.PREFIX_POG.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_POG.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_POR:
                placeOfResidence = subset.count >= DataGroup13.PREFIX_POR.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_POR.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_PERSONAL_IDENTIFICATION:
                personalIdentification = subset.count >= DataGroup13.PREFIX_PERSONAL_IDENTIFICATION.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_PERSONAL_IDENTIFICATION.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_DATEOFISSUE:
                dateOfIssue = subset.count >= DataGroup13.PREFIX_DATEOFISSUE.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_DATEOFISSUE.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_DATEOFEXPIRY:
                dateOfExpiry = subset.count >= DataGroup13.PREFIX_DATEOFEXPIRY.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_DATEOFEXPIRY.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_FAMILY:
                var seps: [Int] = []
                for j in stride(from: DataGroup13.PREFIX_FAMILY.count, through: (subset.count-2), by: 1) {
                    if subset[j] == 48 && subset[j + 2] == 12 {
                        seps.append(j)
                    }
                }
                if seps.count != 2 {
                    print("FAMILY: Bad format")
                    break
                }
                fatherName = String(decoding: subset[(seps[0] + DataGroup13.PREFIX_FATHERNAME.count)..<seps[1]], as: UTF8.self)
                motherName = String(decoding: subset[(seps[1] + DataGroup13.PREFIX_MOTHERNAME.count)..<subset.count], as: UTF8.self)
            case DataGroup13.IDX_SPOUSE:
                var seps1: [Int] = []
                for j in stride(from: DataGroup13.PREFIX_SPOUSE.count, to: (subset.count - 2), by: 1) {
                    if subset[j] == 48 && subset[j + 2] == 12 {
                        seps1.append(j)
                    }
                }
                if seps1.count < 1 {
                    print("SPOUSE: Single, no spouse")
                    break
                } else if seps1.count > 1 {
                    print("SPOUSE: More than one spouse")
                }
                spouseName = String(decoding: subset[(seps1[0] + DataGroup13.PREFIX_SPOUSENAME.count)..<subset.count], as: UTF8.self)
            case DataGroup13.IDX_OLDEID:
                oldEidNumber = subset.count >= DataGroup13.PREFIX_OLDEID.count
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_OLDEID.count), as: UTF8.self)
                : ""
            case DataGroup13.IDX_CARDUNK:
                unkIdNumber = subset.count >= DataGroup13.IDX_CARDUNK
                ? String(decoding: subset.suffix(from: DataGroup13.PREFIX_UNK.count), as: UTF8.self)
                : ""
            default:
                unkInfo.append(String(decoding: subset, as: UTF8.self))
            }
        }
    }
}
