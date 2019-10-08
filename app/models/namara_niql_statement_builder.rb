
class NamaraNiqlStatementBuilder

  def initialize(namara_client)
    @client = namara_client
  end

  def get_key(code)
    stmt = "SELECT foreign_key FROM b6e978e8-5607-425e-b9a4-2b405e2e529f WHERE code_client = '#{code}'"
    @client.query(stmt)
  end

  def self.key(code)

    client = NamaraNiqlRequests.new(API_KEY, ORG_ID)
    statement_builder = NamaraNiqlStatementBuilder.new(client)

    response = JSON.parse(statement_builder.get_key(code))['results'][0]['foreign_key']

  end

  def get_address(code)
    stmt = "SELECT address FROM b6e978e8-5607-425e-b9a4-2b405e2e529f WHERE code_client = '#{code}'"
    @client.query(stmt)
  end

  def self.address(code)

    client = NamaraNiqlRequests.new(API_KEY, ORG_ID)
    statement_builder = NamaraNiqlStatementBuilder.new(client)

    response = JSON.parse(statement_builder.get_address(code))['results'][0]['address']

  end



end
