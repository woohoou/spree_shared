namespace :spree_shared do
  desc "Bootstraps single database."
  task :bootstrap, [:db_name] => [:environment] do |t, args|
    if args[:db_name].blank?
      puts %q{You must supply db_name, with "rake spree_shared:bootstrap['the_db_name']"}
    else
      db_name = args[:db_name]

      #convert name to postgres friendly name
      db_name.gsub!('-','_')

      initializer = SpreeShared::TenantInitializer.new(db_name)
      
      puts "Creating database: #{db_name}"
      initializer.drop_and_create_database
      
      puts "Loading seeds into database: #{db_name}"
      initializer.load_seeds
      
      if ENV['LOAD_SAMPLE_DATA']
        puts "Loading sample data into database: #{db_name}"
        initializer.load_spree_sample_data
      end
      
      puts "Create admin user into database: #{db_name}"
      initializer.create_admin

      puts "Bootstrap completed successfully"
    end

  end

end
