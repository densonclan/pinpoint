# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#
# Clients
#
clients = Client.create([
    { :name => 'Nisa', :code => 'NISA', :reference => 'NISA', :description => 'Nisa Stores'},
    { :name => 'Costcutter', :code => 'COSTCUTTER', :reference => 'COSTCUTTER', :description => 'Costcutter Stores'},
    { :name => 'Premier', :code => 'PREMIER', :reference => 'PREMIER', :description => 'Premier Stores'},
])

#
# Pages
#
pages = Page.create([
    { :name => 'A4 4 Pages', :description => '4 pages, Double sided', :reference_number =>'A4-04' },
    { :name => 'A4 6 Pages', :description => '6 pages, Double sided', :reference_number =>'A4-06' },
    { :name => 'A4 8 Pages', :description => '8 pages, Double sided', :reference_number =>'A4-08' },
])

#
# Options
#
options = Option.create([
    { :name => 'A', :description => 'Nisa & CC Licensed', :price_zone => 'Convenience', :multibuy => false, :licenced => true, :total_ambient => 11, :total_licenced => 5, :total_temp => 9, :reference_number => 'A' },
    { :name => 'B', :description => 'Nisa & CC Multibuy', :price_zone => 'Convenience', :multibuy => true, :licenced => false, :total_ambient => 16, :total_licenced => 0, :total_temp => 9, :reference_number => 'B' },
    { :name => 'D', :description => 'Nisa & CC Multibuy/Licensed', :price_zone => 'Convenience', :multibuy => true, :licenced => true, :total_ambient => 18, :total_licenced => 9, :total_temp => 13, :reference_number => 'D' },
    { :name => 'D (Sc)', :description => 'Nisa & CC Multibuy/Licensed (Sc)', :price_zone => 'Convenience', :multibuy => true, :licenced => true, :total_ambient => 18, :total_licenced => 9, :total_temp => 13, :reference_number => 'D-SC' },
    { :name => 'SD', :description => 'Nisa Fascia Multibuy/Licensed', :price_zone => 'Convenience', :multibuy => true, :licenced => true, :total_ambient => 18, :total_licenced => 9, :total_temp => 13, :reference_number => 'SD' },
    { :name => 'SD (Sc)', :description => 'Nisa Fascia Multibuy/Licensed', :price_zone => 'Convenience', :multibuy => true, :licenced => true, :total_ambient => 18, :total_licenced => 9, :total_temp => 13, :reference_number => 'SD-SC' },
    { :name => 'C', :description => 'Nisa & CC Licensed', :price_zone => 'High Street', :multibuy => false, :licenced => true, :total_ambient => 11, :total_licenced => 5, :total_temp => 9, :reference_number => 'C' },
    { :name => 'E', :description => 'Nisa & CC Multibuy', :price_zone => 'High Street', :multibuy => true, :licenced => false, :total_ambient => 16, :total_licenced => 0, :total_temp => 9, :reference_number => 'E' },
    { :name => 'F (Ni)', :description => 'Nisa & CC Multibuy (NI)', :price_zone => 'High Street', :multibuy => true, :licenced => false, :total_ambient => 25, :total_licenced => 0, :total_temp => 15, :reference_number => 'F-NI' },
    { :name => 'F1 (Ni)', :description => 'NISA', :price_zone => 'High Street', :multibuy => true, :licenced => false, :total_ambient => 30, :total_licenced => 0, :total_temp => 15, :reference_number => 'F1-NI' },
    { :name => 'G', :description => 'Nisa & CC Multibuy/Licensed', :price_zone => 'High Street', :multibuy => true, :licenced => true, :total_ambient => 24, :total_licenced => 10, :total_temp => 16, :reference_number => 'G' },
    { :name => 'G (Sc)', :description => 'Nisa & CC Multibuy/Licensed (Sc)', :price_zone => 'High Street', :multibuy => true, :licenced => true, :total_ambient => 24, :total_licenced => 10, :total_temp => 16, :reference_number => 'G-SC' },
    { :name => 'SG', :description => 'Nisa Fascia Multibuy/Licensed', :price_zone => 'High Street', :multibuy => true, :licenced => true, :total_ambient => 24, :total_licenced => 10, :total_temp => 16, :reference_number => 'SG' },
    { :name => 'SG (Sc)', :description => 'Nisa Fascia Multibuy/Licensed', :price_zone => 'High Street', :multibuy => true, :licenced => true, :total_ambient => 24, :total_licenced => 10, :total_temp => 16, :reference_number => 'SG-SC' },
    { :name => 'LG', :description => 'Loco Fascia Multibuy/Licensed', :price_zone => 'High Street', :multibuy => true, :licenced => true, :total_ambient => 24, :total_licenced => 10, :total_temp => 16, :reference_number => 'LG' },
    { :name => 'H', :description => 'Nisa & CC Multibuy/Licensed', :price_zone => 'Supermarket', :multibuy => true, :licenced => true, :total_ambient => 32, :total_licenced => 13, :total_temp => 25, :reference_number => 'H' },
    { :name => 'H (Sc)', :description => 'Nisa & CC Multibuy/Licensed (Sc)', :price_zone => 'Supermarket', :multibuy => true, :licenced => true, :total_ambient => 32, :total_licenced => 13, :total_temp => 25, :reference_number => 'H-SC' },
    { :name => 'H2 (NI)', :description => 'Nisa  ', :price_zone => 'Supermarket', :multibuy => true, :licenced => false, :total_ambient => 30, :total_licenced => 0, :total_temp => 25, :reference_number => 'H2-NI' },
    { :name => 'H3 (NI)', :description => 'Nisa & CC Multibuy (NI)', :price_zone => 'Supermarket', :multibuy => true, :licenced => true, :total_ambient => 32, :total_licenced => 13, :total_temp => 25, :reference_number => 'H3-NI' },
    { :name => 'SH', :description => 'Nisa Fascia Multibuy/Licensed', :price_zone => 'Supermarket', :multibuy => true, :licenced => true, :total_ambient => 32, :total_licenced => 13, :total_temp => 25, :reference_number => 'SH' },
    { :name => 'LH', :description => 'Loco Fascia Multibuy/Licensed', :price_zone => 'Supermarket', :multibuy => true, :licenced => true, :total_ambient => 32, :total_licenced => 13, :total_temp => 25, :reference_number => 'LH' },
    { :name => 'X', :description => 'Nis & CC Multibuy/Licensed', :price_zone => 'Nisa & costcutter', :multibuy => true, :licenced => true, :total_ambient => 13, :total_licenced => 3, :total_temp => 4, :reference_number => 'X' },
])

