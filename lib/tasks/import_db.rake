task import_xlsx: [:environment] do
  workbook = Roo::Spreadsheet.open './lib/tasks/database.xlsx'
  worksheets = workbook.sheets
  puts "Found #{worksheets.count} worksheets"

  user = User.find_by(email: 'oscar@gmail.com')
  account = user.account
  warehouse = account.warehouses.last
  all_keys = %w[import_id	  description	name	  presentation	trademark	model_rrss	provider	list_price	DESCORDINARIO	purchase_cost_package	purchase_cost_unit	PRECIO1	sale_price_unit	PRECIO3	PRECIO4	sale_price_package	total_unit	  characteristics	generic_name	industry	  controled	  min_stock	      max_stock	      alternative_code	unit	  package	category	sub_category	taxes	    FLAGGRANEL	FLAGFVENCIMIENTO	FLAGDISCONTINUADO	FLAGSERIE	FLAGLOTE	FLAGOFERTA	FLAGSERVICIO	FLAGKIT	COMISION	TIPOBCODE	IDPROVEEDOR	TC	COSTOUNITME	PRECIOUNITME	CODPROVEEDOR	OFERTA	DOCULTIMACOMPRA	SALDONEGATIVO	PRINTCOMANDAOMISION	FACTOR1	FACTOR2	FACTOR3	FACTOR4	PESO	total_stock	FECHAINICIAL	FECHAFINAL	PRECIOELEGIDO	DESCUENTO	DIASSEMANA	TALLA	COLOR	ANIO	UBICACION	CILINDRADA	USRADICIONA	FECHAHORAADICIONA	USRMODIFICA	FECHAHORAMODIFICA]
  product_keys = %w[import_id	description	name	presentation	trademark	model_rrss	provider	total_unit	characteristics	generic_name	industry	controled	alternative_code	unit	package	category	sub_category]
  item_keys = %w[list_price	purchase_cost_package	purchase_cost_unit	sale_price_unit	sale_price_package	min_stock	max_stock	total_stock]
  
  errors = []
  worksheets.each do |worksheet|
    puts "Reading: #{worksheet}"
    workbook.sheet(worksheet).each_row_streaming(offset: 1, pad_cells: true) do |row|
      all_data = {}
      row.each_with_index do |cell, index| 
        key = all_keys[index]
        all_data[key] = cell&.value
      end
      provider_name = all_data.delete('provider') || 'sin nombre'
      provider = Provider.find_or_create_by(
        account_id: account.id,
        social_reason: provider_name,
        nit: 0
      )
      
      product_data = all_data.select {|k,v| product_keys.include?(k)}
      product_data['customer_id'] = provider.id
      product_data['account_id'] = account.id
      product_data['taxes'] = product_data['taxes'] == 'SI'
      product_data['controled'] = product_data['controled'] == 'SI'
      product = Product.create(product_data)
      if product.new_record?
        required_fields = ['name', 'description', 'presentation', 'generic_name', 'unit', 'package', 'category', 'sub_category', 'account_id', 'trademark']
        required_fields.each do |attr|
          product_data[attr] = 0 if product_data[attr].nil?
        end
        product = Product.create(product_data)
        errors << product if product.new_record?
      end

      item_data = all_data.select {|k,v| item_keys.include?(k)}
      item_data['product_id'] = product.id
      item_data['warehouse_id'] = warehouse.id
      item_data['code'] = product.import_id
      item_data['quantity'] = item_data['total_stock'].to_i / product.total_unit.to_i
      item  = Item.create(item_data)      

      if item.new_record?
        required_fields = ['quantity', 'total_stock', 'sale_price_unit', 'purchase_cost_package', 'purchase_cost_unit', 'code']
        required_fields.each do |attr|
          item_data[attr] = 0 if item_data[attr].nil?
        end
        item = Item.create(item_data)
        errors << item if item.new_record?
      end
      puts "Product created: #{product.name}"
      if product.new_record? || item.new_record? || provider.new_record?
        puts "product not created" 
        puts "item not created"
        puts "provider not created"
      end
    end
  end
  puts ">>>>>>>>>>>>>>> Finalizado exitosamente!"
end