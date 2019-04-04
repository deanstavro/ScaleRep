# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#user = CreateAdminService.new.call
#puts 'CREATED ADMIN USER: ' << user.email

#admin users
AdminUser.create!(email: 'dean@scalerep.com', password: 'Sc@leRep123!', password_confirmation: 'Sc@leRep123!') unless AdminUser.exists?(email: 'dean@scalerep.com')
AdminUser.create!(email: 'paul@scalerep.com', password: 'Sc@leRep123!', password_confirmation: 'Sc@leRep123!') unless AdminUser.exists?(email: 'paul@scalerep.com')

# client client_companies
papito = ClientCompany.create!(name:'Papito', company_domain:'papito.com', monthlyContactEngagementCount: 200, account_manager: 'Isaias Bustos') unless ClientCompany.exists?(company_domain: 'papito.com')
ClientCompany.create!(name:'Sunoco', company_domain:'sunoco.com', monthlyContactEngagementCount: 200, account_manager: 'Isaias Bustos') unless ClientCompany.exists?(company_domain: 'sunoco.com')
