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
class AsciiInvoice < Invoice

  def self.is_mine?(ocr_info)
    ocr_info.search_line("ANALITICA") && ocr_info.search_line("Cantidad Miles")
  end

  def calculate_amount
    ocr_info.using_included do
      self.amount = es_decimal(ocr_info.search_nearest_line_text(0.7856249809265137,0.8225463628768921))
    end
    self.amount
  end

  def valid?(context = nil)
    super
  end
end
