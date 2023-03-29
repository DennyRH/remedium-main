# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'

emails = ['sergio@gmail.com', 'oscar@gmail.com', 'denny@gmail.com']
roles = ['owner', 'admin', 'sales']

type_of_taxpayers = ['Persona Natural', 'Persona Jurídica']

# method puts the successfull create and errors
def save_and_puts_result(instance, name)
  if instance.save
    puts "Successfull Create #{instance.class} #{name}"
    instance
  else
    puts "Errors Create #{instance.class} #{name}"
  end
end

# Create warehouse details first and after a warehouse
def create_access_alloweds(user, warehouse)
  new_access_allowed = AccessAllowed.new(user_id: user.id, warehouse_id: warehouse.id)
  save_and_puts_result(new_access_allowed, "for #{user.role.name}")
end

def create_warehouse_details(warehouse, counter_branch_code)
  new_warehouse_detail = WarehouseDetail.new(
    address: Faker::Address.full_address, warehouse_id: warehouse.id,
    municipality: Faker::Address.city, branch_code: counter_branch_code,
    nit: Faker::Company.polish_taxpayer_identification_number
  )
  save_and_puts_result(new_warehouse_detail, "for #{warehouse.name}")
end

def create_pos_session(warehouse, user)
  new_pos_session = PosSession.new(
    warehouse_id: warehouse.id, petty_cash: 300, type_of_currency: 'bs',
    user_id: user.id
  )
  save_and_puts_result(new_pos_session, "for warehouse #{warehouse.name}")
  new_pos_session.update(status: 'closed')
end

def create_provider(account)
  provider = Provider.create(
    nit: Faker::Company.polish_taxpayer_identification_number,
    social_reason: Faker::Company.name, email: Faker::Internet.email,
    account_id: account.id, phone: Faker::Company.czech_organisation_number
  )
  puts "Create successfull customer #{provider.social_reason}"
end

def create_user(counter_user, account)
  user = User.create(
    email: Faker::Internet.email, password: '123123', account_id: account.id,
    role_id: counter_user == 2 ? counter_user : 3, name: Faker::Name.male_first_name,
    last_name: Faker::Name.last_name, ci: Faker::Company.czech_organisation_number
  )
  puts "Create successfull user #{user.name}"
end

def create_items(warehouse, account)
  products = Product.where(account_id: account.id)
  puts "Creatings Items in the warehouse #{warehouse.name}"
  products.each do |obj|
    qty = rand(30..60)
    price_list = rand(130.1..170.9)
    cost_unit = price_list / obj.total_unit
    sale_price_unit = cost_unit + cost_unit * 0.15
    Item.create(
      warehouse_id: warehouse.id, product_id: obj.id, quantity: qty,
      total_stock: qty * obj.total_unit, min_stock: rand(140..250),
      max_stock: rand(900..1400), code: Faker::Code.nric, list_price: price_list.round(2),
      purchase_cost_package: price_list.round(2), purchase_cost_unit: cost_unit.round(2),
      sale_price_unit: sale_price_unit.round(2)
    )
  end
end

def create_warehouses(account, user)
  puts 'Creating Warehouses'
  counter_branch_code = 0

  3.times do
    new_warehouse = Warehouse.new(name: Faker::Address.street_name, account_id: account.id)
    save_and_puts_result(new_warehouse, new_warehouse.name)
    create_access_alloweds(user, new_warehouse)
    create_warehouse_details(new_warehouse, counter_branch_code)
    create_pos_session(new_warehouse, user)
    counter_branch_code += 1
    create_items(new_warehouse, account)
  end
end

def create_employees(account)
  puts "creating users and customers for #{account.name}"
  counter_user = 2
  3.times do
    create_provider(account)
    create_user(counter_user, account)
    counter_user += 1
  end
end

def create_account(type_of_taxpayers, obj)
  new_account = Account.new(
    name: Faker::Company.name, nit: Faker::Company.polish_taxpayer_identification_number,
    phone: Faker::Company.czech_organisation_number, email: obj, municipality: Faker::Address.city,
    sector_type_document: 'Factura de Compra y Venta', address: Faker::Address.street_address,
    invoice_type: 'Facturas con derecho a crédito fiscal', bussiness_type: Faker::Company.industry,
    type_of_taxpayer: type_of_taxpayers[rand(0..1)], economic_activity: Faker::IndustrySegments.super_sector,
    social_reason: Faker::Company.name
  )
  save_and_puts_result(new_account, new_account.name)
end

def create_products(account, customers)
  counter_product = 1
  units = ['CAPSULA BLANDA', 'CAPSULA', 'COMPRIMIDOS', 'TABLETA']
  generic_name = ['ISOTRETINOINA', 'IBUFLAMANTE', 'ANTIALERGICOS', 'ASITRONEINA']

  20.times do
    name_product = "producto#{counter_product} prueba#{counter_product}"
    unit = units[rand(0..3)]
    total_unit = rand(20..40)
    new_product = Product.new(
      name: name_product, description: "#{name_product} #{rand(10..30)}MG X #{total_unit} #{unit}",
      code: Faker::Code.nric, presentation: 'X 1 CAJA', trademark: 'LIFE SCIENCES',
      customer_id: customers.sample.id, account_id: account.id, generic_name: generic_name[rand(0..3)],
      unit: unit, package: 'CAJA', category: 'MEDICAMENTOS', sub_category: 'GENERAL',
      characteristics: 'DOLOR FATIGA', total_unit: total_unit
    )
    save_and_puts_result(new_product, new_product.name)
    counter_product += 1
  end
end

puts 'Creating Roles'
roles.each do |obj|
  role = Role.new(name: obj, account_id: 0)
  save_and_puts_result(role, obj)
end

puts 'Creating Accounts and Users'
emails.each do |obj|
  new_account = create_account(type_of_taxpayers, obj)
  new_user = User.new(email: obj, password: '123456', account: new_account, role_id: 1)
  save_and_puts_result(new_user, new_user.email)
  create_employees(new_account)
  providers = Provider.where(account_id: new_account.id)
  create_products(new_account, providers)
  create_warehouses(new_account, new_user)
end
