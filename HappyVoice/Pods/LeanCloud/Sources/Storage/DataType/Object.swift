//
//  Object.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/23/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud object type.

 It's a compound type used to unite other types.
 It can be extended into subclass while adding some other properties to form a new type.
 Each object is correspond to a record in data storage.
 */
@dynamicMemberLookup
open class LCObject: NSObject, LCValue, LCValueExtension, Sequence {
    public let application: LCApplication
    
    /// Access control lists.
    @objc dynamic public var ACL: LCACL?

    /// Object identifier.
    @objc dynamic public private(set) var objectId: LCString?

    @objc dynamic public private(set) var createdAt: LCDate?
    @objc dynamic public private(set) var updatedAt: LCDate?

    /**
     The table of properties.

     - note: This property table may not contains all properties, 
             because when a property did set in initializer, its setter hook will not be called in Swift.
             This property is intent for internal use.
             For accesssing all properties, please use `dictionary` property.
     */
    private var propertyTable: LCDictionary = [:]

    /// The table of all properties.
    lazy var dictionary: LCDictionary = {
        self.synchronizePropertyTable()
        return self.propertyTable
    }()

    var hasObjectId: Bool {
        return objectId != nil
    }
    
    private(set) var objectClassName: String?

    var actualClassName: String {
        if let className = (self.get("className") as? LCString)?.value {
            return className
        } else if let className = self.objectClassName {
            return className
        }
        return type(of: self).objectClassName()
    }

    /// The temp in-memory object identifier.
    var internalId = Utility.uuid()

    /// Operation hub.
    /// Used to manage update operations.
    var operationHub: OperationHub?

    /// Whether object has data to upload or not.
    public var hasDataToUpload: Bool {
        if self.hasObjectId {
            if let operationHub = self.operationHub {
                return !operationHub.isEmpty
            } else {
                return false
            }
        } else {
            return true
        }
    }

    public override required init() {
        self.application = LCApplication.default
        super.init()
        self.operationHub = OperationHub(self)
        self.propertyTable.elementDidChange = { (key, value) in
            Runtime.setInstanceVariable(self, key, value)
        }
    }
    
    public required init(application: LCApplication) {
        self.application = application
        super.init()
        self.operationHub = OperationHub(self)
        self.propertyTable.elementDidChange = { (key, value) in
            Runtime.setInstanceVariable(self, key, value)
        }
    }

    public convenience init(
        application: LCApplication = LCApplication.default,
        objectId: LCStringConvertible)
    {
        self.init(application: application)
        self.objectId = objectId.lcString
    }

    public convenience init(
        application: LCApplication = LCApplication.default,
        className: LCStringConvertible)
    {
        self.init(application: application)
        self.objectClassName = className.lcString.value
    }

    public convenience init(
        application: LCApplication = LCApplication.default,
        className: LCStringConvertible,
        objectId: LCStringConvertible)
    {
        self.init(application: application)
        self.objectClassName = className.lcString.value
        self.objectId = objectId.lcString
    }

    convenience init(application: LCApplication, dictionary: LCDictionaryConvertible) {
        self.init(application: application)
        for (key, value) in dictionary.lcDictionary {
            self.propertyTable[key] = value
        }
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let application: LCApplication
        if
            let applicationID: String = aDecoder.decodeObject(forKey: "applicationID") as? String,
            let registeredApplication: LCApplication = applicationRegistry[applicationID]
        {
            application = registeredApplication
        } else {
            application = LCApplication.default
        }
        self.init(application: application)
        self.objectClassName = aDecoder.decodeObject(forKey: "objectClassName") as? String
        let dictionary: LCDictionary = (aDecoder.decodeObject(forKey: "propertyTable") as? LCDictionary) ?? [:]
        for (key, value) in dictionary {
            self.propertyTable[key] = value
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        let applicationID: String = self.application.id
        let propertyTable: LCDictionary = self.dictionary.copy() as! LCDictionary
        
        aCoder.encode(applicationID, forKey: "applicationID")
        aCoder.encode(propertyTable, forKey: "propertyTable")
        
        if let objectClassName = self.objectClassName {
            aCoder.encode(objectClassName, forKey: "objectClassName")
        }
    }

    open func copy(with zone: NSZone?) -> Any {
        return self
    }

    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCObject {
            return object === self || (hasObjectId && object.objectId == objectId)
        } else {
            return false
        }
    }

