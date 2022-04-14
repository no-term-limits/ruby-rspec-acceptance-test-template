# frozen_string_literal: true

module MysqlDbHelper
  class MysqlDb
    attr_reader :host, :dbschema, :username, :password, :database

    Sequel.default_timezone = :utc

    def initialize(host, username, password, dbschema)
      @host = host
      @username = username
      @password = password
      @dbschema = dbschema
      @database = mysqldb_connect(host, username, password, dbschema)
    end

    # NOTE: *_record methods will operate with single table records:
    def select_record(table, query_hash)
      record = database[table.to_sym].first(query_hash)
      database.disconnect
      record
    rescue Sequel::Error => e
      e.message
    end

    def insert_record(table, data_hash)
      database[table.to_sym].insert(data_hash)
      record = select_record(table, data_hash)
      database.disconnect
      record
    rescue Sequel::Error => e
      e.message
    end

    def update_record(table, query_hash, data_hash)
      database_table = database[table.to_sym]
      database_table.where(database_table.first(query_hash)).update(data_hash)
      record = select_record(table, query_hash)
      database.disconnect
      record
    rescue Sequel::Error => e
      e.message
    end

    def delete_record(table, query_hash)
      database_table = database[table.to_sym]
      database_table.where(database_table.first(query_hash)).delete
      record = select_record(table, query_hash)
      database.disconnect
      record
    rescue Sequel::Error => e
      e.message
    end

    # NOTE: use this method to operate with multiple table records or complex sql queries.
    def query_records(sql_statement)
      records = database.fetch(sql_statement).all
      database.disconnect
      records
    rescue Sequel::Error => e
      e.message
    end

    alias execute_sql query_records

    private

    def mysqldb_connect(host, username, password, dbschema)
      Sequel.connect(adapter: 'mysql2', host: host, username: username, password: password, database: dbschema)
    end
  end
end
