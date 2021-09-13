class AddOcrDataToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :ocr_data, :jsonb
  end
end
