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
class PascualInvoice < Invoice

  def self.is_mine?(ocr_info)
    ocr_info.search_line("IDENTIFICACION DEL COMPRADOR")
  end

  def calculate_amount
    self.amount = es_decimal(ocr_info.search_next_line_text('TOTAL A PAGAR: (EUROS)'))
  end

  def fat
    es_decimal(ocr_info.search_next_line_text('MG'))
  end

end
