/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_139664264")

  // add field
  collection.fields.addAt(4, new Field({
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
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_139664264")

  // remove field
  collection.fields.removeById("json1932473548")

  return app.save(collection)
})
