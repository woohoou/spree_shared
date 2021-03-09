class SpreeShared::TenantInitializer
  attr_reader :db_name

  def initialize(db_name, admin_email=nil, admin_password=nil)
    @db_name = db_name
    ENV['RAILS_CACHE_ID'] = @db_name
    ENV['AUTO_ACCEPT'] = 'true'
    ENV['SKIP_NAG'] = 'yes'

    @email = admin_email || ENV[@db_name.upcase+'_ADMIN_EMAIL'] || ENV['ADMIN_EMAIL'] || "spree@example.com"
    @password = admin_password || ENV[@db_name.upcase+'_ADMIN_PASSWORD'] || ENV['ADMIN_PASSWORD'] || "spree123"
  end

  def drop_database
    ActiveRecord::Base.establish_connection #make sure we're talkin' to db
    ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{@db_name} CASCADE")
  end

  def create_database
    Apartment::Tenant.create @db_name
  end

  def drop_and_create_database
    drop_database
    create_database
  end

  def load_seeds
    Apartment::Tenant.switch(@db_name) do
      Rails.application.load_seed
    end
  end

  def load_spree_sample_data
    Apartment::Tenant.switch(@db_name) do
      SpreeSample::Engine.load_samples
    end
  end

  def create_admin
    Apartment::Tenant.switch(@db_name) do
      unless Spree::User.find_by_email(@email)
        admin = Spree::User.create(:password => @password,
                            :password_confirmation => @password,
                            :email => @email,
                            :login => @email)
        role = Spree::Role.find_or_create_by name: "admin"
        admin.spree_roles << role
        admin.save
      end
    end
  end

end