##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::Postgres
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::Scanner

  def initialize
    super(
      'Name' => 'Postgres Schema Dump',
      'Description' => %(
          This module extracts the schema information from a
          Postgres server.
      ),
      'Author' => ['theLightCosine'],
      'License' => MSF_LICENSE
    )
    register_options([
      OptString.new('DATABASE', [ true, 'The database to authenticate against', 'postgres']),
      OptBool.new('DISPLAY_RESULTS', [true, 'Display the Results to the Screen', true]),
      OptString.new('IGNORED_DATABASES', [true, 'Comma separated list of databases to ignore during the schema dump', 'template1,template0'])
    ])
    deregister_options('SQL', 'RETURN_ROWSET', 'VERBOSE')
  end

  def run_host(_ip)
    pg_schema = get_schema
    pg_schema.each do |db|
      report_note(
        host: datastore['RHOST'],
        type: 'postgres.db.schema',
        data: db,
        port: datastore['RPORT'],
        proto: 'tcp',
        update: :unique_data
      )
    end
    output = "Postgres SQL Server Schema \n Host: #{datastore['RHOST']} \n Port: #{datastore['RPORT']} \n ====================\n\n"
    output << YAML.dump(pg_schema)
    this_service = report_service(
      host: datastore['RHOST'],
      port: datastore['RPORT'],
      name: 'postgres',
      proto: 'tcp'
    )
    store_loot('postgres_schema', 'text/plain', datastore['RHOST'], output, "#{datastore['RHOST']}_postgres_schema.txt", 'Postgres SQL Schema', this_service)
    print_good output if datastore['DISPLAY_RESULTS']
  end

  def get_schema
    ignored_databases = datastore['IGNORED_DATABASES'].split(',').map(&:strip)
    pg_schema = []
    database_names = smart_query('SELECT datname FROM pg_database').to_a.flatten
    if database_names.empty?
      print_status("#{rhost}:#{rport} - No databases found")
      return pg_schema
    end
    status_message = "#{rhost}:#{rport} - Found databases: #{database_names.join(', ')}."
    excluded_databases = (database_names & ignored_databases)
    status_message += " Ignoring #{excluded_databases.join(', ')}." if excluded_databases.any?
    print_status(status_message)
    extractable_database_names = database_names - ignored_databases
    extractable_database_names.each do |database_name|
      next if ignored_databases.include? database_name
      tmp_db = {}
      tmp_db['DBName'] = database_name
      tmp_db['Tables'] = []
      postgres_login({ database: database_name })
      tmp_tblnames = smart_query("SELECT c.relname, n.nspname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname NOT IN ('pg_catalog','pg_toast') AND pg_catalog.pg_table_is_visible(c.oid);")
      if tmp_tblnames && !tmp_tblnames.empty?
        tmp_tblnames.each do |tbl_row|
          tmp_tbl = {}
          tmp_tbl['TableName'] = tbl_row[0]
          tmp_tbl['Columns'] = []
          tmp_column_names = smart_query("SELECT  A.attname, T.typname, A.attlen FROM pg_class C, pg_namespace N, pg_attribute A, pg_type T WHERE  (N.oid=C.relnamespace) AND (A.attrelid=C.oid) AND (A.atttypid=T.oid) AND (A.attnum>0) AND (NOT A.attisdropped) AND (N.nspname ILIKE 'public') AND (c.relname='#{tbl_row[0]}');")
          if tmp_column_names && !tmp_column_names.empty?
            tmp_column_names.each do |column_row|
              tmp_column = {}
              tmp_column['ColumnName'] = column_row[0]
              tmp_column['ColumnType'] = column_row[1]
              tmp_column['ColumnLength'] = column_row[2]
              tmp_tbl['Columns'] << tmp_column
            end
          end
          tmp_db['Tables'] << tmp_tbl
        end
      end
      pg_schema << tmp_db
    end

    pg_schema
  end

  def smart_query(query_string)
    res = postgres_query(query_string, false)
    # Error handling routine here, borrowed heavily from todb
    case res.keys[0]
    when :conn_error
      print_error('A Connection Error Occurred')
      return
    when :sql_error
      case res[:sql_error]
      when /^C42501/
        print_error "#{datastore['RHOST']}:#{datastore['RPORT']} Postgres - Insufficient permissions."
      else
        print_error "#{datastore['RHOST']}:#{datastore['RPORT']} Postgres - #{res[:sql_error]}"
      end
      return nil
    when :complete
      return res[:complete].rows
    end
  end

end
