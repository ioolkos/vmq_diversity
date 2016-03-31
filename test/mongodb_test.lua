assert(mongodb.delete("mongodb_test", "users", {}))

doc1 = {_id = 'test-id',
       first_name = 'Jules',
       last_name = 'Verne',
       protocol = 'MQTT',
       broker = 'VerneMQ'}

doc2 = {first_name = 'John',
       last_name = 'Doe',
       protocol = 'MQTT',
       broker = 'Mosquitto'}

-- insert one document
ret = mongodb.insert("mongodb_test", "users", doc1)
assert(#ret == 1)

-- insert multiple documents
assert(mongodb.delete("mongodb_test", "users", {}))
ret = mongodb.insert("mongodb_test", "users", {doc1, doc2})
assert(#ret == 2)
assert(ret[1]._id == 'test-id')
assert(ret[2]._id) -- assert id was set automatically

cursor = mongodb.find("mongodb_test", "users", {})
ret = mongodb.take(cursor, 5)

-- update broker for all MQTT users
assert(mongodb.update("mongodb_test", "users", {protocol = 'MQTT'}, {broker = 'VerneMQ'}))

-- find all
cursor = mongodb.find("mongodb_test", "users", {})

-- take 5, it will return 2 entries
ret = mongodb.take(cursor, 5)
assert(#ret == 2)
mongodb.close(cursor)

-- find with filter
cursor = mongodb.find("mongodb_test", "users", {first_name = 'Jules'})
ret = mongodb.next(cursor)
assert(ret.first_name == "Jules")
assert(ret.last_name == "Verne")
assert(false == mongodb.next(cursor))
mongodb.close(cursor)

-- using a projector, to hide first_name value
cursor = mongodb.find("mongodb_test", "users", {}, {projector = {first_name = false}})
ret = mongodb.next(cursor)
assert(ret['first_name'] == nil)
mongodb.close(cursor)

-- find_one
ret = mongodb.find_one("mongodb_test", "users", {first_name = 'Jules'})
assert(ret.first_name == "Jules")
assert(ret.last_name == "Verne")