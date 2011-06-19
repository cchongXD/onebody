def sql_concat(*args)
  case DB_ADAPTER
  when 'mysql'
    "CONCAT(#{args.join(', ')})"
  when 'postgres'
    args.join(' || ')
  end
end

def sql_date_part(expr, part)
  case DB_ADAPTER
  when 'mysql'
    "#{part}(#{expr})"
  when 'postgres'
    "date_part('#{part}', #{expr})"
  end
end

def sql_year(expr)
  sql_date_part(expr, 'year')
end

def sql_month(expr)
  sql_date_part(expr, 'month')
end

def sql_day(expr)
  sql_date_part(expr, 'day')
end

def sql_now
  "now()"
end

def sql_random
  case DB_ADAPTER
  when 'mysql'
    "rand()"
  when 'postgres'
    "random()"
  end
end

def sql_adddate(expr, interval)
  case DB_ADAPTER
  when 'mysql'
    "adddate(#{expr}, interval #{interval.sub(/s$/i, '')})"
  when 'postgres'
    "#{expr} + cast('#{interval}' as interval)"
  end
end

def sql_curdate
  case DB_ADAPTER
  when 'mysql'
    "curdate()"
  when 'postgres'
    "current_date"
  end
end

def sql_ilike
  case DB_ADAPTER
  when 'mysql'
    # like is case insensitive in MySQL by default
    "like"
  when 'postgres'
    "ilike"
  end
end

class ActiveRecord::Base

  def self.scope_by_site_id
    default_scope lambda { where(:site_id => Site.current.id) }
  end

  def self.hashify(options)
    return [] unless connection.adapter_name == 'MySQL'
    attributes = options[:attributes].select { |a| column_names.include?(a.to_s) }.map { |a| "IFNULL(#{a}, '')" }.join(',')
    conditions = []
    conditions << "id in (#{options[:ids].to_a.map { |id| id.to_i }.join(',')})" if options[:ids].to_a.any?
    conditions << "legacy_id in (#{options[:legacy_ids].map { |id| id.to_i }.join(',')})" if options[:legacy_ids].to_a.any?
    connection.select_all("select id, legacy_id, #{table_name =~ /people/ ? 'family_id,' : nil} #{options[:debug] ? '' : 'SHA1'}(CONCAT(#{attributes})) as hash from `#{table_name}` where #{conditions.join(' or ')} and site_id=#{Site.current.id} limit #{MAX_RECORD_HASHES}")
  end

  def self.digits_only_for_attributes=(attributes)
    attributes.each do |attribute|
      class_eval "
        def #{attribute}=(val)
          write_attribute :#{attribute}, val.to_s.digits_only
        end
      "
    end
  end

  def self.fall_through_attributes(*attributes)
    options = attributes.pop.symbolize_keys
    attributes.each do |attribute|
      class_eval "
        def #{attribute}; #{options[:to]} && #{options[:to]}.#{attribute}; end
      "
    end
  end

end