    open override func value(forKey key: String) -> Any? {
        guard let value = get(key) else {
            return super.value(forKey: key)
        }

        return value
    }

    open func makeIterator() -> DictionaryIterator<String, LCValue> {
        return dictionary.makeIterator()
    }

    open var jsonValue: Any {
        var result: [String: Any] = [:]

        if let properties = dictionary.jsonValue as? [String: Any] {
            result.merge(properties) { (lhs, rhs) in rhs }
        }

        result["__type"]    = "Object"
        result["className"] = actualClassName

        return result
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        let dictionary = LCDictionary(self.dictionary)

        dictionary["__type"] = "Object".lcString
        dictionary["className"] = actualClassName.lcString

        return dictionary.formattedJSONString(indentLevel: indentLevel, numberOfSpacesForOneIndentLevel: numberOfSpacesForOneIndentLevel)
    }

    open var jsonString: String {
        return formattedJSONString(indentLevel: 0)
    }

    public var rawValue: LCValueConvertible {
        return self
    }

    var lconValue: Any? {
        guard let objectId = objectId else {
            return nil
        }

        return [
            "__type"    : "Pointer",
            "className" : actualClassName,
            "objectId"  : objectId.value
        ]
    }

    /**
     Get preferred batch request.

     If returns nil, it will use the default batch request.
     */
    func preferredBatchRequest(method: HTTPClient.Method, path: String, internalId: String) throws -> [String: Any]? {
        return nil
    }
    
    static func instance(application: LCApplication) -> LCValue {
        return self.init(application: application)
    }

    func forEachChild(_ body: (_ child: LCValue) throws -> Void) rethrows {
        try dictionary.forEachChild(body)
    }

    func add(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be added.")
    }

