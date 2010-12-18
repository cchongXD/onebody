require 'active_support/string_inquirer'

begin
  case Site.connection.adapter_name
  when 'PostgreSQL'
    DB_ADAPTER = ActiveSupport::StringInquirer.new('postgres')
  when 'MySQL'
    DB_ADAPTER = ActiveSupport::StringInquirer.new('mysql')
  end
rescue
  # probably not connected
  case OneBodyInfo.new.database_yaml['production']['adapter']
  when 'postgresql'
    DB_ADAPTER = ActiveSupport::StringInquirer.new('postgres')
  when 'mysql'
    DB_ADAPTER = ActiveSupport::StringInquirer.new('mysql')
  end
end

unless defined?(DB_ADAPTER)
  raise 'Unsupported database adapter.'
end

ONEBODY_VERSION = File.read(Rails.root.join('VERSION')).strip