#
# Distributors
#
distributors = Distributor.create([
    { :name => 'Store Delivery', :distributor_type => 'in-store', :reference_number => 'STORE-01',  :description => ''},
    { :name => 'SOLUS Team', :distributor_type => 'solus', :reference_number => 'SOLUS-01',  :description => ''},
    { :name => 'Royal Mail', :distributor_type => 'royal-mail', :reference_number => 'ROYALMAIL-01',  :description => ''},
    { :name => 'Newspaper', :distributor_type => 'newspaper', :reference_number => 'NEWSPAPER-01',  :description => ''},
    { :name => 'Store/Own Dist', :distributor_type => 'store-own-dost', :description => 'Stores with own distribution', :reference_number => "ST-OWN"}
])

#
# Periods
#
first_period = Period.create({
    :period_number => 1,
    :week_number => 298,
    :completed => false,
    :current => true
})

# first_period.period_dates.build({
#     :client_id => Client.find_by_name('Nisa').id,
#     :date_promo => '12-12-2012',
#     :date_samples => '12-12-2012',
#     :date_approval => '12-12-2012',
#     :date_print => '12-12-2012',
#     :date_dispatch => '12-12-2012'
# })

#
# Create periods from 2 to 17
#
# (2..17).each do |i|

#     Period.create({
#         :period_number => i,
#         :week_number => (first_period.week_number + 3),
#         :date_promo => (first_period.date_promo.to_date + 21),
#         :date_samples => (first_period.date_samples.to_date + 21),
#         :date_approval => (first_period.date_approval.to_date + 21),
#         :date_print => (first_period.date_print.to_date + 21),
#         :date_dispatch => (first_period.date_dispatch.to_date + 21),
#         :completed => false,
#         :current => false
#     })

# end

#
# Departments
#
departments = Department.create([
    { :name => "Administrator", :short_code => 'administrator', :description => "Pinpoint administrators"},
    { :name => "Nisa", :short_code => 'nisa', :description => "Nisa employees"},
    { :name => "Costcutter", :short_code => 'costcutter', :description => "Costcutter employees"},
    { :name => "Pending", :short_code => 'pending', :description => "Pending upon approval"},
])

#
# Users
#
# Administrator:
#   Email: pinpoint@gaskandhawley.com
#   Password: password2
#
users = User.create([
    { :email => 'pinpoint@gaskandhawley.com',
      :password => 'pr0cess08',
      :name => 'Administrator',
      :approved => true,
      :department => departments.first }
])
