# == Schema Information
#
# Table name: invoices
#
#  id           :bigint           not null, primary key
#  amount       :decimal(, )
#  invoice_date :date
#  ocr_data     :jsonb
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class LeymaInvoice < Invoice

  def self.is_mine?(ocr_info)
    ocr_info.search_line("LEYMA")
  end

  def calculate_amount
    ocr_info.using_included do
      self.amount = es_decimal(ocr_info.search_next_line_text('TOTAL en Euros'))
    end
    self.amount
  end
end
