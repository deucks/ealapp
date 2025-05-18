/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_139664264")

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "json3169615425",
    "maxSize": 0,
    "name": "conversationHistory",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "json1932473548",
    "maxSize": 0,
    "name": "lastMlOutput",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_139664264")

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "json3169615425",
    "maxSize": 0,
    "name": "conversation_history",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "json1932473548",
    "maxSize": 0,
    "name": "last_ml_output",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
})
