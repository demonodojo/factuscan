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
class LabInvoice < Invoice

  def self.is_mine?(ocr_info)
    ocr_info.search_line("DATOS REFERENTES A CUOTAS")
  end

  def calculate_amount
    self.amount = es_decimal(ocr_info.search_next_line_text('TOTAL LIQUIDO'))
  end

  def calculate_total
    es_decimal(ocr_info.search_below_line_text('TOTAL (Imp.Incluidos)'))
  end

  def calculate_discounts
    es_decimal(ocr_info.line_above(ocr_info.search_next_line('TOTAL LIQUIDO'))[:text]) * -1
  end

  def check_calculations
    begin
      calculate_total - calculate_discounts == calculate_amount
    rescue
      return false
    end
  end
end
