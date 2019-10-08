# require 'rest-client'
# require 'json'

API_KEY = '89843c662df3cfa55288578854faf74c4e2908d8da7c3bf0cf0d8d5f05ef7256'
ORG_ID = '5b51fc635796961117434bf0'

class NamaraNiqlRequests

  def initialize(api_key, organization_id)
    @api_key = api_key
    @organization_id = organization_id
  end

  def query(statement)
    RestClient::Request.execute(
      method: :post,
      url: 'https://api.namara.io/v0/query.json',
      content_type: :json,
      headers: {'X-API-Key' => @api_key},
      payload: {
        query: statement,
        organization_id: @organization_id
      }
    )
  end
end