    func concatenate(_ other: LCValue, unique: Bool) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be concatenated.")
    }

    func differ(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be differed.")
    }

    /**
     Set class name of current type.

     The default implementation returns the class name without root module.

     - returns: The class name of current type.
     */
    open class func objectClassName() -> String {
        let className = String(validatingUTF8: class_getName(self))!

        /* Strip root namespace to cope with application package name's change. */
        if let index = className.firstIndex(of: ".") {
            let startIndex: String.Index = className.index(after: index)
            return String(className[startIndex...])
        } else {
            return className
        }
    }

    /**
     Register current object class manually.
     */
    public static func register() {
        ObjectProfiler.shared.registerClass(self)
    }

    /**
     Load a property for key.

     If the property value for key is already existed and type is mismatched, it will throw an exception.

     - parameter key: The key to load.

     - returns: The property value.
     */
    func getProperty<Value: LCValue>(_ key: String) throws -> Value? {
        let value = propertyTable[key]

        if let value = value {
            guard value is Value else {
                let reason = String(format: "Failed to get property for name \"%@\" with type \"%s\".", key, class_getName(Value.self))
                throw LCError(code: .invalidType, reason: reason)
            }
        }

        return value as? Value
    }

    /**
     Load a property for key.

     If the property value for key is not existed, it will initialize the property.
     If the property value for key is already existed and type is mismatched, it will throw an exception.

     - parameter key: The key to load.

     - returns: The property value.
     */
    func loadProperty<Value: LCValue>(_ key: String) throws -> Value {
        if let value: Value = try getProperty(key) {
            return value
        }

        guard
            let type = Value.self as? LCValueExtension.Type,
            let value = type.instance(application: self.application) as? Value
        else {
            let reason = String(format: "Failed to load property for name \"%@\" with type \"%s\".", key, class_getName(Value.self))
            throw LCError(code: .invalidType, reason: reason)
        }

        propertyTable[key] = value

        return value
    }

    /**
     Update property with operation.

     - parameter operation: The operation used to update property.
     */
    func updateProperty(_ operation: Operation) throws {
        let key   = operation.key
        let name  = operation.name
        let value = operation.value

        willChangeValue(forKey: key)

        switch name {
        case .set:
            propertyTable[key] = value
        case .delete:
            propertyTable[key] = nil
        case .increment:
            guard let number = value as? LCNumber else {
                throw LCError(code: .invalidType, reason: "Failed to increase property.")
            }

            let amount = number.value
            let property: LCNumber = try loadProperty(key)

            property.addInPlace(amount)
        case .add:
            guard let array = value as? LCArray else {
                throw LCError(code: .invalidType, reason: "Failed to add objects to property.")
            }

            let elements = array.value
            let property: LCArray = try loadProperty(key)

            property.concatenateInPlace(elements, unique: false)
        case .addUnique:
            guard let array = value as? LCArray else {
                throw LCError(code: .invalidType, reason: "Failed to add objects to property by unique.")
            }

            let elements = array.value
            let property: LCArray = try loadProperty(key)

            property.concatenateInPlace(elements, unique: true)
        case .remove:
            guard let array = value as? LCArray else {
                throw LCError(code: .invalidType, reason: "Failed to remove objects from property.")
            }

            let elements = array.value
            let property: LCArray? = try getProperty(key)

            property?.differInPlace(elements)
        case .addRelation:
            guard
                let array = value as? LCArray,
                let elements = array.value as? [LCRelation.Element]
            else {
                throw LCError(code: .invalidType, reason: "Failed to add relations to property.")
            }

            let relation = try loadProperty(key) as LCRelation

            try relation.appendElements(elements)
        case .removeRelation:
            guard
                let array = value as? LCArray,
                let elements = array.value as? [LCRelation.Element]
            else {
                throw LCError(code: .invalidType, reason: "Failed to remove relations from property.")
            }

            let relation: LCRelation? = try getProperty(key)

            relation?.removeElements(elements)
        }

        didChangeValue(forKey: key)
    }

    /**
     Synchronize property table.

     This method will synchronize nonnull instance variables into property table.

     Q: Why we need this method?

     A: When a property is set through dot syntax in initializer, its corresponding setter hook will not be called,
        it will result in that some properties will not be added into property table.
     */
    func synchronizePropertyTable() {
        ObjectProfiler.shared.iterateProperties(self) { (key, _) in
            guard
                let ivarValue: LCValue = Runtime.instanceVariableValue(self, key) as? LCValue,
                ivarValue !== propertyTable[key]
                else
            {
                return
            }
            propertyTable[key] = ivarValue
        }
    }

    /**
     Add an operation.

     - parameter name:  The operation name.
     - parameter key:   The operation key.
     - parameter value: The operation value.
     */
    func addOperation(_ name: Operation.Name, _ key: String, _ value: LCValue? = nil) throws {
        let operation = try Operation(name: name, key: key, value: value)

        try updateProperty(operation)
        try operationHub?.reduce(operation)
    }

    /**
     Transform value for key.

     - parameter key:   The key for which the value should be transformed.
     - parameter value: The value to be transformed.

     - returns: The transformed value for key.
     */
    func transformValue(_ key: String, _ value: LCValue?) -> LCValue? {
        guard let value = value else {
            return nil
        }

        switch key {
        case "ACL":
            return LCACL(jsonValue: value.jsonValue)
        case "createdAt", "updatedAt":
            return LCDate(jsonValue: value.jsonValue)
        default:
            return value
        }
    }

    /**
     Update a property.

     - parameter key:   The property key to be updated.
     - parameter value: The property value.
     */
    func update(_ key: String, _ value: LCValue?) {
        willChangeValue(forKey: key)
        propertyTable[key] = transformValue(key, value)
        didChangeValue(forKey: key)
    }

    /**
     Get and set value via subscript syntax.
     */
    open subscript(key: String) -> LCValue? {
        get {
            var lcValue: LCValue? = nil
            if let value: LCValue = get(key) {
                lcValue = value
            }
            return lcValue
        }
        set {
            /*
             Currently, Swift do not support throwable subscript.
             So, the exception will be ignored.
             */
            try? set(key, lcValue: newValue)
        }
    }

    open subscript(dynamicMember key: String) -> LCValueConvertible? {
        get {
            return self[key]
        }
        set {
            self[key] = newValue?.lcValue
        }
    }

    /**
     Get value for key.

     - parameter key: The key for which to get the value.

     - returns: The value for key.
     */
    open func get(_ key: String) -> LCValue? {
        var lcValue: LCValue? = nil
        if let value: LCValue = ObjectProfiler.shared.propertyValue(self, key) {
            lcValue = value
        } else if let value: LCValue = propertyTable[key] {
            lcValue = value
        }
        return lcValue
    }

    /**
     Set value for key.

     - parameter key:   The key for which to set the value.
     - parameter value: The new value.
     */
    func set(_ key: String, lcValue value: LCValue?) throws {
        if let value = value {
            try addOperation(.set, key, value)
        } else {
            try addOperation(.delete, key)
        }
    }

    /**
     Set value for key.

     This method allows you to set a value of a Swift built-in type which confirms LCValueConvertible.

     - parameter key:   The key for which to set the value.
     - parameter value: The new value.
     */
    open func set(_ key: String, value: LCValueConvertible?) throws {
        try set(key, lcValue: value?.lcValue)
    }

    /**
     Unset value for key.

     - parameter key: The key for which to unset.
     */
    open func unset(_ key: String) throws {
        try addOperation(.delete, key, nil)
    }

    /**
     Increase a number by amount.

     - parameter key:    The key of number which you want to increase.
     - parameter amount: The amount to increase. If no amount is specified, 1 is used by default. 
     */
    open func increase(_ key: String, by: LCNumberConvertible = 1) throws {
        try addOperation(.increment, key, by.lcNumber)
    }

    /**
     Append an element into an array.

     - parameter key:     The key of array into which you want to append the element.
     - parameter element: The element to append.
     */
    open func append(_ key: String, element: LCValueConvertible) throws {
        try addOperation(.add, key, LCArray([element.lcValue]))
    }

    /**
     Append one or more elements into an array.

     - parameter key:      The key of array into which you want to append the elements.
     - parameter elements: The array of elements to append.
     */
    open func append(_ key: String, elements: LCArrayConvertible) throws {
        try addOperation(.add, key, elements.lcArray)
    }

    /**
     Append an element into an array with unique option.

     - parameter key:     The key of array into which you want to append the element.
     - parameter element: The element to append.
     - parameter unique:  Whether append element by unique or not.
                          If true, element will not be appended if it had already existed in array;
                          otherwise, element will always be appended.
     */
    open func append(_ key: String, element: LCValueConvertible, unique: Bool) throws {
        try addOperation(unique ? .addUnique : .add, key, LCArray([element.lcValue]))
    }

    /**
     Append one or more elements into an array with unique option.

     - seealso: `append(key: String, element: LCValue, unique: Bool)`

     - parameter key:      The key of array into which you want to append the element.
     - parameter elements: The array of elements to append.
     - parameter unique:   Whether append element by unique or not.
     */
    open func append(_ key: String, elements: LCArrayConvertible, unique: Bool) throws {
        try addOperation(unique ? .addUnique : .add, key, elements.lcArray)
    }

    /**
     Remove an element from an array.

     - parameter key:     The key of array from which you want to remove the element.
     - parameter element: The element to remove.
     */
    open func remove(_ key: String, element: LCValueConvertible) throws {
        try addOperation(.remove, key, LCArray([element.lcValue]))
    }

    /**
     Remove one or more elements from an array.

     - parameter key:      The key of array from which you want to remove the element.
     - parameter elements: The array of elements to remove.
     */
    open func remove(_ key: String, elements: LCArrayConvertible) throws {
        try addOperation(.remove, key, elements.lcArray)
    }

    /**
     Get relation object for key.

     - parameter key: The key where relationship based on.

     - returns: The relation for key.
     */
    open func relationForKey(_ key: String) -> LCRelation {
        return LCRelation(application: self.application, key: key, parent: self)
    }

    /**
     Insert an object into a relation.

     - parameter key:    The key of relation into which you want to insert the object.
     - parameter object: The object to insert.
     */
    open func insertRelation(_ key: String, object: LCObject) throws {
        try addOperation(.addRelation, key, LCArray([object]))
    }

    /**
     Remove an object from a relation.

     - parameter key:    The key of relation from which you want to remove the object.
     - parameter object: The object to remove.
     */
    open func removeRelation(_ key: String, object: LCObject) throws {
        try addOperation(.removeRelation, key, LCArray([object]))
    }

    /**
     Validate object before saving.

     Subclass can override this method to add custom validation logic.
     */
    func validateBeforeSaving() throws {
        /* Validate circular reference. */
    }

    /**
     Discard changes by removing all change operations.
     */
    func discardChanges() {
        operationHub?.reset()
    }

    /**
     The method which will be called when object itself did save.
     */
    func objectDidSave() {
        /* Nop */
    }
    
    private static func assertObjectsApplication(_ objects: [LCObject]) -> Bool {
        let sharedApplication = (objects.first?.application ?? LCApplication.default)
        for object in objects {
            if object.application !== sharedApplication {
                return false
            }
        }
        return true
    }

    // MARK: Save object
    
    public enum SaveOption {
        case fetchWhenSave
        case query(LCQuery)
    }

    /**
     Save a batch of objects in one request synchronously.

     - parameter objects: An array of objects to be saved.

     - returns: The result of deletion request.
     */
    public static func save(_ objects: [LCObject], options: [SaveOption] = []) -> LCBooleanResult {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return expect { fulfill in
            save(objects, options: options, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Save a batch of objects in one request asynchronously.

     - parameter objects: An array of objects to be saved.
     - parameter completion: The completion callback closure.

     - returns: The request of saving.
     */
    @discardableResult
    public static func save(_ objects: [LCObject], options: [SaveOption] = [], completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return save(objects, options: options, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    static func save(_ objects: [LCObject], options: [SaveOption], completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        var parameters: [String: Any] = [:]
        for option in options {
            switch option {
            case .fetchWhenSave:
                parameters["fetchWhenSave"] = true
            case .query(let query):
                if let whereDictionary: Any = query.lconValue["where"] {
                    parameters["where"] = whereDictionary
                }
            }
        }
        return ObjectUpdater.save(objects, parameters: (parameters.isEmpty ? nil : parameters), completionInBackground: completion)
    }

    /**
     Save object and its all descendant objects synchronously.

     - returns: The result of saving request.
     */
    public func save(options: [SaveOption] = []) -> LCBooleanResult {
        return type(of: self).save([self], options: options)
    }

    /**
     Save object and its all descendant objects asynchronously.

     - parameter completion: The completion callback closure.

     - returns: The request of saving.
     */
    @discardableResult
    public func save(options: [SaveOption] = [], completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return type(of: self).save([self], options: options, completion: completion)
    }

    // MARK: Delete object

    /**
     Delete a batch of objects in one request synchronously.

     - parameter objects: An array of objects to be deleted.

     - returns: The result of deletion request.
     */
    public static func delete(_ objects: [LCObject]) -> LCBooleanResult {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return expect { fulfill in
            delete(objects, completionInBackground: fulfill)
        }
    }

    /**
     Delete a batch of objects in one request asynchronously.

     - parameter objects: An array of objects to be deleted.
     - parameter completion: The completion callback closure.

     - returns: The request of deletion.
     */
    @discardableResult
    public static func delete(_ objects: [LCObject], completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return delete(objects, completionInBackground: { result in mainQueueAsync { completion(result) } } )
    }

    @discardableResult
    private static func delete(_ objects: [LCObject], completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return ObjectUpdater.delete(objects, completionInBackground: completion)
    }

    /**
     Delete current object synchronously.

     - returns: The result of deletion request.
     */
    public func delete() -> LCBooleanResult {
        return type(of: self).delete([self])
    }

    /**
     Delete current object asynchronously.

     - parameter completion: The completion callback closure.

     - returns: The request of deletion.
     */
    @discardableResult
    public func delete(_ completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return type(of: self).delete([self], completion: completion)
    }

    // MARK: Fetch object

    /**
     Fetch a batch of objects in one request synchronously.

     - parameter objects: An array of objects to be fetched.

     - returns: The result of fetching request.
     */
    public static func fetch(_ objects: [LCObject], keys: [String]? = nil) -> LCBooleanResult {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return expect { fulfill in
            fetch(objects, keys: keys, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Fetch a batch of objects in one request asynchronously.

     - parameter completion: The completion callback closure.
     - parameter objects: An array of objects to be fetched.

     - returns: The request of fetching.
     */
    @discardableResult
    public static func fetch(_ objects: [LCObject], keys: [String]? = nil, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return fetch(objects, keys: keys, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func fetch(_ objects: [LCObject], keys: [String]?, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        assert(self.assertObjectsApplication(objects), "objects with multiple applications.")
        return ObjectUpdater.fetch(objects, keys: keys, completionInBackground: completion)
    }

    /**
     Fetch object from server synchronously.

     - returns: The result of fetching request.
     */
    public func fetch(keys: [String]? = nil) -> LCBooleanResult {
        return type(of: self).fetch([self], keys: keys)
    }

    /**
     Fetch object from server asynchronously.

     - parameter completion: The completion callback closure.
     */
    @discardableResult
    public func fetch(keys: [String]? = nil, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return type(of: self).fetch([self], keys: keys, completion: completion)
    }
}
