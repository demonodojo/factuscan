class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.date :invoice_date

      t.timestamps
    end
  end
end
