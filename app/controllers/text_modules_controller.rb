# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class TextModulesController < ApplicationController
  prepend_before_action :authentication_check

=begin

Format:
JSON

Example:
{
  "id":1,
  "name":"some text_module",
  "user_id": null,
  "keywords":"some keywords",
  "content":"some content",
  "active":true,
  "updated_at":"2012-09-14T17:51:53Z",
  "created_at":"2012-09-14T17:51:53Z",
  "updated_by_id":2.
  "created_by_id":2,
}

=end

=begin

Resource:
GET /api/v1/text_modules.json

Response:
[
  {
    "id": 1,
    "name": "some_name1",
    ...
  },
  {
    "id": 2,
    "name": "some_name2",
    ...
  }
]

Test:
curl http://localhost/api/v1/text_modules.json -v -u #{login}:#{password}

=end

  def index
    permission_check('ticket.agent')
    model_index_render(TextModule, params)
  end

=begin

Resource:
GET /api/v1/text_modules/#{id}.json

Response:
{
  "id": 1,
  "name": "name_1",
  ...
}

Test:
curl http://localhost/api/v1/text_modules/#{id}.json -v -u #{login}:#{password}

=end

  def show
    permission_check('ticket.agent')
    model_show_render(TextModule, params)
  end

=begin

Resource:
POST /api/v1/text_modules.json

Payload:
{
  "name": "some name",
  "keywords":"some keywords",
  "content":"some content",
  "active":true,
}

Response:
{
  "id": 1,
  "name": "some_name",
  ...
}

Test:
curl http://localhost/api/v1/text_modules.json -v -u #{login}:#{password} -H "Content-Type: application/json" -X POST -d '{"name": "some_name","active": true, "note": "some note"}'

=end

  def create
    permission_check('admin.text_module')
    model_create_render(TextModule, params)
  end

=begin

Resource:
PUT /api/v1/text_modules/{id}.json

Payload:
{
  "name": "some name",
  "keywords":"some keywords",
  "content":"some content",
  "active":true,
}

Response:
{
  "id": 1,
  "name": "some_name",
  ...
}

Test:
curl http://localhost/api/v1/text_modules.json -v -u #{login}:#{password} -H "Content-Type: application/json" -X PUT -d '{"name": "some_name","active": true, "note": "some note"}'

=end

  def update
    permission_check('admin.text_module')
    model_update_render(TextModule, params)
  end

=begin

Resource:
DELETE /api/v1/text_modules/{id}.json

Response:
{}

Test:
curl http://localhost/api/v1/text_modules.json -v -u #{login}:#{password} -H "Content-Type: application/json" -X DELETE

=end

  def destroy
    permission_check('admin.text_module')
    model_destroy_render(TextModule, params)
  end
end