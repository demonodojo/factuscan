class AddTypeToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :type, :string
    add_column :invoices, :amount, :decimal
  end
end
